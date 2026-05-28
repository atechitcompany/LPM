import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lightatech/FormComponents/FLoatingButton.dart';
import 'package:lightatech/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lightatech/core/session/session_manager.dart';
import '../models/task.dart';
import '../models/floating_sheet_type.dart';
import 'task_detail_page.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/gestures.dart';
import 'package:lightatech/Features/Dashboard/screens/sidebar_menu.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class MapScreen extends StatefulWidget {
  const MapScreen({super.key, required this.title});

  final String title;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController taskName = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // --- BEGIN NEW MAP SECTIONS UI (TABS & PRIORITIES) ---
  String _activeTab = 'My Work';
  // --- END NEW MAP SECTIONS UI (TABS & PRIORITIES) ---

  OverlayEntry? _floatingSheetOverlay;

  final List<Task> tasks = [];

  // selected tasks for multi-select
  final Set<Task> _selected = {};

  // --- BEGIN COLLAPSIBLE PRIORITIES ---
  final Set<String> _collapsedPriorities = {};
  // --- END COLLAPSIBLE PRIORITIES ---

  // --- BEGIN TASK SORTING MECHANISM ---
  String _sortBy = 'Priority'; // 'Priority' or 'Date Created'
  bool _sortAscending = true; // true = ascending / default, false = descending
  // --- END TASK SORTING MECHANISM ---

  // --- BEGIN DYNAMIC SORT/FILTER LOGIC ---
  String? _selectedPersonFilter;
  String _personSearchQuery = '';
  bool _isSecondaryDropdownOpen = false;
  // --- END DYNAMIC SORT/FILTER LOGIC ---

  bool _wasKeyboardVisible = false;

  // temp selections while creating a new task
  String? _newTaskPriority;
  String? _newTaskReminder;
  String? _newTaskAssignee;
  // --- BEGIN NEW ACCOMPANY FIELD ---
  String? _newTaskAccompany;
  // --- END NEW ACCOMPANY FIELD ---
  String? _newTaskDeadline;
  String? _newTaskWorkType;
  String? _newTaskFolder;
  String? _newTaskClientName;

  //Draggable list
  // Draggable button order (uses existing FloatingSheetType)
  // Default button order (MUST COME FIRST)
  final List<FloatingSheetType> _defaultOrder = [
    FloatingSheetType.priority,
    FloatingSheetType.remind,
    FloatingSheetType.assign,
    // --- BEGIN NEW ACCOMPANY FIELD ---
    FloatingSheetType.accompany,
    // --- END NEW ACCOMPANY FIELD ---
    FloatingSheetType.deadline,
    FloatingSheetType.workType,
    FloatingSheetType.folder,
    FloatingSheetType.clientName,
  ];

  // Draggable button order
  late List<FloatingSheetType> _buttonOrder = List.from(_defaultOrder);

  // Firestore collection reference
  final CollectionReference tasksCollection = FirebaseFirestore.instance
      .collection('tasks');

  // collapsed/expanded state for completed section
  bool _isAddTaskSheetOpen = false;

  bool _completedCollapsed = false;

  // cache for assignees (loaded from Firestore)
  List<String>? _assigneesCache;
  List<String>? _clientsCache;

  @override
  void initState() {
    super.initState();
    NotificationService.isMapScreenActive = true;
    // 1️⃣ Load saved button order (Priority / Remind / Assign / etc.)
    _loadButtonOrder();

    // 2️⃣ Load tasks AFTER first frame (existing behavior)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTasksFromFirebase();
    });
  }
  //Reminder Format
  String _formatDateTime(String input) {
    if (input.isEmpty) return '';
    final parts = input.split(', ');
    final formattedParts = parts.map((part) {
      try {
        final dt = DateTime.parse(part);
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final tomorrow = today.add(const Duration(days: 1));
        final date = DateTime(dt.year, dt.month, dt.day);

        final timeStr =
            '${dt.hour % 12 == 0 ? 12 : dt.hour % 12}:${dt.minute.toString().padLeft(2, '0')} ${dt.hour >= 12 ? 'PM' : 'AM'}';

        if (date == today) return 'Today $timeStr';
        if (date == tomorrow) return 'Tomorrow $timeStr';
        return '${dt.day}/${dt.month} $timeStr';
      } catch (_) {
        return part;
      }
    }).toList();
    return formattedParts.join(', ');
  }

  Future<void> _saveButtonOrder() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'home_button_order',
      _buttonOrder.map((e) => e.name).toList(),
    );
  }

  Widget _buildBottomSheetButtonWithState(
      FloatingSheetType type,
      StateSetter setModalState,
      ) {
    IconData icon;
    String label;
    String? selectedValue;
    void Function(String) onSelected;
    void Function() onClear;

    switch (type) {
      case FloatingSheetType.priority:
        icon = Icons.flag_outlined;
        label = "Priority";
        selectedValue = _newTaskPriority;
        onSelected = (v) {
          setState(() => _newTaskPriority = v);
          setModalState(() {});
        };
        onClear = () {
          setState(() => _newTaskPriority = null);
          setModalState(() {});
        };
        break;
      case FloatingSheetType.remind:
        icon = Icons.notifications_active;
        label = "Remind Me";
        selectedValue = _newTaskReminder != null ? _formatDateTime(_newTaskReminder!) : null;
        onSelected = (v) {
          setState(() => _newTaskReminder = v);
          setModalState(() {});
        };
        onClear = () {
          setState(() => _newTaskReminder = null);
          setModalState(() {});
        };
        break;
      case FloatingSheetType.assign:
        icon = Icons.assignment;
        label = "Assign";
        selectedValue = _newTaskAssignee;
        onSelected = (v) {
          setState(() => _newTaskAssignee = v);
          setModalState(() {});
        };
        onClear = () {
          setState(() => _newTaskAssignee = null);
          setModalState(() {});
        };
        break;
      // --- BEGIN NEW ACCOMPANY FIELD ---
      case FloatingSheetType.accompany:
        icon = Icons.people_outline;
        label = "Accompany";
        selectedValue = _newTaskAccompany;
        onSelected = (v) {
          setState(() => _newTaskAccompany = v);
          setModalState(() {});
        };
        onClear = () {
          setState(() => _newTaskAccompany = null);
          setModalState(() {});
        };
        break;
      // --- END NEW ACCOMPANY FIELD ---
      case FloatingSheetType.deadline:
        icon = Icons.alarm;
        label = "Deadline";
        selectedValue = _newTaskDeadline != null ? _formatDateTime(_newTaskDeadline!) : null;
        onSelected = (v) {
          setState(() => _newTaskDeadline = v);
          setModalState(() {});
        };
        onClear = () {
          setState(() => _newTaskDeadline = null);
          setModalState(() {});
        };
        break;
      case FloatingSheetType.workType:
        icon = Icons.insert_drive_file;
        label = "Work Type";
        selectedValue = _newTaskWorkType;
        onSelected = (v) {
          setState(() => _newTaskWorkType = v);
          setModalState(() {});
        };
        onClear = () {
          setState(() => _newTaskWorkType = null);
          setModalState(() {});
        };
        break;
      case FloatingSheetType.folder:
        icon = Icons.folder_outlined;
        label = "Folder";
        selectedValue = _newTaskFolder;
        onSelected = (v) {
          setState(() => _newTaskFolder = v);
          setModalState(() {});
        };
        onClear = () {
          setState(() => _newTaskFolder = null);
          setModalState(() {});
        };
        break;
      case FloatingSheetType.clientName:
        icon = Icons.business_center_outlined;
        label = "Client Name";
        selectedValue = _newTaskClientName;
        onSelected = (v) {
          setState(() => _newTaskClientName = v);
          setModalState(() {});
        };
        onClear = () {
          setState(() => _newTaskClientName = null);
          setModalState(() {});
        };
        break;
    }

    final bool isSelected = selectedValue != null && selectedValue.isNotEmpty;
    final String displayText = isSelected ? selectedValue : label;

    return Builder(
      builder: (buttonContext) => AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: isSelected ? Colors.brown.shade50 : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? Colors.brown : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () =>
                  _showFloatingSheet(buttonContext, type, onSelected: onSelected, setModalState: setModalState),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 17),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(
                          scale: animation,
                          child: FadeTransition(opacity: animation, child: child),
                        );
                      },
                      child: Icon(
                        icon,
                        key: ValueKey('icon_$isSelected'),
                        size: 18,
                        color: isSelected ? Colors.brown : Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        return SizeTransition(
                          sizeFactor: animation,
                          axis: Axis.horizontal,
                          axisAlignment: -1,
                          child: FadeTransition(opacity: animation, child: child),
                        );
                      },
                      child: Text(
                        displayText,
                        key: ValueKey('text_$displayText'),
                        style: TextStyle(
                          color: isSelected ? Colors.brown : Colors.grey.shade700,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    // Show cross button only when selected
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: isSelected ? 24 : 0,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: isSelected ? 1.0 : 0.0,
                        child: isSelected
                            ? GestureDetector(
                          onTap: () {
                            onClear();
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.brown,
                            ),
                          ),
                        )
                            : const SizedBox.shrink(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    NotificationService.isMapScreenActive = false;
    _hideFloatingSheet();
    _focusNode.dispose();
    taskName.dispose();
    _searchController.dispose(); // ADD THIS
    super.dispose();
  }

  Future<void> _loadButtonOrder() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('home_button_order');

    if (!mounted) return;

    setState(() {
      if (saved == null) {
        _buttonOrder = List.from(_defaultOrder);
        return;
      }

      _buttonOrder = saved
          .map(
            (e) => FloatingSheetType.values.firstWhere(
              (v) => v.name == e,
          orElse: () => _defaultOrder.first,
        ),
      )
          .toList();
    });
  }

  Future<DateTime?> pickDateTimeWithTabs(
      BuildContext context, {
        DateTime? initial,
      }) async {
    DateTime selectedDate = initial ?? DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.fromDateTime(initial ?? DateTime.now());

    int tabIndex = 0;

    return showDialog<DateTime>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: SizedBox(
                height: 430,
                child: Column(
                  children: [
                    Row(
                      children: [
                        _tabButton(
                          title: "DATE",
                          selected: tabIndex == 0,
                          onTap: () => setState(() => tabIndex = 0),
                        ),
                        _tabButton(
                          title: "TIME",
                          selected: tabIndex == 1,
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: selectedTime,
                            );
                            if (picked != null) {
                              selectedTime = picked;
                              setState(() => tabIndex = 1);
                            }
                          },
                        ),
                      ],
                    ),
                    Expanded(
                      child: tabIndex == 0
                          ? CalendarDatePicker(
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                        onDateChanged: (date) {
                          selectedDate = date;
                        },
                      )
                          : Center(
                        child: Text(
                          selectedTime.format(context),
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("CANCEL"),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              final result = DateTime(
                                selectedDate.year,
                                selectedDate.month,
                                selectedDate.day,
                                selectedTime.hour,
                                selectedTime.minute,
                              );
                              Navigator.pop(context, result);
                            },
                            child: const Text("SAVE"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _tabButton({
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected ? Colors.blue : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: selected ? Colors.blue : Colors.black54,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ------------ Order Helper ---------------
  Widget _buildBottomSheetButton(FloatingSheetType type) {
    IconData icon;
    String label;
    void Function(String) onSelected;

    switch (type) {
      case FloatingSheetType.priority:
        icon = Icons.flag_outlined;
        label = "Priority";
        onSelected = (v) => setState(() => _newTaskPriority = v);
        break;
      case FloatingSheetType.remind:
        icon = Icons.notifications_active;
        label = "Remind Me";
        onSelected = (v) => setState(() => _newTaskReminder = v);
        break;
      case FloatingSheetType.assign:
        icon = Icons.assignment;
        label = "Assign";
        onSelected = (v) => setState(() => _newTaskAssignee = v);
        break;
      // --- BEGIN NEW ACCOMPANY FIELD ---
      case FloatingSheetType.accompany:
        icon = Icons.people_outline;
        label = "Accompany";
        onSelected = (v) => setState(() => _newTaskAccompany = v);
        break;
      // --- END NEW ACCOMPANY FIELD ---
      case FloatingSheetType.deadline:
        icon = Icons.alarm;
        label = "Deadline";
        onSelected = (v) => setState(() => _newTaskDeadline = v);
        break;
      case FloatingSheetType.workType:
        icon = Icons.insert_drive_file;
        label = "Work Type";
        onSelected = (v) => setState(() => _newTaskWorkType = v);
        break;
      case FloatingSheetType.folder:
        icon = Icons.folder_outlined;
        label = "Folder";
        onSelected = (v) => setState(() => _newTaskFolder = v);
        break;

      case FloatingSheetType.clientName:
        icon = Icons.business_center_outlined;
        label = "Client Name";
        onSelected = (v) => setState(() => _newTaskClientName = v);
        break;
    }

    return Builder(
      builder: (buttonContext) => TextButton.icon(
        onPressed: () =>
            _showFloatingSheet(buttonContext, type, onSelected: onSelected),
        icon: Icon(icon, size: 18, color: Colors.brown),
        label: Text(label),
      ),
    );
  }



  // ---------- Firestore helpers ----------
  Future<void> _loadTasksFromFirebase() async {
    final snapshot = await tasksCollection.get();

    final loaded = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Task.fromMap(doc.id, data);
    }).toList();

    loaded.sort(_taskComparator);

    setState(() {
      tasks
        ..clear()
        ..addAll(loaded);
    });
  }

  Future<void> _addTaskToFirebase(Task task) async {
    final docRef = await tasksCollection.add(task.toMap());
    task.id = docRef.id;
  }

  Future<void> _updateTaskInFirebase(Task task) async {
    if (task.id == null) return;
    await tasksCollection.doc(task.id).update(task.toMap());
  }

  Future<void> _deleteTaskFromFirebase(Task task) async {
    if (task.id == null) return;
    await tasksCollection.doc(task.id).delete();
  }

  Future<void> _handleAddTaskFromSheet() async {
    final text = taskName.text.trim();
    if (text.isEmpty) return;

    final nowMs = DateTime.now().millisecondsSinceEpoch;

    final newTask = Task(
      text,
      // --- BEGIN NEW TAB LOGIC ---
      createdBy: SessionManager.getEmail() ?? '',
      // --- END NEW TAB LOGIC ---
      priority: _newTaskPriority,
      reminder: _newTaskReminder,
      assignee: _newTaskAssignee,
      // --- BEGIN NEW ACCOMPANY FIELD ---
      accompany: _newTaskAccompany,
      // --- END NEW ACCOMPANY FIELD ---
      deadline: _newTaskDeadline,
      workType: _newTaskWorkType,
      folder: _newTaskFolder,
      clientName: _newTaskClientName,
      priorityUpdatedAt: _newTaskPriority != null ? nowMs : null,
    );

    await _addTaskToFirebase(newTask);

    setState(() {
      tasks.add(newTask);
      _sortTasks();

      // Reset ALL temporary selections
      _newTaskPriority = null;
      _newTaskReminder = null;
      _newTaskAssignee = null;
      // --- BEGIN NEW ACCOMPANY FIELD ---
      _newTaskAccompany = null;
      // --- END NEW ACCOMPANY FIELD ---
      _newTaskDeadline = null;
      _newTaskWorkType = null;
      _newTaskFolder = null;
      _newTaskClientName = null;
    });

    // Clear input and refocus
    taskName.clear();
    await Future.delayed(const Duration(milliseconds: 80));
    _focusNode.requestFocus();
  }

  // ---------- priority sorting helpers ----------
  int _priorityOrder(String? p) {
    switch (p) {
      case 'U1':
        return 1;
      case 'U2':
        return 2;
      case 'U3':
        return 3;
      case 'Urgent':
        return 4;
      case 'IMP':
        return 5;
      case 'Today':
        return 6;
      case 'Tomorrow':
        return 7;
      case 'Day Later':
        return 8;
      case 'Later':
        return 9;
      case 'Process':
        return 10;
      case 'Hold':
        return 11;
      case 'Free':
        return 12;
      default:
        return 100; // no / unknown priority goes last
    }
  }

  // NEW: comparator puts completed tasks first, then sorted by custom criteria
  int _taskComparator(Task a, Task b) {
    // Completed (isDone == true) come first (unless explicitly sorting by Status)
    if (_sortBy != 'Status') {
      if (a.isDone != b.isDone) {
        return a.isDone ? 1 : -1;
      }
    }

    if (_sortBy == 'Date Created') {
      final da = _parseCreatedDate(a.createdDate) ?? DateTime(1970);
      final db = _parseCreatedDate(b.createdDate) ?? DateTime(1970);
      return _sortAscending ? da.compareTo(db) : db.compareTo(da);
    }

    if (_sortBy == 'Deadline') {
      final da = a.deadline != null ? DateTime.tryParse(a.deadline!) ?? DateTime(2100) : DateTime(2100);
      final db = b.deadline != null ? DateTime.tryParse(b.deadline!) ?? DateTime(2100) : DateTime(2100);
      return _sortAscending ? da.compareTo(db) : db.compareTo(da);
    }

    if (_sortBy == 'Status') {
      final sa = a.isDone ? 1 : 0;
      final sb = b.isDone ? 1 : 0;
      return _sortAscending ? sa.compareTo(sb) : sb.compareTo(sa);
    }

    if (_sortBy == 'Name of the User') {
      final sa = a.assignee ?? '';
      final sb = b.assignee ?? '';
      return _sortAscending ? sa.toLowerCase().compareTo(sb.toLowerCase()) : sb.toLowerCase().compareTo(sa.toLowerCase());
    }

    if (_sortBy == 'Assigned by') {
      final sa = a.createdBy ?? '';
      final sb = b.createdBy ?? '';
      return _sortAscending ? sa.toLowerCase().compareTo(sb.toLowerCase()) : sb.toLowerCase().compareTo(sa.toLowerCase());
    }

    // Default Priority sorting
    final pa = _priorityOrder(a.priority);
    final pb = _priorityOrder(b.priority);

    if (pa != pb) {
      return _sortAscending ? pa.compareTo(pb) : pb.compareTo(pa);
    }

    final ta = a.priorityUpdatedAt ?? 0;
    final tb = b.priorityUpdatedAt ?? 0;

    return _sortAscending ? tb.compareTo(ta) : ta.compareTo(tb);
  }

  void _sortTasks() {
    tasks.sort(_taskComparator);
  }

  // ---------- load assignees (cached) ----------
  Future<List<String>> _loadClientsFromFirestore() async {
    if (_clientsCache != null) return _clientsCache!;

    final snap = await FirebaseFirestore.instance.collection('Client').get();

    final values = snap.docs
        .map((d) => d['name']?.toString() ?? '')
        .where((e) => e.isNotEmpty)
        .toList();

    _clientsCache = values;
    return values;
  }

  Future<List<String>> _loadAssigneesFromFirestore() async {
    if (_assigneesCache != null) return _assigneesCache!;

    // adjust the collection name / field name to match your Firestore layout
    final snap = await FirebaseFirestore.instance.collection('Assignee').get();

    final values = snap.docs
        .map((d) {
      final data = d.data();
      final nameField = data['name'];
      if (nameField != null && nameField.toString().isNotEmpty) {
        return nameField.toString();
      }
      return d.id;
    })
        .where((e) => e.isNotEmpty)
        .toList();

    _assigneesCache = values;
    return values;
  }

  // ---------- overlay helpers for add-task sheet ----------
  void _hideFloatingSheet() {
    _floatingSheetOverlay?.remove();
    _floatingSheetOverlay = null;
    _searchController.clear();
    _searchQuery = '';
  }

  // note: made async so we can await loading assignees when needed
  Future<void> _showFloatingSheet(
      BuildContext buttonContext,
      FloatingSheetType type, {
        void Function(String)? onSelected,
        StateSetter? setModalState,
      }) async {
    if (_floatingSheetOverlay != null) {
      _hideFloatingSheet();
    }
    List<String>? workTypes;
    if (type == FloatingSheetType.workType) {
      final snap = await FirebaseFirestore.instance
          .collection('WorkType')
          .get();

      workTypes = snap.docs
          .map((d) => d['workType']?.toString() ?? '')
          .where((e) => e.isNotEmpty)
          .toList();
    }
    List<String>? clients;

    if (type == FloatingSheetType.clientName) {
      clients = await _loadClientsFromFirestore();
    }

    // ✅ ROOT CONTEXT (FIX)
    final BuildContext rootContext = Navigator.of(
      buttonContext,
      rootNavigator: true,
    ).context;

    // If assign type, load assignees (cached)
    List<String>? assignees;
    if (type == FloatingSheetType.assign || type == FloatingSheetType.accompany) {
      assignees = await _loadAssigneesFromFirestore();
    }

    final RenderBox button = buttonContext.findRenderObject() as RenderBox;
    final RenderBox overlay =
    Overlay.of(buttonContext).context.findRenderObject() as RenderBox;

    final Offset buttonPosition = button.localToGlobal(
      Offset.zero,
      ancestor: overlay,
    );
    final Size overlaySize = overlay.size;

    List<Widget> buildOptions() {
      switch (type) {
        case FloatingSheetType.priority:
          return const [
            ListTile(leading: Icon(Icons.flag), title: Text("U1")),
            ListTile(leading: Icon(Icons.flag), title: Text("U2")),
            ListTile(leading: Icon(Icons.flag_rounded), title: Text("U3")),
            ListTile(leading: Icon(Icons.flag_rounded), title: Text("Urgent")),
            ListTile(leading: Icon(Icons.flag_rounded), title: Text("IMP")),
            ListTile(leading: Icon(Icons.flag_rounded), title: Text("Today")),
            ListTile(
              leading: Icon(Icons.flag_rounded),
              title: Text("Tomorrow"),
            ),
            ListTile(
              leading: Icon(Icons.flag_rounded),
              title: Text("Day Later"),
            ),
            ListTile(leading: Icon(Icons.flag_rounded), title: Text("Later")),
            ListTile(leading: Icon(Icons.flag_rounded), title: Text("Process")),
            ListTile(leading: Icon(Icons.flag_rounded), title: Text("Hold")),
            ListTile(leading: Icon(Icons.flag_rounded), title: Text("Free")),
          ];

        case FloatingSheetType.remind:
        case FloatingSheetType.deadline:
          return const [
            ListTile(
              leading: Icon(Icons.access_time),
              title: Text("Today (1 hour)"),
            ),
            ListTile(leading: Icon(Icons.today), title: Text("Today (3 hour)")),
            ListTile(
              leading: Icon(Icons.calendar_today),
              title: Text("Today (6 hour)"),
            ),
            ListTile(
              leading: Icon(Icons.calendar_today),
              title: Text("Tomorrow (12 pm)"),
            ),
            ListTile(
              leading: Icon(Icons.calendar_today),
              title: Text("Custom"),
            ),
          ];

        case FloatingSheetType.assign:
          if (assignees != null && assignees.isNotEmpty) {
            return assignees.map((a) => ListTile(title: Text(a))).toList();
          }
          return const [
            ListTile(leading: Icon(Icons.person), title: Text("Assign to me")),
            ListTile(
              leading: Icon(Icons.group),
              title: Text("Assign to someone else"),
            ),
          ];
        // --- BEGIN NEW ACCOMPANY FIELD ---
        case FloatingSheetType.accompany:
          if (assignees != null && assignees.isNotEmpty) {
            return assignees.map((a) => ListTile(title: Text(a))).toList();
          }
          return const [
            ListTile(leading: Icon(Icons.person), title: Text("None")),
          ];
        // --- END NEW ACCOMPANY FIELD ---
        case FloatingSheetType.workType:
          return (workTypes ?? [])
              .map((w) => ListTile(title: Text(w)))
              .toList();

        case FloatingSheetType.folder:
          return const [
            ListTile(title: Text("Personal")),
            ListTile(title: Text("Office")),
            ListTile(title: Text("Freelance")),
            ListTile(title: Text("Custom")),
          ];
        case FloatingSheetType.clientName:
          if (clients != null && clients.isNotEmpty) {
            return clients.map((c) => ListTile(title: Text(c))).toList();
          }
          return const [ListTile(title: Text("No clients found"))];
      }
    }

    const double menuWidth = 240;
    const double padding = 8;

    final bool hasSearchBar = type == FloatingSheetType.assign ||
        type == FloatingSheetType.accompany ||
        type == FloatingSheetType.workType ||
        type == FloatingSheetType.clientName;

    final double menuHeightEstimate = hasSearchBar ? 280 : 220;

    double left = buttonPosition.dx;
    if (left + menuWidth > overlaySize.width - padding) {
      left = overlaySize.width - menuWidth - padding;
    }
    if (left < padding) left = padding;

    double top = buttonPosition.dy - menuHeightEstimate;
    if (hasSearchBar) {
      if (top < padding) top = padding;
    } else {
      if (top < padding) {
        top = buttonPosition.dy + button.size.height + padding;
      }
    }

    final TextEditingController _searchController = TextEditingController();
    String _searchQuery = '';

    _floatingSheetOverlay = OverlayEntry(
      builder: (_) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: _hideFloatingSheet,
                behavior: HitTestBehavior.translucent,
                child: const SizedBox.shrink(),
              ),
            ),
            Positioned(
              left: left,
              top: top,
              child: Material(
                color: Colors.white,
                elevation: 6,
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: menuWidth,
                  child: StatefulBuilder(
                    builder: (context, setOverlayState) {
                      final bool showSearch = type == FloatingSheetType.assign ||
                          type == FloatingSheetType.accompany ||
                          type == FloatingSheetType.workType ||
                          type == FloatingSheetType.clientName;

                      final allOptions = buildOptions();

                      final filteredOptions = showSearch && _searchQuery.isNotEmpty
                          ? allOptions.where((tile) {
                        if (tile is! ListTile) return true;
                        final text = (tile.title as Text).data ?? '';
                        return text.toLowerCase().contains(_searchQuery.toLowerCase());
                      }).toList()
                          : allOptions;

                      final bool isMultiSelect = type == FloatingSheetType.remind ||
                          type == FloatingSheetType.assign ||
                          type == FloatingSheetType.accompany;

                      List<String> selectedList = [];
                      if (isMultiSelect) {
                        String currentVal = '';
                        if (type == FloatingSheetType.remind) {
                          currentVal = _newTaskReminder ?? '';
                        } else if (type == FloatingSheetType.assign) {
                          currentVal = _newTaskAssignee ?? '';
                        } else if (type == FloatingSheetType.accompany) {
                          currentVal = _newTaskAccompany ?? '';
                        }
                        selectedList = currentVal.split(', ').where((e) => e.isNotEmpty).toList();
                      }

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (showSearch)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
                              child: TextField(
                                controller: _searchController,
                                autofocus: true,
                                decoration: InputDecoration(
                                  hintText: 'Search...',
                                  hintStyle: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade400,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.search,
                                    size: 18,
                                    color: Colors.grey.shade500,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                  isDense: true,
                                  filled: true,
                                  fillColor: Colors.grey.shade100,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                onChanged: (val) {
                                  _searchQuery = val;
                                  setOverlayState(() {});
                                },
                              ),
                            ),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 220),
                            child: filteredOptions.isEmpty
                                ? Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                'No results found',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            )
                                : ListView(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              children: filteredOptions.map((tile) {
                                if (tile is! ListTile) return tile;
                                final label = (tile.title as Text).data ?? '';
                                final isSelected = selectedList.contains(label);

                                return InkWell(
                                  onTap: () async {
                                    if (onSelected == null) {
                                      _hideFloatingSheet();
                                      return;
                                    }

                                    final now = DateTime.now();
                                    final lower = label.toLowerCase();

                                    if (isMultiSelect) {
                                      if (type == FloatingSheetType.remind && lower.contains('custom')) {
                                        _hideFloatingSheet();
                                        final DateTime? computed = await pickDateTimeWithTabs(rootContext);
                                        if (computed != null) {
                                          final iso = computed.toIso8601String();
                                          setState(() {
                                            if (!selectedList.contains(iso)) {
                                              selectedList.add(iso);
                                            }
                                            final val = selectedList.join(', ');
                                            if (type == FloatingSheetType.remind) _newTaskReminder = val;
                                          });
                                          setModalState?.call(() {});
                                        }
                                        return;
                                      }

                                      if (type == FloatingSheetType.accompany && label == 'None') {
                                        setState(() {
                                          selectedList.clear();
                                          _newTaskAccompany = null;
                                        });
                                        setModalState?.call(() {});
                                        setOverlayState(() {});
                                        return;
                                      }

                                      setState(() {
                                        if (isSelected) {
                                          selectedList.remove(label);
                                        } else {
                                          selectedList.add(label);
                                        }
                                        final val = selectedList.isEmpty ? null : selectedList.join(', ');
                                        if (type == FloatingSheetType.remind) {
                                          _newTaskReminder = val;
                                        } else if (type == FloatingSheetType.assign) {
                                          _newTaskAssignee = val;
                                        } else if (type == FloatingSheetType.accompany) {
                                          _newTaskAccompany = val;
                                        }
                                      });
                                      setModalState?.call(() {});
                                      setOverlayState(() {});
                                    } else {
                                      DateTime? computed;
                                      if (type == FloatingSheetType.deadline) {
                                        if (lower.contains('custom')) {
                                          _hideFloatingSheet();
                                          computed = await pickDateTimeWithTabs(rootContext);
                                        } else if (lower.contains('1 hour')) {
                                          computed = now.add(const Duration(hours: 1));
                                        } else if (lower.contains('3 hour')) {
                                          computed = now.add(const Duration(hours: 3));
                                        } else if (lower.contains('6 hour')) {
                                          computed = now.add(const Duration(hours: 6));
                                        } else if (lower.contains('tomorrow')) {
                                          final t = DateTime(now.year, now.month, now.day)
                                              .add(const Duration(days: 1));
                                          computed = DateTime(t.year, t.month, t.day, 12, 0);
                                        }

                                        if (computed != null) {
                                          onSelected(computed.toIso8601String());
                                        }
                                      } else {
                                        onSelected(label);
                                      }
                                      _searchController.clear();
                                      _searchQuery = '';
                                      _hideFloatingSheet();
                                    }
                                  },
                                  child: ListTile(
                                    leading: tile.leading,
                                    title: tile.title,
                                    subtitle: tile.subtitle,
                                    trailing: isMultiSelect
                                        ? Icon(
                                      isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                                      color: isSelected ? Colors.brown : Colors.grey.shade400,
                                    )
                                        : tile.trailing,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          if (isMultiSelect)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.brown,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    _searchQuery = '';
                                    _hideFloatingSheet();
                                  },
                                  child: const Text("Done"),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(buttonContext).insert(_floatingSheetOverlay!);
  }

  // ---------- thin hairline helper ----------
  Widget _thinHairline({
    double indent = 12,
    double endIndent = 12,
    double opacity = 0.06,
  }) {
    final int alpha = (opacity.clamp(0.0, 1.0) * 255).round();
    return Container(
      height: 1,
      margin: EdgeInsets.only(left: indent, right: endIndent),
      color: Colors.grey.withAlpha(alpha),
    );
  }

  // ------------- add task bottom sheet -------------
  void _openAddTaskSheet() {
    _isAddTaskSheetOpen = true;
    _wasKeyboardVisible = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      isDismissible: true,
      enableDrag: !kIsWeb,
      backgroundColor: Colors.white,
      constraints: kIsWeb
          ? BoxConstraints(
        maxHeight:
        MediaQuery.of(context).size.height * 0.85, // Taller on web
      )
          : null,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final viewInsets = MediaQuery.of(sheetContext).viewInsets;
            final screenWidth = MediaQuery.of(sheetContext).size.width;
            final isMobileWeb = kIsWeb && screenWidth < 600;

            // For mobile web, add extra padding to push content above keyboard
            final systemNavBar = MediaQuery.of(sheetContext).padding.bottom;
            final bottomPadding = isMobileWeb
                ? 350.0
                : (kIsWeb ? 16.0 : (16.0 + viewInsets.bottom + systemNavBar));

            return SingleChildScrollView(
              // ✅ KEPT
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: bottomPadding,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[600],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: taskName,
                            focusNode: _focusNode,
                            autofocus:
                            !isMobileWeb, // Don't autofocus on mobile web initially
                            decoration: const InputDecoration(
                              hintText: "Add a task",
                              border: InputBorder.none,
                            ),
                            onSubmitted: (_) async {
                              await _handleAddTaskFromSheet();
                              setModalState(() {});
                            },
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            await _handleAddTaskFromSheet();
                            setModalState(() {});
                          },
                          icon: const Icon(Icons.send, color: Colors.brown),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // ✅ KEPT REORDERABLE FOR MOBILE, CENTERED FOR DESKTOP WEB
                    SizedBox(
                      height: 56,
                      child:
                      (kIsWeb &&
                          screenWidth >= 600) // Desktop web: centered
                          ? Center(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: _buttonOrder.map((type) {
                            return _buildBottomSheetButtonWithState(
                              type,
                              setModalState,
                            );
                          }).toList(),
                        ),
                      )
                          : ScrollConfiguration(
                        // ✅ Mobile (web & native): scrollable & reorderable
                        behavior: ScrollConfiguration.of(sheetContext)
                            .copyWith(
                          dragDevices: {
                            PointerDeviceKind.touch,
                            PointerDeviceKind.mouse,
                            PointerDeviceKind.trackpad,
                          },
                        ),
                        child: ReorderableListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const ClampingScrollPhysics(),
                          buildDefaultDragHandles: false,
                          itemCount: _buttonOrder.length,
                          onReorder: (oldIndex, newIndex) {
                            setState(() {
                              if (newIndex > oldIndex) newIndex -= 1;
                              final item = _buttonOrder.removeAt(
                                oldIndex,
                              );
                              _buttonOrder.insert(newIndex, item);
                            });
                            _saveButtonOrder();
                            setModalState(() {}); // Update modal state
                          },
                          itemBuilder: (context, index) {
                            final type = _buttonOrder[index];
                            return Padding(
                              key: ValueKey(type),
                              padding: const EdgeInsets.only(right: 8),
                              child: ReorderableDelayedDragStartListener(
                                index: index,
                                child: _buildBottomSheetButtonWithState(
                                  type,
                                  setModalState,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      _isAddTaskSheetOpen = false;
      _wasKeyboardVisible = false;
    });
  }

  // ----------------- full-page task detail -----------------
  void _openTaskDetail(Task task) {
    context.push(
      '/task',
      extra: task,  // Just pass the task, not a Map
    );
  }

  void _deleteTask(Task task) async {
    final index = tasks.indexOf(task);
    if (index == -1) return;

    await _deleteTaskFromFirebase(task);

    setState(() {
      tasks.removeAt(index);
    });
  }

  Future<void> _confirmDeleteSelected() async {
    if (_selected.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Delete ${_selected.length} task(s)?'),
          content: const Text(
            'Are you sure you want to delete selected tasks?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      // Copy selected to avoid concurrent modification
      final List<Task> toDelete = _selected.toList();

      for (final t in toDelete) {
        if (t.id != null) {
          try {
            await _deleteTaskFromFirebase(t);
          } catch (_) {
            // ignore per-item delete errors, continue
          }
        }
        // remove from local list if present
        tasks.remove(t);
      }

      setState(() {
        _selected.clear();
        _sortTasks();
      });
    }
  }

  // NEW: prompt to add a substep to a task (shows dialog with input)
  Future<void> _promptAddSubstep(Task task) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Add substep'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Substep title'),
            onSubmitted: (v) => Navigator.of(ctx).pop(v),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    if (result != null && result.trim().isNotEmpty) {
      setState(() {
        task.steps.add(TaskStep(title: result.trim()));
      });
      await _updateTaskInFirebase(task);
      setState(() {
        _sortTasks();
      });
    }
  }

  // --- BEGIN NEW TAB LOGIC ---
  DateTime? _parseCreatedDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    try {
      final parts = dateStr.split('•');
      if (parts.isEmpty) return null;
      final datePart = parts[0].trim();
      final dateParts = datePart.split('/');
      if (dateParts.length < 3) return null;
      final day = int.parse(dateParts[0]);
      final month = int.parse(dateParts[1]);
      final year = int.parse(dateParts[2]);

      int hour = 0;
      int minute = 0;
      if (parts.length > 1) {
        final timePart = parts[1].trim();
        final timeParts = timePart.split(':');
        if (timeParts.length >= 2) {
          hour = int.parse(timeParts[0]);
          minute = int.parse(timeParts[1]);
        }
      }
      return DateTime(year, month, day, hour, minute);
    } catch (e) {
      return null;
    }
  }

  int _getElapsedDays(String? dateStr) {
    final created = _parseCreatedDate(dateStr);
    if (created == null) return 0;
    final diff = DateTime.now().difference(created);
    return diff.inDays;
  }
  // --- END NEW TAB LOGIC ---

  // --- BEGIN NEW MAP SECTIONS UI (TABS & PRIORITIES) ---
  List<Task> _getFilteredTasks() {
    // --- BEGIN NEW TAB LOGIC ---
    final String loginUserId = SessionManager.getEmail() ?? '';
    List<Task> baseTasks;

    if (_activeTab == 'Done Work') {
      // Done Work: Filter to show tasks where status == 'completed' AND task belongs to loginUserId
      baseTasks = tasks.where((t) => t.isDone && (t.createdBy == loginUserId || (t.assignee ?? '').split(', ').contains(loginUserId))).toList();
    } else if (_activeTab == 'My Work') {
      // My Work: Filter to show tasks where createdBy == loginUserId OR assignedTo == loginUserId
      baseTasks = tasks.where((t) => !t.isDone && (t.createdBy == loginUserId || (t.assignee ?? '').split(', ').contains(loginUserId))).toList();
    } else if (_activeTab == 'Work Days') {
      // Work Days: Filter pending tasks that have active scheduled dates (deadline or reminder set)
      baseTasks = tasks.where((t) => !t.isDone && ((t.deadline != null && t.deadline!.isNotEmpty) || (t.reminder != null && t.reminder!.isNotEmpty))).toList();
    } else {
      // All Work: Remove user-specific filters
      baseTasks = tasks.toList();
    }
    // --- END NEW TAB LOGIC ---

    // --- BEGIN DYNAMIC SORT/FILTER LOGIC ---
    if (_selectedPersonFilter != null && _selectedPersonFilter!.isNotEmpty) {
      if (_sortBy == 'Name of the User') {
        baseTasks = baseTasks.where((t) => (t.assignee ?? '').split(', ').contains(_selectedPersonFilter!)).toList();
      } else if (_sortBy == 'Assigned by') {
        baseTasks = baseTasks.where((t) => t.createdBy == _selectedPersonFilter!).toList();
      }
    }
    // --- END DYNAMIC SORT/FILTER LOGIC ---

    return baseTasks;
  }

  Map<String, List<Task>> _groupTasksByPriority(List<Task> filteredTasks) {
    final Map<String, List<Task>> grouped = {};

    for (final task in filteredTasks) {
      final p = task.priority?.trim() ?? '';
      String groupKey = 'No Priority';

      if (p.isEmpty) {
        groupKey = 'No Priority';
      } else if (p.toLowerCase() == 'urgent' || p == 'U1' || p == 'U2' || p == 'U3') {
        groupKey = 'A (Urgent)';
      } else if (p.toLowerCase() == 'overdue') {
        groupKey = 'B (Overdue)';
      } else {
        groupKey = p; // dynamic key for IMP, Hold, Today, etc.
      }

      if (!grouped.containsKey(groupKey)) {
        grouped[groupKey] = [];
      }
      grouped[groupKey]!.add(task);
    }

    return grouped;
  }

  Widget _buildGroupHeader(String title, int count) {
    final isCollapsed = _collapsedPriorities.contains(title);
    return InkWell(
      onTap: () {
        setState(() {
          if (isCollapsed) {
            _collapsedPriorities.remove(title);
          } else {
            _collapsedPriorities.add(title);
          }
        });
      },
      onDoubleTap: () {
        setState(() {
          final allKeys = ['A (Urgent)', 'B (Overdue)', 'IMP', 'Hold', 'Today', 'No Priority'];
          if (_collapsedPriorities.length < allKeys.length) {
            _collapsedPriorities.addAll(allKeys);
          } else {
            _collapsedPriorities.clear();
          }
        });
      },
      child: Container(
        width: double.infinity,
        color: const Color(0xFFF5F5F5),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        margin: const EdgeInsets.only(top: 2, bottom: 2),
        child: Row(
          children: [
            Icon(
              isCollapsed ? Icons.chevron_right : Icons.expand_more,
              color: Colors.grey.shade600,
              size: 20,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF424242),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF616161),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopTabs() {
    final tabs = ["My Work", "Done Work", "All Work", "Work Days"];
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isCentered = screenWidth >= 600;

    final children = tabs.map((tabName) {
      final bool isSelected = _activeTab == tabName;
      return InkWell(
        onTap: () {
          setState(() {
            _activeTab = tabName;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? const Color(0xFF1E88E5) : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Text(
            tabName,
            style: TextStyle(
              color: isSelected ? const Color(0xFF212121) : const Color(0xFF757575),
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 15,
            ),
          ),
        ),
      );
    }).toList();

    return Container(
      height: 48,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
      ),
      child: isCentered
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: children,
            )
          : ListView(
              scrollDirection: Axis.horizontal,
              children: children,
            ),
    );
  }

  // --- BEGIN TASK SORTING HEADER ---
  Widget _buildSortingHeader() {
    final bool showSecondaryDropdown = _sortBy == 'Name of the User' || _sortBy == 'Assigned by';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    "Sort by: ",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Colors.black54,
                    ),
                  ),
                  DropdownButton<String>(
                    value: _sortBy,
                    underline: const SizedBox.shrink(),
                    isDense: true,
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.blue, size: 18),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Priority', child: Text('Priority')),
                      DropdownMenuItem(value: 'Date Created', child: Text('Date Created')),
                      DropdownMenuItem(value: 'Deadline', child: Text('Deadline')),
                      DropdownMenuItem(value: 'Status', child: Text('Status')),
                      DropdownMenuItem(value: 'Name of the User', child: Text('Name of the User')),
                      DropdownMenuItem(value: 'Assigned by', child: Text('Assigned by')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _sortBy = val;
                          // --- BEGIN DYNAMIC SORT/FILTER LOGIC ---
                          if (_sortBy != 'Name of the User' && _sortBy != 'Assigned by') {
                            _selectedPersonFilter = null;
                            _personSearchQuery = '';
                            _isSecondaryDropdownOpen = false;
                          } else {
                            _isSecondaryDropdownOpen = true; // Auto open when selected
                          }
                          // --- END DYNAMIC SORT/FILTER LOGIC ---
                          _sortTasks();
                        });
                      }
                    },
                  ),
                ],
              ),
              IconButton(
                icon: Icon(
                  _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                  color: Colors.blue,
                  size: 18,
                ),
                onPressed: () {
                  setState(() {
                    _sortAscending = !_sortAscending;
                    _sortTasks();
                  });
                },
                tooltip: _sortAscending ? "Sort Ascending" : "Sort Descending",
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
        // --- BEGIN DYNAMIC SORT/FILTER LOGIC ---
        if (showSecondaryDropdown)
          FutureBuilder<List<String>>(
            future: _getSecondaryDropdownUsers(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox.shrink();
              final allUsers = snapshot.data!;
              final filteredUsers = allUsers
                  .where((u) => u.toLowerCase().contains(_personSearchQuery.toLowerCase()))
                  .toList();

              return Container(
                color: Colors.grey.shade50,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _isSecondaryDropdownOpen = !_isSecondaryDropdownOpen;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _selectedPersonFilter ?? "Select a person...",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: _selectedPersonFilter != null ? Colors.black87 : Colors.grey.shade500,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Icon(
                                    _isSecondaryDropdownOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                                    size: 18,
                                    color: Colors.grey.shade600,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (_selectedPersonFilter != null) ...[
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.clear, size: 18, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _selectedPersonFilter = null;
                                _personSearchQuery = '';
                              });
                            },
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                          ),
                        ]
                      ],
                    ),
                    if (_isSecondaryDropdownOpen) ...[
                      const SizedBox(height: 6),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: const BoxConstraints(maxHeight: 180),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: TextField(
                                style: const TextStyle(fontSize: 13),
                                decoration: InputDecoration(
                                  hintText: "Search name...",
                                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                                  prefixIcon: const Icon(Icons.search, size: 16, color: Colors.grey),
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(4),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                ),
                                onChanged: (val) {
                                  setState(() {
                                    _personSearchQuery = val;
                                  });
                                },
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                itemCount: filteredUsers.length,
                                itemBuilder: (context, index) {
                                  final user = filteredUsers[index];
                                  final isSel = _selectedPersonFilter == user;
                                  return InkWell(
                                    onTap: () {
                                      setState(() {
                                        _selectedPersonFilter = user;
                                        _isSecondaryDropdownOpen = false;
                                        _personSearchQuery = '';
                                      });
                                    },
                                    child: Container(
                                      color: isSel ? Colors.blue.withValues(alpha: 0.1) : Colors.transparent,
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      width: double.infinity,
                                      child: Text(
                                        user,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: isSel ? FontWeight.w600 : FontWeight.w400,
                                          color: isSel ? Colors.blue : Colors.black87,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        // --- END DYNAMIC SORT/FILTER LOGIC ---
      ],
    );
  }

  // --- BEGIN DYNAMIC SORT/FILTER LOGIC ---
  Future<List<String>> _getSecondaryDropdownUsers() async {
    final assignees = await _loadAssigneesFromFirestore();
    final creators = tasks
        .map((t) => t.createdBy)
        .where((e) => e != null && e.isNotEmpty)
        .cast<String>()
        .toSet()
        .toList();
    final combined = <String>{...assignees, ...creators}.toList();
    combined.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return combined;
  }
  // --- END DYNAMIC SORT/FILTER LOGIC ---
  // --- END TASK SORTING HEADER ---
  // --- END NEW MAP SECTIONS UI (TABS & PRIORITIES) ---

  Widget _buildTaskTile(Task task, int index) {
    final isSelected = _selected.contains(task);

    // bigger, more breathable section per task
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      child: InkWell(
        onLongPress: () {
          setState(() {
            if (_selected.contains(task)) {
              _selected.remove(task);
            } else {
              _selected.add(task);
            }
          });
        },
        onTap: () async {
          if (_selected.isNotEmpty) {
            // toggle selection when selection mode active
            setState(() {
              if (_selected.contains(task)) {
                _selected.remove(task);
              } else {
                _selected.add(task);
              }
            });
            return;
          }
          // normal behavior: toggle done marker when tapping the left icon,
          // otherwise open detail. We keep the same behavior as before:
          _openTaskDetail(task);
        },
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue.withAlpha(20) : Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () async {
                  // tapping the left icon toggles done even in selection mode
                  setState(() {
                    task.isDone = !task.isDone;
                  });
                  await _updateTaskInFirebase(task);
                  setState(() {
                    _sortTasks();
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 14.0),
                  child: isSelected
                      ? const Icon(
                    Icons.check_circle,
                    size: 28,
                    color: Colors.blue,
                  )
                      : Icon(
                    task.isDone
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    size: 28,
                    color: task.isDone ? Colors.green : Colors.black54,
                  ),
                ),
              ),
              // Title + workType (subtitle)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w400,
                        decoration: task.isDone
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    if (task.workType != null && task.workType!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Text(
                          task.workType!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: task.isDone
                                ? Colors.grey.shade500
                                : Colors.grey.shade700,
                          ),
                        ),
                      ),
                    // --- BEGIN NEW TAB LOGIC ---
                    if (_activeTab == 'Work Days')
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          "${_getElapsedDays(task.createdDate)} work days elapsed",
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.blueGrey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    // --- END NEW TAB LOGIC ---
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // priority tappable badge + plus icon (right side)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Builder(
                        builder: (badgeContext) {
                          final p = task.priority;
                          if (p == null || p.isEmpty) {
                            return GestureDetector(
                              onTap: () {
                                _showFloatingSheet(
                                  badgeContext,
                                  FloatingSheetType.priority,
                                  onSelected: (value) async {
                                    setState(() {
                                      task.priority = value;
                                      task.priorityUpdatedAt =
                                          DateTime.now().millisecondsSinceEpoch;
                                    });
                                    _sortTasks();
                                    await _updateTaskInFirebase(task);
                                  },
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                child: Text(
                                  'None',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            );
                          }

                          return GestureDetector(
                            onTap: () {
                              _showFloatingSheet(
                                badgeContext,
                                FloatingSheetType.priority,
                                onSelected: (value) async {
                                  setState(() {
                                    task.priority = value;
                                    task.priorityUpdatedAt =
                                        DateTime.now().millisecondsSinceEpoch;
                                  });
                                  _sortTasks();
                                  await _updateTaskInFirebase(task);
                                },
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.brown),
                              ),
                              child: Text(
                                p,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.brown,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      // plus icon to add substeps
                      InkWell(
                        onTap: () => _promptAddSubstep(task),
                        borderRadius: BorderRadius.circular(20),
                        child: const Padding(
                          padding: EdgeInsets.all(6.0),
                          child: Icon(
                            Icons.add_circle_outline,
                            size: 24,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // keep a small spacer so the row aligns nicely
                  const SizedBox(height: 2),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- build with Completed-first grouped UI ----------
  @override
  Widget build(BuildContext context) {
    // If multi-select active, show selection appbar
    final bool selectionActive = _selected.isNotEmpty;

    return WillPopScope(
      onWillPop: () async {
        if (_isAddTaskSheetOpen) {
          if (kIsWeb) {
            // WEB: Just close the sheet on any back press
            Navigator.of(context, rootNavigator: true).pop();
            FocusScope.of(context).unfocus();
            return false;
          } else {
            // NATIVE: Two-step keyboard then sheet
            final isKeyboardVisible =
                MediaQuery.of(context).viewInsets.bottom > 0;

            if (isKeyboardVisible) {
              FocusScope.of(context).unfocus();
              return false;
            } else {
              Navigator.of(context, rootNavigator: true).pop();
              return false;
            }
          }
        }
        return true; // Allow normal back navigation
      },
      child: Scaffold(
        drawer: const SidebarMenu(),
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: selectionActive
            ? AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          automaticallyImplyLeading: false,
          iconTheme: const IconThemeData(color: Colors.brown),
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.brown),
            onPressed: () {
              setState(() {
                _selected.clear();
              });
            },
          ),
          title: Text(
            '${_selected.length} selected',
            style: const TextStyle(
              color: Colors.brown,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.redAccent,
              ),
              onPressed: _confirmDeleteSelected,
            ),
            const SizedBox(width: 8),
          ],
        )
            : AppBar(
          backgroundColor: Colors.white,
          elevation: 0, // flat
          centerTitle: false,
          automaticallyImplyLeading: true,
          iconTheme: const IconThemeData(color: Colors.brown),
          title: Text(
            widget.title,
            style: const TextStyle(
              color: Colors.brown,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: Column(
          children: [
            // --- BEGIN NEW MAP SECTIONS UI (TABS & PRIORITIES) ---
            _buildTopTabs(),
            _buildSortingHeader(),
            // --- END NEW MAP SECTIONS UI (TABS & PRIORITIES) ---
            Expanded(
              child: tasks.isEmpty
                  ? const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    "Tasks show up here if they aren't part of any lists you've created.",
                    textAlign: TextAlign.center,
                  ),
                ),
              )
                  : Builder(
                builder: (_) {
                  // --- BEGIN NEW MAP SECTIONS UI (TABS & PRIORITIES) ---
                  const bool useNewTabsAndPriorities = true;
                  final children = <Widget>[];

                  if (useNewTabsAndPriorities) {
                    _sortTasks();
                    final filteredTasks = _getFilteredTasks();
                    final groupedTasks = _groupTasksByPriority(filteredTasks);
                    final keys = groupedTasks.keys.toList();
                    keys.sort((a, b) {
                      if (a == 'A (Urgent)') return -1;
                      if (b == 'A (Urgent)') return 1;
                      if (a == 'B (Overdue)') return -1;
                      if (b == 'B (Overdue)') return 1;
                      if (a == 'No Priority') return 1;
                      if (b == 'No Priority') return -1;
                      return a.compareTo(b);
                    });
                    for (final key in keys) {
                      final groupList = groupedTasks[key] ?? [];
                      if (groupList.isNotEmpty) {
                        children.add(_buildGroupHeader(key, groupList.length));
                        if (!_collapsedPriorities.contains(key)) {
                          for (int i = 0; i < groupList.length; i++) {
                            children.add(_buildTaskTile(groupList[i], i));
                            children.add(
                              _thinHairline(indent: 15, endIndent: 15, opacity: 0.05),
                            );
                          }
                        }
                      }
                    }
                  } else {
                  // --- END NEW MAP SECTIONS UI (TABS & PRIORITIES) ---
                    // ensure tasks are sorted (safeguard)
                    _sortTasks();

                    final completed = tasks.where((t) => t.isDone).toList();
                    final pending = tasks.where((t) => !t.isDone).toList();

                    // pending tasks
                    for (int i = 0; i < pending.length; i++) {
                      children.add(_buildTaskTile(pending[i], i));
                      children.add(
                        _thinHairline(indent: 15, endIndent: 15, opacity: 0.05),
                      );
                    }

                    // separator between sections (very subtle)
                    if (pending.isNotEmpty && completed.isNotEmpty) {
                      children.add(
                        _thinHairline(indent: 0, endIndent: 0, opacity: 0.06),
                      );
                    }

                    // Completed header + items (collapsible)
                    if (completed.isNotEmpty) {
                      children.add(
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 8.0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Completed (${completed.length})",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  _completedCollapsed
                                      ? Icons.expand_more
                                      : Icons.expand_less,
                                  color: Colors.grey.shade700,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _completedCollapsed = !_completedCollapsed;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      );

                      if (!_completedCollapsed) {
                        for (int i = 0; i < completed.length; i++) {
                          children.add(_buildTaskTile(completed[i], i));
                          children.add(
                            _thinHairline(
                              indent: 15,
                              endIndent: 15,
                              opacity: 0.05,
                            ),
                          );
                        }
                        children.add(const SizedBox(height: 8));
                      }
                    }
                  // --- BEGIN NEW MAP SECTIONS UI (TABS & PRIORITIES) ---
                  }
                  // --- END NEW MAP SECTIONS UI (TABS & PRIORITIES) ---

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final isWeb = constraints.maxWidth >= 1024;

                      return Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: isWeb ? 900 : double.infinity,
                          ),
                          child: ListView(
                            padding: EdgeInsets.zero,
                            children: children,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: selectionActive
            ? null
            : FloatingButton(onPressed: _openAddTaskSheet),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}
