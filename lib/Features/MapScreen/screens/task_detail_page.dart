import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/floating_sheet_type.dart';
import '../../../FormComponents/FileUploadBox.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';


class TaskDetailPage extends StatefulWidget {
  final Task task;
  final VoidCallback onChanged;
  final VoidCallback onDelete;

  const TaskDetailPage({
    super.key,
    required this.task,
    required this.onChanged,
    required this.onDelete,
  });

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  OverlayEntry? _overlayEntry;
  late TextEditingController _noteController;

  // for steps
  late TextEditingController _stepController;
  bool _isAddingStep = false;
  int? _editingStepIndex;

  // for editing main title
  late TextEditingController _titleController;
  bool _isEditingTitle = false;

  Task get task => widget.task;

  // Caches for Firestore-loaded lists
  List<String>? _workTypesCache;
  List<String>? _assigneesCache;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: task.note);
    _stepController = TextEditingController();
    _titleController = TextEditingController(text: task.title);
  }

  @override
  void dispose() {
    _hideOverlay();
    task.note = _noteController.text;
    task.title = _titleController.text;
    _noteController.dispose();
    _stepController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  Future<List<String>> _loadWorkTypesFromFirestore() async {
    if (_workTypesCache != null) return _workTypesCache!;

    final snap = await FirebaseFirestore.instance.collection('WorkType').get();

    final values = snap.docs
        .map((d) => (d.data()['workType'] ?? '').toString())
        .where((e) => e.isNotEmpty)
        .toList();

    _workTypesCache = values;
    return values;
  }

  Future<List<String>> _loadAssigneesFromFirestore() async {
    if (_assigneesCache != null) return _assigneesCache!;

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

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  /// Helper: show date picker then time picker and return combined DateTime (or null if cancelled)
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
                    // ---------- DATE | TIME TABS ----------
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

                    // ---------- CONTENT ----------
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

                    // ---------- ACTIONS ----------
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



  Future<void> _showOverlay(
      BuildContext buttonContext,
      FloatingSheetType type, {
        String? fieldKey,
      }) async {
    if (_overlayEntry != null) {
      _hideOverlay();
    }

    // resolve key same as before (no default)
    String resolvedKey;
    if (fieldKey != null) {
      resolvedKey = fieldKey;
    } else {
      switch (type) {
        case FloatingSheetType.priority:
          resolvedKey = 'priority';
          break;
        case FloatingSheetType.remind:
          resolvedKey = 'reminder';
          break;
        case FloatingSheetType.assign:
          resolvedKey = 'assignee';
          break;
        case FloatingSheetType.deadline:
          resolvedKey = 'deadline';
          break;
        case FloatingSheetType.workType:
          resolvedKey = 'workType';
          break;
        case FloatingSheetType.folder:
          // TODO: Handle this case.
          throw UnimplementedError();
        case FloatingSheetType.clientName:
          // TODO: Handle this case.
          throw UnimplementedError();
      }
    }

    // If workType or assignee, load values from Firestore (async)
    List<String>? workTypes;
    List<String>? assignees;
    if (resolvedKey == 'workType') {
      workTypes = await _loadWorkTypesFromFirestore();
    } else if (resolvedKey == 'assignee') {
      assignees = await _loadAssigneesFromFirestore();
    }

    final OverlayState overlayState = Overlay.of(buttonContext);
    final RenderBox button = buttonContext.findRenderObject() as RenderBox;
    final RenderBox overlayBox = overlayState.context.findRenderObject() as RenderBox;

    final Offset buttonPosition = button.localToGlobal(Offset.zero, ancestor: overlayBox);
    final Size buttonSize = button.size;
    final Size overlaySize = overlayBox.size;

    List<Widget> tilesFor(String key) {
      switch (key) {
        case 'priority':
          return const [
            ListTile(title: Text("U1")),
            ListTile(title: Text("U2")),
            ListTile(title: Text("U3")),
            ListTile(title: Text("Urgent")),
            ListTile(title: Text("IMP")),
            ListTile(title: Text("Today")),
            ListTile(title: Text("Tomorrow")),
            ListTile(title: Text("Day Later")),
            ListTile(title: Text("Later")),
            ListTile(title: Text("Process")),
            ListTile(title: Text("Hold")),
            ListTile(title: Text("Free")),
          ];
        case 'reminder':
          return const [
            ListTile(leading: Icon(Icons.access_time), title: Text("Today (1 hour)")),
            ListTile(leading: Icon(Icons.access_time), title: Text("Today (3 hour)")),
            ListTile(leading: Icon(Icons.access_time), title: Text("Today (6 hour)")),
            ListTile(leading: Icon(Icons.access_time), title: Text("Tomorrow (12 pm)")),
            ListTile(leading: Icon(Icons.calendar_month), title: Text("Custom")),
          ];
        case 'assignee':
          if (assignees == null || assignees.isEmpty) {
            return const [
              ListTile(leading: Icon(Icons.person), title: Text("Assign to me")),
              ListTile(leading: Icon(Icons.group), title: Text("Assign to someone else")),
            ];
          }
          return assignees.map((v) => ListTile(title: Text(v))).toList();
        case 'deadline':
          return const [
            ListTile(leading: Icon(Icons.access_time), title: Text("Today (1 hour)")),
            ListTile(leading: Icon(Icons.access_time), title: Text("Today (3 hour)")),
            ListTile(leading: Icon(Icons.access_time), title: Text("Today (6 hour)")),
            ListTile(leading: Icon(Icons.access_time), title: Text("Tomorrow (12 pm)")),
            ListTile(leading: Icon(Icons.calendar_month), title: Text("Custom")),
          ];
        case 'workType':
          return (workTypes ?? []).map((v) => ListTile(title: Text(v))).toList();
        default:
          return [];
      }
    }

    final tileWidgets = tilesFor(resolvedKey);

    // Positioning
    const double menuWidth = 260;
    const double menuHeightEstimate = 220;
    const double padding = 8;

    double left = buttonPosition.dx;
    if (left + menuWidth > overlaySize.width - padding) {
      left = overlaySize.width - menuWidth - padding;
    }
    if (left < padding) left = padding;

    double topBelow = buttonPosition.dy + buttonSize.height + padding;
    double topAbove = buttonPosition.dy - menuHeightEstimate - padding;
    double top;
    if (topBelow + menuHeightEstimate <= overlaySize.height - padding) {
      top = topBelow;
    } else if (topAbove >= padding) {
      top = topAbove;
    } else {
      top = (overlaySize.height - menuHeightEstimate - padding)
          .clamp(padding, overlaySize.height - menuHeightEstimate - padding);
    }

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: _hideOverlay,
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
                    children: tileWidgets.map((tile) {
                      return InkWell(
                        onTap: () async {
                          if (tile is ListTile) {
                            final label = (tile.title as Text).data ?? '';

                            // handle reminder/deadline specially: want to store concrete datetime (ISO)
                            if (resolvedKey == 'reminder' || resolvedKey == 'deadline') {
                              DateTime? computed;

                              // If 'Custom' => hide overlay first then open pickers
                              if (label.toLowerCase().contains('custom')) {
                                // hide list immediately so picker appears without the list behind
                                _hideOverlay();

                                computed = await pickDateTimeWithTabs(context);

                              } else {
                                // Preset options: compute concrete DateTime
                                final now = DateTime.now();
                                final lower = label.toLowerCase();
                                if (lower.contains('today (1 hour)')) {
                                  computed = now.add(const Duration(hours: 1));
                                } else if (lower.contains('today (3 hour)')) {
                                  computed = now.add(const Duration(hours: 3));
                                } else if (lower.contains('today (6 hour)')) {
                                  computed = now.add(const Duration(hours: 6));
                                } else if (lower.contains('tomorrow (12 pm)')) {
                                  final tomorrow =
                                  DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
                                  computed = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 12, 0);
                                } else {
                                  // fallback - shouldn't usually happen
                                  computed = null;
                                }
                              }

                              if (computed != null) {
                                final iso = computed.toIso8601String();
                                setState(() {
                                  if (resolvedKey == 'reminder') {
                                    task.reminder = iso;
                                  } else {
                                    task.deadline = iso;
                                  }
                                });
                                widget.onChanged();
                              } else {
                                // fallback: store label text
                                setState(() {
                                  if (resolvedKey == 'reminder') {
                                    task.reminder = label;
                                  } else {
                                    task.deadline = label;
                                  }
                                });
                                widget.onChanged();
                                // ensure overlay hidden
                                _hideOverlay();
                              }
                            } else {
                              // Non-date fields (priority, assignee, workType etc.)
                              setState(() {
                                switch (resolvedKey) {
                                  case 'priority':
                                    task.priority = label;
                                    task.priorityUpdatedAt = DateTime.now().millisecondsSinceEpoch;
                                    break;
                                  case 'assignee':
                                    task.assignee = label;
                                    break;
                                  case 'workType':
                                    task.workType = label;
                                    break;
                                  default:
                                    break;
                                }
                              });
                              widget.onChanged();
                              _hideOverlay();
                            }
                          } else {
                            _hideOverlay();
                          }
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

    // Insert overlay now
    overlayState.insert(_overlayEntry!);
  }

  // ---------- title editing ----------
  void _saveTitle(String value) {
    final text = value.trim();
    if (text.isEmpty) return;
    setState(() {
      task.title = text;
      _titleController.text = text;
      _isEditingTitle = false;
    });
    widget.onChanged(); // pushes to Firebase
  }

  // ---------- steps logic ----------
  void _saveStep(String value) {
    final text = value.trim();
    if (text.isEmpty) return;

    setState(() {
      task.steps.add(TaskStep(title: text));
      _isAddingStep = false;
      _stepController.clear();
    });
    widget.onChanged();
  }

  void _startEditStep(int index) {
    setState(() {
      _editingStepIndex = index;
      _isAddingStep = false;
      _stepController.text = task.steps[index].title;
    });
  }

  void _saveEditedStep(int index, String value) {
    final text = value.trim();
    if (text.isEmpty) return;

    setState(() {
      task.steps[index].title = text;
      _editingStepIndex = null;
      _stepController.clear();
    });
    widget.onChanged();
  }

  Future<void> _confirmDeleteStep(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Delete step'),
          content: const Text('Are you sure you want to delete this sub-step?'),
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
      setState(() {
        if (index >= 0 && index < task.steps.length) {
          task.steps.removeAt(index);
        }
      });
      widget.onChanged();
    }
  }

  Widget _buildStepTile(TaskStep step, int index) {
    final isEditing = _editingStepIndex == index;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                step.isDone = !step.isDone;
              });
              widget.onChanged();
            },
            child: Icon(
              step.isDone ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 22,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: isEditing
                ? TextField(
              controller: _stepController,
              autofocus: true,
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
              ),
              onSubmitted: (val) => _saveEditedStep(index, val),
            )
                : GestureDetector(
              onTap: () => _startEditStep(index),
              child: Text(
                step.title,
                style: TextStyle(
                  fontSize: 15,
                  decoration: step.isDone ? TextDecoration.lineThrough : TextDecoration.none,
                ),
              ),
            ),
          ),
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: () {
                setState(() {
                  _editingStepIndex = null;
                  _stepController.clear();
                });
              },
            )
          else
          // show delete icon when not editing
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
              onPressed: () => _confirmDeleteStep(index),
              tooltip: 'Delete sub-step',
            ),
        ],
      ),
    );
  }

  // ---------- generic UI helpers ----------
  Widget _borderedTile({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: child,
    );
  }

  Widget _infoTrailing(String? value) {
    if (value == null || value.isEmpty) {
      return Text(
        "None",
        style: TextStyle(
          color: Colors.grey.shade500,
          fontSize: 13,
        ),
      );
    }

    // if looks like ISO datetime, show a friendly formatted string
    try {
      final dt = DateTime.parse(value);
      final formatted = "${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
      return Text(
        formatted,
        style: const TextStyle(
          color: Colors.brown,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      );
    } catch (_) {
      // not an ISO string - show as-is
      return Text(
        value,
        style: const TextStyle(
          color: Colors.brown,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      );
    }
  }

  bool _isSelected(String? value) => value != null && value.isNotEmpty;

  Widget _priorityBadgeHeader() {
    final p = task.priority;
    if (p == null || p.isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.brown),
      ),
      child: Text(
        p,
        style: const TextStyle(
          fontSize: 13,
          color: Colors.brown,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Task"),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWeb = constraints.maxWidth >= 1024;

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isWeb ? 900 : double.infinity,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  children: [
                    // ---------- main title row ----------
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              task.isDone = !task.isDone;
                            });
                            widget.onChanged();
                          },
                          child: Icon(
                            task.isDone
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _isEditingTitle
                              ? TextField(
                            controller: _titleController,
                            autofocus: true,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                            ),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                            onSubmitted: _saveTitle,
                          )
                              : GestureDetector(
                            onTap: () {
                              setState(() {
                                _isEditingTitle = true;
                                _titleController.text = task.title;
                              });
                            },
                            child: Text(
                              task.title,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                decoration: task.isDone
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            ),
                          ),
                        ),
                        _priorityBadgeHeader(),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // ---------- steps ----------
                    if (task.steps.isNotEmpty)
                      ...task.steps
                          .asMap()
                          .entries
                          .map((e) => _buildStepTile(e.value, e.key)),

                    if (_isAddingStep)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            const Icon(Icons.radio_button_unchecked, size: 22),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _stepController,
                                autofocus: true,
                                decoration: const InputDecoration(
                                  hintText: "Add step",
                                  border: InputBorder.none,
                                ),
                                onSubmitted: _saveStep,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: () {
                                setState(() {
                                  _isAddingStep = false;
                                  _stepController.clear();
                                });
                              },
                            ),
                          ],
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _editingStepIndex = null;
                            _isAddingStep = true;
                            _stepController.clear();
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: const [
                              Icon(Icons.add, color: Colors.blue, size: 20),
                              SizedBox(width: 8),
                              Text(
                                "Add step",
                                style: TextStyle(color: Colors.blue, fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 8),

                    // ---------- Priority / Remind / Assign / Deadline / Work Type ----------
                    Builder(
                      builder: (buttonContext) => _borderedTile(
                        child: ListTile(
                          leading:
                          const Icon(Icons.flag_sharp, color: Colors.brown),
                          title: const Text("Priority"),
                          trailing: _infoTrailing(task.priority),
                          selected: _isSelected(task.priority),
                          onTap: () => _showOverlay(
                            buttonContext,
                            FloatingSheetType.priority,
                          ),
                        ),
                      ),
                    ),
                    Builder(
                      builder: (buttonContext) => _borderedTile(
                        child: ListTile(
                          leading: const Icon(Icons.notifications_active,
                              color: Colors.brown),
                          title: const Text("Remind Me"),
                          trailing: _infoTrailing(task.reminder),
                          selected: _isSelected(task.reminder),
                          onTap: () => _showOverlay(
                            buttonContext,
                            FloatingSheetType.remind,
                          ),
                        ),
                      ),
                    ),
                    Builder(
                      builder: (buttonContext) => _borderedTile(
                        child: ListTile(
                          leading:
                          const Icon(Icons.checklist, color: Colors.brown),
                          title: const Text("Assign"),
                          trailing: _infoTrailing(task.assignee),
                          selected: _isSelected(task.assignee),
                          onTap: () => _showOverlay(
                            buttonContext,
                            FloatingSheetType.assign,
                          ),
                        ),
                      ),
                    ),
                    Builder(
                      builder: (buttonContext) => _borderedTile(
                        child: ListTile(
                          leading: const Icon(Icons.alarm, color: Colors.brown),
                          title: const Text("Deadline"),
                          trailing: _infoTrailing(task.deadline),
                          selected: _isSelected(task.deadline),
                          onTap: () => _showOverlay(
                            buttonContext,
                            FloatingSheetType.deadline,
                          ),
                        ),
                      ),
                    ),
                    Builder(
                      builder: (buttonContext) => _borderedTile(
                        child: ListTile(
                          leading: const Icon(Icons.insert_drive_file,
                              color: Colors.brown),
                          title: const Text("Work Type"),
                          trailing: _infoTrailing(task.workType),
                          selected: _isSelected(task.workType),
                          onTap: () => _showOverlay(
                            buttonContext,
                            FloatingSheetType.deadline,
                            fieldKey: 'workType',
                          ),
                        ),
                      ),
                    ),

                    // ---------- FILES ----------
                    if (task.files.isNotEmpty)
                      Column(
                        children: task.files.asMap().entries.map((entry) {
                          final index = entry.key;
                          final file = entry.value;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.image, color: Colors.blue),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        file.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w500),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "${(file.size / 1024).toStringAsFixed(1)} KB · Image",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, size: 20),
                                  onPressed: () {
                                    setState(() {
                                      task.files.removeAt(index);
                                    });
                                    widget.onChanged();
                                  },
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),

                    // ---------- ADD FILE ----------
                    _borderedTile(
                      child: Padding(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 8.0),
                        child: FileUploadBox(
                          onFileSelected: (PlatformFile file) {
                            setState(() {
                              task.files.add(
                                TaskFile(
                                  name: file.name,
                                  size: file.size,
                                  path: file.path,
                                ),
                              );
                            });
                            widget.onChanged();
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    const Text(
                      "Add note",
                      style:
                      TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _noteController,
                      maxLines: 12,
                      onChanged: (value) {
                        task.note = value;
                        widget.onChanged();
                      },
                      decoration: const InputDecoration(
                        hintText: "Add note",
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // ---------- Created + delete ----------
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Created: ${task.createdDate}",
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 14,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.brown, size: 28),
                          onPressed: () {
                            widget.onDelete();
                            context.pop();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

