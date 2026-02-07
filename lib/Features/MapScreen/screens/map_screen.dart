import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lightatech/FormComponents/FLoatingButton.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import '../models/floating_sheet_type.dart';
import 'task_detail_page.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/gestures.dart';


class MapScreen extends StatefulWidget {
  const MapScreen({super.key, required this.title});

  final String title;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController taskName = TextEditingController();

  OverlayEntry? _floatingSheetOverlay;

  final List<Task> tasks = [];

  // selected tasks for multi-select
  final Set<Task> _selected = {};

  // temp selections while creating a new task
  String? _newTaskPriority;
  String? _newTaskReminder;
  String? _newTaskAssignee;
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
    FloatingSheetType.deadline,
    FloatingSheetType.workType,
    FloatingSheetType.folder,
    FloatingSheetType.clientName,
  ];

// Draggable button order
  late List<FloatingSheetType> _buttonOrder = List.from(_defaultOrder);



  // Firestore collection reference
  final CollectionReference tasksCollection =
  FirebaseFirestore.instance.collection('tasks');

  // collapsed/expanded state for completed section
  bool _completedCollapsed = false;

  // cache for assignees (loaded from Firestore)
  List<String>? _assigneesCache;
  List<String>? _clientsCache;


  @override
  void initState() {
    super.initState();

    // 1️⃣ Load saved button order (Priority / Remind / Assign / etc.)
    _loadButtonOrder();

    // 2️⃣ Load tasks AFTER first frame (existing behavior)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTasksFromFirebase();
    });
  }
  Future<void> _saveButtonOrder() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'home_button_order',
      _buttonOrder.map((e) => e.name).toList(),
    );
  }



  @override
  void dispose() {
    _hideFloatingSheet();
    _focusNode.dispose();
    taskName.dispose();
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
          .map((e) => FloatingSheetType.values.firstWhere(
            (v) => v.name == e,
        orElse: () => _defaultOrder.first,
      ))
          .toList();
    });

  }

  Future<DateTime?> pickDateTimeWithTabs(BuildContext context,
      {DateTime? initial}) async {
    DateTime selectedDate = initial ?? DateTime.now();
    TimeOfDay selectedTime =
    TimeOfDay.fromDateTime(initial ?? DateTime.now());

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
                          horizontal: 12, vertical: 8),
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
        onPressed: () => _showFloatingSheet(
          buttonContext,
          type,
          onSelected: onSelected,
        ),
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
      priority: _newTaskPriority,
      reminder: _newTaskReminder,
      assignee: _newTaskAssignee,
      deadline: _newTaskDeadline,
      workType: _newTaskWorkType,
      folder: _newTaskFolder,          //
      clientName: _newTaskClientName,  //
      priorityUpdatedAt: _newTaskPriority != null ? nowMs : null,
    );

    await _addTaskToFirebase(newTask);

    setState(() {
      tasks.add(newTask);
      _sortTasks();

      // reset temporary selections for the next task
      _newTaskPriority = null;
      _newTaskReminder = null;
      _newTaskAssignee = null;
      _newTaskDeadline = null;
      _newTaskWorkType = null;
    });

    // KEEP THE BOTTOM SHEET OPEN: clear input and re-request focus
    taskName.clear();
    await Future.delayed(const Duration(milliseconds: 80));
    _focusNode.requestFocus();
    _newTaskFolder = null;
    _newTaskClientName = null;

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

  // NEW: comparator puts completed tasks first, then priority, then priorityUpdatedAt
  int _taskComparator(Task a, Task b) {
    // Completed (isDone == true) come first
    if (a.isDone != b.isDone) {
      return a.isDone ? -1 : 1;
    }

    final pa = _priorityOrder(a.priority);
    final pb = _priorityOrder(b.priority);

    if (pa != pb) {
      return pa.compareTo(pb); // smaller = higher priority
    }

    final ta = a.priorityUpdatedAt ?? 0;
    final tb = b.priorityUpdatedAt ?? 0;

    // latest updated priority first
    return tb.compareTo(ta);
  }

  void _sortTasks() {
    tasks.sort(_taskComparator);
  }

  // ---------- load assignees (cached) ----------
  Future<List<String>> _loadClientsFromFirestore() async {
    if (_clientsCache != null) return _clientsCache!;

    final snap =
    await FirebaseFirestore.instance.collection('Client').get();

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
  }

  // note: made async so we can await loading assignees when needed
  Future<void> _showFloatingSheet(
      BuildContext buttonContext,
      FloatingSheetType type, {
        void Function(String)? onSelected,
      }) async {
    if (_floatingSheetOverlay != null) {
      _hideFloatingSheet();
    }
    List<String>? workTypes;
    if (type == FloatingSheetType.workType) {
      final snap =
      await FirebaseFirestore.instance.collection('WorkType').get();

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
    final BuildContext rootContext =
        Navigator.of(buttonContext, rootNavigator: true).context;

    // If assign type, load assignees (cached)
    List<String>? assignees;
    if (type == FloatingSheetType.assign) {
      assignees = await _loadAssigneesFromFirestore();
    }

    final RenderBox button = buttonContext.findRenderObject() as RenderBox;
    final RenderBox overlay =
    Overlay.of(buttonContext).context.findRenderObject() as RenderBox;

    final Offset buttonPosition =
    button.localToGlobal(Offset.zero, ancestor: overlay);
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
            ListTile(leading: Icon(Icons.flag_rounded), title: Text("Tomorrow")),
            ListTile(leading: Icon(Icons.flag_rounded), title: Text("Day Later")),
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
                title: Text("Today (1 hour)")),
            ListTile(
                leading: Icon(Icons.today),
                title: Text("Today (3 hour)")),
            ListTile(
                leading: Icon(Icons.calendar_today),
                title: Text("Today (6 hour)")),
            ListTile(
                leading: Icon(Icons.calendar_today),
                title: Text("Tomorrow (12 pm)")),
            ListTile(
                leading: Icon(Icons.calendar_today),
                title: Text("Custom")),
          ];

        case FloatingSheetType.assign:
          if (assignees != null && assignees.isNotEmpty) {
            return assignees.map((a) => ListTile(title: Text(a))).toList();
          }
          return const [
            ListTile(leading: Icon(Icons.person), title: Text("Assign to me")),
            ListTile(
                leading: Icon(Icons.group),
                title: Text("Assign to someone else")),
          ];
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
          return const [
            ListTile(title: Text("No clients found")),
          ];



      }
    }

    const double menuWidth = 240;
    const double menuHeightEstimate = 220;
    const double padding = 8;

    double left = buttonPosition.dx;
    if (left + menuWidth > overlaySize.width - padding) {
      left = overlaySize.width - menuWidth - padding;
    }
    if (left < padding) left = padding;

    double top = buttonPosition.dy - menuHeightEstimate;
    if (top < padding) {
      top = buttonPosition.dy + button.size.height + padding;
    }

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
                  height: menuHeightEstimate,
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: buildOptions().map((tile) {
                      return InkWell(
                        onTap: () async {
                          if (onSelected == null || tile is! ListTile) {
                            _hideFloatingSheet();
                            return;
                          }

                          final label = (tile.title as Text).data ?? '';
                          final now = DateTime.now();
                          final lower = label.toLowerCase();
                          DateTime? computed;

                          if (type == FloatingSheetType.remind ||
                              type == FloatingSheetType.deadline) {
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
                              computed =
                                  DateTime(t.year, t.month, t.day, 12, 0);
                            }

                            if (computed != null) {
                              onSelected(computed.toIso8601String());
                            }
                          } else {
                            onSelected(label);
                          }

                          _hideFloatingSheet();
                        },
                        child: tile,
                      );
                    }).toList(),
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
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
                // input row
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: taskName,
                        focusNode: _focusNode,
                        autofocus: true,
                        decoration: const InputDecoration(
                          hintText: "Add a task",
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) async {
                          await _handleAddTaskFromSheet();
                        },
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        await _handleAddTaskFromSheet();
                      },
                      icon: const Icon(
                        Icons.send,
                        color: Colors.brown,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),
                SizedBox(
                  height: 56, // slightly taller for web hit-testing
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context).copyWith(
                      dragDevices: {
                        PointerDeviceKind.touch,
                        PointerDeviceKind.mouse,
                        PointerDeviceKind.trackpad,
                      },
                    ),
                    child: ReorderableListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const ClampingScrollPhysics(), // IMPORTANT for web
                      buildDefaultDragHandles: false,
                      itemCount: _buttonOrder.length,
                      onReorder: (oldIndex, newIndex) {
                        setState(() {
                          if (newIndex > oldIndex) newIndex -= 1;
                          final item = _buttonOrder.removeAt(oldIndex);
                          _buttonOrder.insert(newIndex, item);
                        });
                        _saveButtonOrder();
                      },
                      itemBuilder: (context, index) {
                        final type = _buttonOrder[index];
                        return Padding(
                          key: ValueKey(type),
                          padding: const EdgeInsets.only(right: 8),
                          child: ReorderableDelayedDragStartListener(
                            index: index,
                            child: _buildBottomSheetButton(type),
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
  }
  // ----------------- full-page task detail -----------------
  void _openTaskDetail(Task task) {
    context.push(
      '/task',
      extra: task,
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
          content: const Text('Are you sure you want to delete selected tasks?'),
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

  Widget _buildTaskTile(Task task, int index) {
    final isSelected = _selected.contains(task);

    // bigger, more breathable section per task
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
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
                      ? const Icon(Icons.check_circle, size: 28, color: Colors.blue)
                      : Icon(
                    task.isDone ? Icons.check_circle : Icons.radio_button_unchecked,
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
                        fontWeight: FontWeight.w600,
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
                            color:
                            task.isDone ? Colors.grey.shade500 : Colors.grey.shade700,
                          ),
                        ),
                      ),
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
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.shade300),
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
                              padding:
                              const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.brown),
                              ),
                              child: Text(
                                p,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.brown,
                                  fontWeight: FontWeight.w700,
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
                          child:
                          Icon(Icons.add_circle_outline, size: 24, color: Colors.blue),
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

    return Scaffold(
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
          style:
          const TextStyle(color: Colors.brown, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
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
          style:
          const TextStyle(color: Colors.brown, fontWeight: FontWeight.w600),
        ),
      ),
      body: tasks.isEmpty
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
          // ensure tasks are sorted (safeguard)
          _sortTasks();

          final completed = tasks.where((t) => t.isDone).toList();
          final pending = tasks.where((t) => !t.isDone).toList();

          final children = <Widget>[];

          // Completed header + items (collapsible)
          if (completed.isNotEmpty) {
            children.add(
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
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
                        _completedCollapsed ? Icons.expand_more : Icons.expand_less,
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
                children.add(_thinHairline(indent: 15, endIndent: 15, opacity: 0.05));
              }
              children.add(const SizedBox(height: 8));
            }
          }

          // separator between sections (very subtle)
          if (pending.isNotEmpty && completed.isNotEmpty) {
            children.add(_thinHairline(indent: 0, endIndent: 0, opacity: 0.06));
          }

          // pending tasks
          for (int i = 0; i < pending.length; i++) {
            children.add(_buildTaskTile(pending[i], i));
            children.add(_thinHairline(indent: 15, endIndent: 15, opacity: 0.05));
          }

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
                    padding: const EdgeInsets.only(top: 8),
                    children: children,
                  ),
                ),
              );
            },
          );

        },
      ),
      floatingActionButton: selectionActive
          ? null
          : FloatingButton(onPressed: _openAddTaskSheet)
    );
  }
}
