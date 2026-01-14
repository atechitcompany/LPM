// lib/pages/graph_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lightatech/FormComponents/FLoatingButton.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/graph_form.dart' show TaskEntry;

const _storageKey = "task_entries_v1";
const _customChartsKey = "custom_charts_v1";

enum ChartType {
  workSingleBar,
  workCompareBar,
  locationPie,
  statusPie,
  deadlinePie,
}

class GraphTileConfig {
  final ChartType type;
  final bool byEmployee;
  final String? employeeName; // optional
  final List<String>? keys; // up to 3 keys for compare

  GraphTileConfig({
    required this.type,
    this.byEmployee = false,
    this.employeeName,
    this.keys,
  });

  Map<String, dynamic> toJson() => {
    "type": type.index,
    "byEmployee": byEmployee,
    "employeeName": employeeName,
    "keys": keys,
  };

  static GraphTileConfig fromJson(Map<String, dynamic> j) => GraphTileConfig(
    type: ChartType.values[(j["type"] ?? 0) as int],
    byEmployee: j["byEmployee"] ?? false,
    employeeName: j["employeeName"],
    keys: j["keys"] == null ? null : List<String>.from(j["keys"] as List),
  );
}

class GraphPage extends StatefulWidget {
  const GraphPage({super.key});

  @override
  State<GraphPage> createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {
  List<TaskEntry> _entries = [];
  final ScrollController _scrollController = ScrollController();

  bool _employeeMode = false;
  String? _selectedEmployee; // "Name Surname"

  // saved custom charts shown on page:
  final List<GraphTileConfig> _addedCharts = [];

  // colors for up to 3 series
  final List<Color> _seriesColors = [
    Colors.blueAccent,
    Colors.green,
    Colors.orange
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    final list = prefs.getStringList(_storageKey) ?? [];
    final decoded = list.map((e) => TaskEntry.fromJson(json.decode(e))).toList();

    final charts = prefs.getStringList(_customChartsKey) ?? [];
    final decodedCharts =
    charts.map((s) => GraphTileConfig.fromJson(json.decode(s))).toList();

    setState(() {
      _entries = decoded;
      _addedCharts
        ..clear()
        ..addAll(decodedCharts);
    });
  }

  Future<void> _saveCustomCharts() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = _addedCharts.map((c) => json.encode(c.toJson())).toList();
    await prefs.setStringList(_customChartsKey, encoded);
  }

  String _employeeKey(TaskEntry e) {
    final name = e.name.trim();
    final surname = e.surname.trim();
    if (name.isEmpty && surname.isEmpty) return "";
    if (surname.isEmpty) return name;
    return "$name $surname";
  }

  List<String> get _employeeNames {
    final set = <String>{};
    for (final e in _entries) {
      final k = _employeeKey(e);
      if (k.isNotEmpty) set.add(k);
    }
    final list = set.toList()..sort();
    return list;
  }

  List<String> get _workNames {
    final map = <String, int>{};
    for (final e in _entries) {
      final w = e.work.trim();
      if (w.isEmpty) continue;
      map[w] = (map[w] ?? 0) + 1;
    }
    final items =
    map.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return items.map((e) => e.key).toList();
  }

  Map<String, int> _workCounts(List<TaskEntry> list) {
    final map = <String, int>{};
    for (final e in list) {
      final w = e.work.trim();
      if (w.isEmpty) continue;
      map[w] = (map[w] ?? 0) + 1;
    }
    return map;
  }

  Map<String, int> _locationCounts(List<TaskEntry> list) {
    final map = <String, int>{};
    for (final e in list) {
      final loc = e.location.trim().isEmpty ? "Unknown" : e.location.trim();
      map[loc] = (map[loc] ?? 0) + 1;
    }
    return map;
  }

  DateTime _onlyDate(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  List<TaskEntry> _filterEntries({bool byEmployee = false, String? employee}) {
    if (byEmployee && (employee != null && employee.isNotEmpty)) {
      final needle = employee.trim().toLowerCase();
      return _entries
          .where((e) => _employeeKey(e).trim().toLowerCase() == needle)
          .toList();
    }
    return _entries;
  }

  // ---------------- Add Chart dialog ----------------
  Future<void> _openAddChartDialog() async {
    ChartType selectedType = ChartType.workSingleBar;
    bool byEmployee = false;
    String? employee = _employeeNames.isEmpty ? null : _employeeNames.first;
    final availableWorkNames = _workNames;
    final selectedKeys = <String>{};
    final availableLocations = _locationCounts(_entries).keys.toList();
    final selectedLocations = <String>{};

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx2, setStateSB) {
          return AlertDialog(
            title: const Text("Add chart"),
            content: SizedBox(
              width: 360,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<ChartType>(
                      value: selectedType,
                      decoration: const InputDecoration(labelText: "Chart type"),
                      items: const [
                        DropdownMenuItem(
                            value: ChartType.workSingleBar,
                            child: Text("Work (bar)")),
                        DropdownMenuItem(
                            value: ChartType.workCompareBar,
                            child: Text("Work (compare up to 3)")),
                        DropdownMenuItem(
                            value: ChartType.locationPie,
                            child: Text("Location (pie)")),
                        DropdownMenuItem(
                            value: ChartType.statusPie,
                            child: Text("Status (pie)")),
                        DropdownMenuItem(
                            value: ChartType.deadlinePie,
                            child:
                            Text("Deadline performance (pie)")),
                      ],
                      onChanged: (v) =>
                          setStateSB(() => selectedType = v ?? ChartType.workSingleBar),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text("Scope:"),
                        const SizedBox(width: 12),
                        ChoiceChip(
                          label: const Text("Overall"),
                          selected: !byEmployee,
                          onSelected: (s) => setStateSB(() => byEmployee = !s),
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text("By Employee"),
                          selected: byEmployee,
                          onSelected: (s) => setStateSB(() => byEmployee = s),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (byEmployee)
                      DropdownButtonFormField<String>(
                        value: employee,
                        decoration:
                        const InputDecoration(labelText: "Select employee"),
                        items: _employeeNames
                            .map((n) => DropdownMenuItem(value: n, child: Text(n)))
                            .toList(),
                        onChanged: (v) => setStateSB(() => employee = v),
                      ),
                    const SizedBox(height: 12),
                    if (selectedType == ChartType.workCompareBar) ...[
                      Align(
                          alignment: Alignment.centerLeft,
                          child: const Text("Select up to 3 works to compare:")),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: availableWorkNames.map((w) {
                          final sel = selectedKeys.contains(w);
                          return FilterChip(
                            label: Text(w),
                            selected: sel,
                            onSelected: (v) {
                              setStateSB(() {
                                if (v) {
                                  if (selectedKeys.length < 3)
                                    selectedKeys.add(w);
                                  else {
                                    final first = selectedKeys.first;
                                    selectedKeys.remove(first);
                                    selectedKeys.add(w);
                                  }
                                } else {
                                  selectedKeys.remove(w);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (selectedType == ChartType.locationPie) ...[
                      Align(
                          alignment: Alignment.centerLeft,
                          child: const Text(
                              "Pick specific locations (optional, up to 3):")),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        children: availableLocations.map((loc) {
                          final sel = selectedLocations.contains(loc);
                          return FilterChip(
                            label: Text(loc),
                            selected: sel,
                            onSelected: (v) {
                              setStateSB(() {
                                if (v) {
                                  if (selectedLocations.length < 3)
                                    selectedLocations.add(loc);
                                  else {
                                    final first = selectedLocations.first;
                                    selectedLocations.remove(first);
                                    selectedLocations.add(loc);
                                  }
                                } else {
                                  selectedLocations.remove(loc);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (selectedType == ChartType.workSingleBar) ...[
                      const Align(
                          alignment: Alignment.centerLeft,
                          child: Text("This shows top works (default).")),
                    ],
                    if (selectedType == ChartType.deadlinePie) ...[
                      const Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Shows On-time / Late / Overdue Pending")),
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(ctx2).pop(),
                  child: const Text("Cancel")),
              ElevatedButton(
                onPressed: () async {
                  if (byEmployee && (employee?.isEmpty ?? true)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Select an employee")));
                    return;
                  }
                  if (selectedType == ChartType.workCompareBar &&
                      selectedKeys.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Choose at least 1 work to compare")));
                    return;
                  }
                  final cfg = GraphTileConfig(
                    type: selectedType,
                    byEmployee: byEmployee,
                    employeeName: employee,
                    keys: selectedType == ChartType.workCompareBar
                        ? selectedKeys.toList()
                        : (selectedType == ChartType.locationPie &&
                        selectedLocations.isNotEmpty
                        ? selectedLocations.toList()
                        : null),
                  );
                  setState(() {
                    _addedCharts.insert(0, cfg);
                  });
                  await _saveCustomCharts();
                  Navigator.of(ctx2).pop();
                },
                child: const Text("Add chart"),
              ),
            ],
          );
        });
      },
    );
  }

  // ---------------- Build page ----------------
  @override
  Widget build(BuildContext context) {
    final currentEntries = (_employeeMode && _selectedEmployee != null)
        ? _entries.where((e) => _employeeKey(e) == _selectedEmployee).toList()
        : _entries;

    final totalTasks = currentEntries.length;
    final completed = currentEntries.where((e) => e.status == "Done").toList();
    final pending = currentEntries.where((e) => e.status == "Pending").toList();

    final now = DateTime.now();
    final nowDate = _onlyDate(now);

    int onTime = 0, late = 0;
    for (final e in completed) {
      if (e.deadline == null || e.completedAt == null) continue;
      final completedDate = _onlyDate(e.completedAt!);
      final deadlineDate = _onlyDate(e.deadline!);
      if (completedDate.compareTo(deadlineDate) <= 0) onTime++;
      else
        late++;
    }

    int overduePending = 0;
    for (final e in pending) {
      if (e.deadline == null) continue;
      final deadlineDate = _onlyDate(e.deadline!);
      if (deadlineDate.isBefore(nowDate)) overduePending++;
    }

    final workMap = _workCounts(currentEntries);
    final locationMap = _locationCounts(currentEntries);
    final pendingCount = pending.length;
    final doneCount = completed.length;

    return Scaffold(
      appBar: AppBar(title: const Text("Performance Graphs")),
      body: SafeArea(
        child: Scrollbar(
          controller: _scrollController,
          thumbVisibility: true,
          child: ListView(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 92),
            children: [
              // Overall vs By Employee selection
              Row(
                children: [
                  ChoiceChip(
                    label: const Text("Overall"),
                    selected: !_employeeMode,
                    onSelected: (v) {
                      if (v) {
                        setState(() {
                          _employeeMode = false;
                          _selectedEmployee = null;
                        });
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text("By Employee"),
                    selected: _employeeMode,
                    onSelected: (v) {
                      if (v) {
                        setState(() {
                          _employeeMode = true;
                          _selectedEmployee ??=
                          _employeeNames.isNotEmpty ? _employeeNames.first : null;
                        });
                      }
                    },
                  ),
                  const SizedBox(width: 12),
                  if (_employeeMode)
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: _selectedEmployee,
                        decoration: const InputDecoration(
                            labelText: "Select employee",
                            isDense: true,
                            border: OutlineInputBorder()),
                        items: _employeeNames
                            .map((w) => DropdownMenuItem(value: w, child: Text(w)))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedEmployee = v),
                      ),
                    ),
                ],
              ),

              if (_employeeMode && _selectedEmployee != null) ...[
                const SizedBox(height: 8),
                Text("Showing data for: $_selectedEmployee",
                    style: const TextStyle(
                        fontStyle: FontStyle.italic, color: Colors.grey)),
              ],

              const SizedBox(height: 20),

              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _summaryCard(
                      title: "Total tasks",
                      value: totalTasks.toString(),
                      color: Colors.blue),
                  _summaryCard(
                      title: "Completed",
                      value: doneCount.toString(),
                      color: Colors.green),
                  _summaryCard(
                      title: "Pending",
                      value: pendingCount.toString(),
                      color: Colors.orange),
                  _summaryCard(
                      title: "On time",
                      value: onTime.toString(),
                      color: Colors.teal),
                  _summaryCard(
                      title: "Late done",
                      value: late.toString(),
                      color: Colors.redAccent),
                  _summaryCard(
                      title: "Overdue pending",
                      value: overduePending.toString(),
                      color: Colors.deepOrange),
                ],
              ),

              const SizedBox(height: 24),

              // Custom charts from admin
              if (_addedCharts.isNotEmpty) ...[
                const Text("Custom charts",
                    style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ..._addedCharts.map((cfg) {
                  final used =
                  _filterEntries(byEmployee: cfg.byEmployee, employee: cfg.employeeName);
                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Expanded(
                                  child: Text(_chartTitle(cfg),
                                      style:
                                      const TextStyle(fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis)),
                              if (cfg.byEmployee && cfg.employeeName != null)
                                Flexible(
                                    child: Text(cfg.employeeName!,
                                        style: const TextStyle(color: Colors.grey),
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.right)),
                              IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () async {
                                    setState(() => _addedCharts.remove(cfg));
                                    await _saveCustomCharts();
                                  }),
                            ]),
                            const SizedBox(height: 8),
                            if (cfg.keys != null && cfg.keys!.isNotEmpty) ...[
                              Wrap(
                                  spacing: 8,
                                  children: cfg.keys!
                                      .asMap()
                                      .entries
                                      .map((entry) {
                                    final idx = entry.key;
                                    final key = entry.value;
                                    return Chip(
                                        avatar: CircleAvatar(
                                            backgroundColor: _seriesColors[
                                            idx % _seriesColors.length]),
                                        label: Text(key));
                                  }).toList()),
                              const SizedBox(height: 8),
                            ],
                            SizedBox(
                                height: 220,
                                child: _buildChartForConfig(cfg, used)),
                          ]),
                    ),
                  );
                }).toList(),
                const SizedBox(height: 12),
              ],

              // Original charts kept as before
              const Text("Work distribution",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (workMap.isEmpty)
                const Text("No work data yet.")
              else
                SizedBox(height: 260, child: _buildWorkBarChart(workMap)),

              const SizedBox(height: 24),

              const Text("Location distribution (Home vs Office)",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SizedBox(height: 220, child: _buildLocationPie(locationMap)),

              const SizedBox(height: 24),

              const Text("Status (Pending vs Done)",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SizedBox(height: 220, child: _buildStatusPieChart(pendingCount, doneCount)),

              const SizedBox(height: 24),

              const Text("Deadline performance",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SizedBox(
                  height: 220,
                  child: _buildDeadlinePieChart(
                      onTime: onTime, late: late, overduePending: overduePending)),

              const SizedBox(height: 32),

              if (totalTasks == 0)
                const Center(
                    child: Text("No tasks yet. Add entries from the form to see graphs.",
                        style: TextStyle(color: Colors.grey))),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingButton(onPressed: _openAddChartDialog)
    );
  }

  String _chartTitle(GraphTileConfig cfg) {
    final base = switch (cfg.type) {
      ChartType.workSingleBar => "Work distribution",
      ChartType.workCompareBar => "Work comparison",
      ChartType.locationPie => "Location distribution",
      ChartType.statusPie => "Status distribution",
      ChartType.deadlinePie => "Deadline performance",
    };
    if (cfg.byEmployee && (cfg.employeeName?.isNotEmpty ?? false))
      return "$base — ${cfg.employeeName}";
    return base;
  }

  Widget _buildChartForConfig(GraphTileConfig cfg, List<TaskEntry> usedEntries) {
    switch (cfg.type) {
      case ChartType.workSingleBar:
        return _buildWorkBarChart(_workCounts(usedEntries));
      case ChartType.workCompareBar:
        final keys = cfg.keys ?? [];
        if (keys.isEmpty) return const Center(child: Text("No keys selected"));
        return _buildGroupedBarForWorks(usedEntries, keys);
      case ChartType.locationPie:
        final map = _locationCounts(usedEntries);
        if (cfg.keys != null && cfg.keys!.isNotEmpty) {
          final filtered = <String, int>{};
          for (final k in cfg.keys!) {
            if (map.containsKey(k)) filtered[k] = map[k]!;
          }
          return _buildLocationPie(filtered);
        }
        return _buildLocationPie(map);
      case ChartType.statusPie:
        final p = usedEntries.where((e) => e.status == "Pending").length;
        final d = usedEntries.where((e) => e.status == "Done").length;
        return _buildStatusPieChart(p, d);
      case ChartType.deadlinePie:
        int onTime = 0, late = 0, overduePending = 0;
        final done = usedEntries.where((e) => e.status == "Done").toList();
        final pend = usedEntries.where((e) => e.status == "Pending").toList();
        final now = DateTime.now();
        final nowDate = _onlyDate(now);
        for (final e in done) {
          if (e.deadline == null || e.completedAt == null) continue;
          final comp = _onlyDate(e.completedAt!);
          final dl = _onlyDate(e.deadline!);
          if (comp.compareTo(dl) <= 0)
            onTime++;
          else
            late++;
        }
        for (final e in pend) {
          if (e.deadline == null) continue;
          final dl = _onlyDate(e.deadline!);
          if (dl.isBefore(nowDate)) overduePending++;
        }
        return _buildDeadlinePieChart(
            onTime: onTime, late: late, overduePending: overduePending);
    }
  }

  // grouped bar comparing up to 3 selected works across employees
  Widget _buildGroupedBarForWorks(List<TaskEntry> entries, List<String> selectedWorks) {
    final employees = <String>{};
    for (final e in entries) {
      final k = _employeeKey(e);
      if (k.isNotEmpty) employees.add(k);
    }
    final employeeList = employees.toList()..sort();
    if (employeeList.isEmpty) return const Center(child: Text("No employee data"));

    final Map<String, List<int>> counts = {};
    for (final emp in employeeList) counts[emp] = List.filled(selectedWorks.length, 0);

    for (final e in entries) {
      final emp = _employeeKey(e);
      if (!counts.containsKey(emp)) continue;
      final work = e.work.trim();
      final idx = selectedWorks.indexOf(work);
      if (idx >= 0) counts[emp]![idx] = counts[emp]![idx] + 1;
    }

    int maxY = 1;
    for (final v in counts.values) {
      for (final c in v) if (c > maxY) maxY = c;
    }

    final groups = <BarChartGroupData>[];
    for (var i = 0; i < employeeList.length; i++) {
      final emp = employeeList[i];
      final row = counts[emp]!;
      final rods = <BarChartRodData>[];
      for (var s = 0; s < row.length; s++) {
        rods.add(BarChartRodData(
            toY: row[s].toDouble(), width: 8, color: _seriesColors[s % _seriesColors.length]));
      }
      groups.add(BarChartGroupData(x: i, barRods: rods));
    }

    return Column(
      children: [
        SizedBox(
          height: 170,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: BarChart(
              BarChartData(
                barTouchData: BarTouchData(enabled: true),
                groupsSpace: 12,
                maxY: maxY + 1.0,
                barGroups: groups,
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= employeeList.length) return const SizedBox();
                        final name = employeeList[idx];
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            name,
                            style: const TextStyle(fontSize: 10),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(show: true),
                borderData: FlBorderData(show: true),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text("X: Employees — Y: number of tasks. Showing: ${selectedWorks.join(', ')}",
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildWorkBarChart(Map<String, int> data) {
    final entries = data.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final top = entries.take(8).toList();
    if (top.isEmpty) return const Center(child: Text("No work data yet."));

    final maxVal = top.map((e) => e.value).reduce((a, b) => a > b ? a : b).toDouble();
    final groups = <BarChartGroupData>[];

    for (var i = 0; i < top.length; i++) {
      final e = top[i];
      groups.add(BarChartGroupData(x: i, barRods: [
        BarChartRodData(toY: e.value.toDouble(), width: 18, color: Colors.blueAccent),
      ]));
    }

    return BarChart(
      BarChartData(
        barTouchData: BarTouchData(enabled: false),
        maxY: maxVal + 1.0,
        barGroups: groups,
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= top.length) return const SizedBox();
                final label = top[idx].key;
                final short = label.length > 10 ? label.substring(0, 10) + "…" : label;
                return Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(short, style: const TextStyle(fontSize: 10)));
              },
            ),
          ),
        ),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: true),
      ),
    );
  }

  Widget _buildLocationPie(Map<String, int> data) {
    if (data.isEmpty) return const Center(child: Text("No location data yet."));
    final entries = data.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final sections = <PieChartSectionData>[];
    for (var i = 0; i < entries.length; i++) {
      final e = entries[i];
      sections.add(PieChartSectionData(
        value: e.value.toDouble(),
        title: "${e.key}\n${e.value}",
        radius: 55,
        color: i == 0 ? Colors.indigo : Colors.deepPurple,
        titleStyle:
        const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
      ));
    }
    return PieChart(PieChartData(sections: sections, sectionsSpace: 2, centerSpaceRadius: 40));
  }

  Widget _buildStatusPieChart(int pending, int done) {
    final total = pending + done;
    if (total == 0) return const Center(child: Text("No status data yet."));
    final sections = <PieChartSectionData>[];
    if (pending > 0)
      sections.add(PieChartSectionData(
          value: pending.toDouble(),
          color: Colors.orange,
          title: "Pending\n$pending",
          radius: 55,
          titleStyle:
          const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)));
    if (done > 0)
      sections.add(PieChartSectionData(
          value: done.toDouble(),
          color: Colors.green,
          title: "Done\n$done",
          radius: 55,
          titleStyle:
          const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)));
    return PieChart(PieChartData(sections: sections, sectionsSpace: 2, centerSpaceRadius: 40));
  }

  Widget _buildDeadlinePieChart(
      {required int onTime, required int late, required int overduePending}) {
    final total = onTime + late + overduePending;
    if (total == 0) return const Center(child: Text("No deadline/Completion data yet."));
    final sections = <PieChartSectionData>[];
    if (onTime > 0)
      sections.add(PieChartSectionData(
          value: onTime.toDouble(),
          color: Colors.teal,
          title: "On time\n$onTime",
          radius: 55,
          titleStyle:
          const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)));
    if (late > 0)
      sections.add(PieChartSectionData(
          value: late.toDouble(),
          color: Colors.redAccent,
          title: "Late done\n$late",
          radius: 55,
          titleStyle:
          const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)));
    if (overduePending > 0)
      sections.add(PieChartSectionData(
          value: overduePending.toDouble(),
          color: Colors.deepOrange,
          title: "Overdue\n$overduePending",
          radius: 55,
          titleStyle:
          const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)));
    return PieChart(PieChartData(sections: sections, sectionsSpace: 2, centerSpaceRadius: 40));
  }

  Widget _summaryCard(
      {required String title, required String value, required Color color}) {
    return SizedBox(
      width: 165,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          ]),
        ),
      ),
    );
  }
}
