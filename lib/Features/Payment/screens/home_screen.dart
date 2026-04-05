import 'dart:async'; // Timer ke liye
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/lead_model.dart';
import '../core/constants.dart';
import 'lead_form_screen.dart';
import 'lead_detail_screen.dart';
import 'payment_screen.dart';
import 'reports_screen.dart';
import 'import_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import 'add_user_screen.dart';
import 'manage_users_screen.dart';
import 'login_screen.dart';

// NEW IMPORTS FOR REQUEST SYSTEM
import 'request_access_screen.dart';
import 'admin_notifications_screen.dart';
import 'admin_alerts_screen.dart';

import 'paid_screen.dart';
import 'map_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CollectionReference _leadsRef = FirebaseFirestore.instance.collection('leads');

  int _currentIndex = 0;
  late PageController _pageController;
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchText = "";

  // --- SELECTION STATE ---
  bool _isSelectionMode = false;
  Set<String> _selectedIds = {};

  // --- SORT & GROUP STATE ---
  String _sortBy = 'Date (Newest)';
  String _groupBy = 'None';

  // --- USER ROLE STATE & PERMISSIONS ---
  String _userRole = 'Employee';
  String _userName = 'User';
  List<dynamic> _allowedTabs = ['Home', 'ToDo', 'Paid', 'Graph'];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);

    // Force Start Timer (Safety)
    Timer(const Duration(seconds: 2), () {
      if (mounted && _isLoading) {
        setState(() {
          _isLoading = false;
        });
        debugPrint("Force stopped loading due to timeout");
      }
    });

    _loadUserDataAndPermissions();
  }

  // --- LOAD PERMISSIONS ---
  void _loadUserDataAndPermissions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('userId');

      if (mounted) {
        setState(() {
          _userRole = prefs.getString('userRole') ?? 'Employee';
          _userName = prefs.getString('userName') ?? 'User';
        });
      }

      if (_userRole == 'Admin') {
        _allowedTabs = ['Home', 'ToDo', 'Paid', 'Graph'];
        if(mounted) setState(() => _isLoading = false);
      } else if (uid != null) {
        FirebaseFirestore.instance.collection('users').doc(uid).get().then((doc) {
          if (doc.exists && mounted) {
            final data = doc.data();
            if (data != null && data.containsKey('visibleTabs')) {
              setState(() {
                _allowedTabs = data['visibleTabs'];
              });
            }
          }
          if (mounted) setState(() => _isLoading = false);
        }).catchError((e) {
          if (mounted) setState(() => _isLoading = false);
        });
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- LOGOUT ---
  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if(mounted) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false
      );
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // --- FILTER & SORT BOTTOM SHEET (UPDATED WITH CLEAR) ---
  void _showFilterBottomSheet() {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (context) {
          return StatefulBuilder(
              builder: (context, setModalState) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- HEADER WITH CLEAR BUTTON ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Sort & Group List", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          TextButton.icon(
                            onPressed: () {
                              // RESET LOGIC
                              setModalState(() {
                                _sortBy = 'Date (Newest)';
                                _groupBy = 'None';
                              });
                              setState(() {}); // Update Main Screen immediately
                            },
                            icon: const Icon(Icons.refresh, size: 18, color: Colors.red),
                            label: const Text("Clear", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                          )
                        ],
                      ),
                      const SizedBox(height: 20),

                      // SORT SECTION
                      const Text("Sort By", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                      Wrap(
                        spacing: 10,
                        children: [
                          _sortChip('Date (Newest)', setModalState),
                          _sortChip('Date (Oldest)', setModalState),
                          _sortChip('Amount (High)', setModalState),
                          _sortChip('Name (A-Z)', setModalState),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // GROUP SECTION
                      const Text("Group By", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                      Wrap(
                        spacing: 10,
                        children: [
                          _groupChip('None', setModalState),
                          _groupChip('Status', setModalState),
                          _groupChip('City', setModalState),
                        ],
                      ),

                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                          child: const Text("APPLY"),
                        ),
                      )
                    ],
                  ),
                );
              }
          );
        }
    );
  }

  Widget _sortChip(String label, StateSetter setModalState) {
    final isSelected = _sortBy == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: const Color(0xFFFDD835),
      onSelected: (bool selected) {
        setModalState(() => _sortBy = label);
        setState(() {}); // Update Main Screen
      },
    );
  }

  Widget _groupChip(String label, StateSetter setModalState) {
    final isSelected = _groupBy == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: Colors.blue[100],
      onSelected: (bool selected) {
        setModalState(() => _groupBy = label);
        setState(() {}); // Update Main Screen
      },
    );
  }

  // --- SELECTION LOGIC ---
  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
        if (_selectedIds.isEmpty) _isSelectionMode = false;
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _selectAll(List<Lead> leads) {
    setState(() {
      if (_selectedIds.length == leads.length) {
        _selectedIds.clear();
        _isSelectionMode = false;
      } else {
        _selectedIds = leads.map((l) => l.id).toSet();
        _isSelectionMode = true;
      }
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _selectedIds.clear();
      _isSelectionMode = false;
    });
  }

  Future<void> _deleteSelected() async {
    final shouldDelete = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Delete Clients?"),
          content: Text("Are you sure you want to delete ${_selectedIds.length} clients?"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Delete", style: TextStyle(color: Colors.red))),
          ],
        )
    );

    if (shouldDelete == true) {
      final batch = FirebaseFirestore.instance.batch();
      for (String id in _selectedIds) {
        batch.delete(_leadsRef.doc(id));
      }
      await batch.commit();
      _exitSelectionMode();
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Deleted successfully')));
    }
  }

  // --- LOGIC FUNCTIONS ---
  void _quickAddPayment(Lead lead) async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (_) => PaymentFormScreen(receiptNo: null, grandTotal: lead.finalAmount, totalPaidSoFar: lead.totalPaid),
      ),
    );

    if (result != null && result['action'] == 'add') {
      final amt = (result['amount'] as num?)?.toDouble() ?? 0.0;
      final paymentEntry = {
        'amount': amt, 'date': result['date'], 'remark': result['remark'], 'receiptNo': result['receiptNo'],
        'gstApplied': result['gstApplied'], 'gstAmount': result['gstAmount'], 'cgst': result['cgst'], 'sgst': result['sgst'],
        'generateBill': result['generateBill'], 'billNo': result['billNo'], 'billDate': result['billDate'],
      };
      final updatedPayments = [paymentEntry, ...lead.payments];
      final newTotalPaid = updatedPayments.fold(0.0, (p, e) => p + (e['amount'] as num).toDouble());
      final newPending = (lead.finalAmount - newTotalPaid).clamp(0.0, double.infinity);
      String newStatus = lead.leadStatus;
      if (newTotalPaid >= lead.finalAmount && lead.finalAmount > 0) newStatus = 'Paid';

      await _leadsRef.doc(lead.id).update({'payments': updatedPayments, 'totalPaid': newTotalPaid, 'pendingAmount': newPending, 'leadStatus': newStatus});
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment Added!')));
    }
  }

  Future<void> _recordCallAndLaunch(Lead lead, String? phone) async {
    final ts = DateTime.now();
    final tsPretty = '${ts.day}/${ts.month}/${ts.year}';
    final updatedLogs = [{'ts': tsPretty, 'via': 'Call'}, ...lead.callLogs];
    await _leadsRef.doc(lead.id).update({'callCount': lead.callCount + 1, 'callLogs': updatedLogs});
    final uri = PhoneHelper.telUri(phone);
    if (uri != null && await canLaunchUrl(uri)) await launchUrl(uri);
  }

  void _openDetail(Lead lead) {
    if (_isSelectionMode) {
      _toggleSelection(lead.id);
    } else {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => LeadDetailScreen(lead: lead)));
    }
  }

  void _openFilteredList(String status, List<Lead> allLeads) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => FilteredListScreen(status: status, leads: allLeads, onOpenDetail: _openDetail)));
  }

  // --- DYNAMIC TABS BUILDER ---
  List<NavigationDestination> _buildNavDestinations() {
    List<NavigationDestination> items = [];
    if (_allowedTabs.contains('Home') || _allowedTabs.isEmpty) items.add(const NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home, color: Colors.black), label: 'Home'));
    if (_allowedTabs.contains('ToDo')) items.add(const NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map, color: Colors.black), label: 'To-Do'));
    if (_allowedTabs.contains('Paid')) items.add(const NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), selectedIcon: Icon(Icons.account_balance_wallet, color: Colors.black), label: 'Paid'));
    if (_allowedTabs.contains('Graph')) items.add(const NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart, color: Colors.black), label: 'Graph'));

    if (items.length < 2) {
      items = [
        const NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home, color: Colors.black), label: 'Home'),
        const NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), selectedIcon: Icon(Icons.account_balance_wallet, color: Colors.black), label: 'Paid'),
      ];
    }
    return items;
  }

  // --- GENERATE PAGES FOR PAGEVIEW ---
  List<Widget> _buildPageViewChildren() {
    List<Widget> pages = [];
    if (_allowedTabs.contains('Home') || _allowedTabs.isEmpty) pages.add(_buildHomeTab());
    if (_allowedTabs.contains('Paid')) pages.add(const PaidScreen());
    if (_allowedTabs.contains('Graph')) pages.add(const ReportsScreen());

    if (pages.length < 2) {
      pages = [_buildHomeTab(), const PaidScreen()];
    }
    return pages;
  }

  // --- MAIN BUILD ---
  @override
  Widget build(BuildContext context) {
    final navDestinations = _buildNavDestinations();
    final pageChildren = _buildPageViewChildren();

    String currentTabName = 'Home';
    if (_allowedTabs.isNotEmpty && _currentIndex < _allowedTabs.length) {
      currentTabName = _allowedTabs[_currentIndex];
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],

      appBar: _buildAppBar(currentTabName),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Colors.black),
              accountName: Text(_userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              accountEmail: Text("Role: $_userRole", style: const TextStyle(color: Colors.white70)),
              currentAccountPicture: CircleAvatar(
                backgroundColor: const Color(0xFFFDD835),
                child: Text(_userName.isNotEmpty ? _userName[0].toUpperCase() : "U", style: const TextStyle(fontSize: 30, color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),

            ListTile(leading: const Icon(Icons.upload_file, color: Colors.purple), title: const Text('Import Data (CSV)'), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const ImportScreen())); }),
            ListTile(leading: const Icon(Icons.settings), title: const Text('Company Settings'), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())); }),

            if (_userRole == 'Admin') ...[
              const Divider(),
              const Padding(padding: EdgeInsets.only(left: 16, top: 10), child: Text("ADMIN CONTROLS", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold))),
              ListTile(leading: const Icon(Icons.notifications_active, color: Colors.orange), title: const Text('Access Requests', style: TextStyle(fontWeight: FontWeight.bold)), trailing: const CircleAvatar(radius: 4, backgroundColor: Colors.red), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminNotificationsScreen())); }),
              ListTile(leading: const Icon(Icons.notifications_active, color: Colors.red), title: const Text('Live Alerts & Payments', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminAlertsScreen())); }),
              ListTile(leading: const Icon(Icons.admin_panel_settings, color: Colors.blue), title: const Text('Manage Users'), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageUsersScreen())); }),
            ],

            if (_userRole != 'Admin') ...[
              const Divider(),
              ListTile(leading: const Icon(Icons.lock_open, color: Colors.green), title: const Text('Request Access'), subtitle: const Text("Ask for features/columns"), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const RequestAccessScreen())); }),
            ],

            const Divider(),
            ListTile(leading: const Icon(Icons.logout, color: Colors.red), title: const Text('Logout', style: TextStyle(color: Colors.red)), onTap: _logout),
          ],
        ),
      ),

      bottomNavigationBar: (!_isSelectionMode && !_isLoading && navDestinations.length >= 2)
          ? NavigationBarTheme(
        data: NavigationBarThemeData(indicatorColor: const Color(0xFFFDD835), labelTextStyle: MaterialStateProperty.all(const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
        child: NavigationBar(
          selectedIndex: _currentIndex >= navDestinations.length ? 0 : _currentIndex, // Safety Check
          onDestinationSelected: (index) {
            setState(() => _currentIndex = index);
            _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
          },
          backgroundColor: Colors.white,
          elevation: 0,
          destinations: navDestinations,
        ),
      )
          : null,

      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : PageView(
          controller: _pageController,
          onPageChanged: (index) => setState(() => _currentIndex = index),
          children: pageChildren,
        ),
      ),

      floatingActionButton: (currentTabName == 'Home' && !_isSelectionMode)
          ? FloatingActionButton(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LeadFormScreen())),
        backgroundColor: const Color(0xFFFDD835),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.black, size: 30),
      )
          : null,
    );
  }

  PreferredSizeWidget? _buildAppBar(String currentTabName) {
    if (_isSelectionMode) {
      return AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(icon: const Icon(Icons.close, color: Colors.black), onPressed: _exitSelectionMode),
        title: Text("${_selectedIds.length} Selected", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: _deleteSelected)],
      );
    }

    if (currentTabName == 'ToDo') return AppBar(title: const Text("To-Do List"), centerTitle: true);
    if (currentTabName == 'Paid') return AppBar(title: const Text("Paid Clients"), centerTitle: true);

    return null;
  }

  // --- HOME TAB ---
  Widget _buildHomeTab() {
    return Column(
      children: [
        Container(
          color: Colors.grey[50],
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
          child: Column(
            children: [
              if (!_isSelectionMode)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      Builder(builder: (context) => IconButton(onPressed: () => Scaffold.of(context).openDrawer(), icon: const Icon(Icons.menu, size: 28))),
                      const SizedBox(width: 8),
                      const Text("Dashboard", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))
                    ]),
                    Row(children: [
                      IconButton(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HistoryScreen())), icon: const Icon(Icons.notifications_none, size: 28)),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          showDialog(context: context, builder: (_) => AlertDialog(
                            title: Row(children: [const Icon(Icons.person, color: Colors.blue), const SizedBox(width: 10), Text(_userName)]),
                            content: Text("Role: $_userRole\n\nLogged in as: $_userName"),
                            actions: [TextButton(onPressed: ()=>Navigator.pop(context), child: const Text("OK"))],
                          ));
                        },
                        child: const CircleAvatar(radius: 18, backgroundColor: Colors.black, child: Icon(Icons.person, color: Colors.white, size: 20)),
                      ),
                    ]),
                  ],
                ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (val) => setState(() => _searchText = val),
                  decoration: InputDecoration(
                    hintText: 'Search for..',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: InkWell(
                      onTap: _showFilterBottomSheet,
                      child: Container(margin: const EdgeInsets.all(6), decoration: BoxDecoration(color: const Color(0xFFFDD835), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.tune, color: Colors.black, size: 20)),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _leadsRef.snapshots(), // Load ALL (sort locally)
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

              // 1. DATA
              var allLeads = snapshot.data?.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                data['id'] = doc.id;
                return Lead.fromJson(data);
              }).toList() ?? [];

              // 2. FILTER
              if (_searchText.isNotEmpty) {
                allLeads = allLeads.where((l) {
                  final term = _searchText.toLowerCase();
                  return (l.leadName?.toLowerCase().contains(term) ?? false) ||
                      (l.company?.toLowerCase().contains(term) ?? false) ||
                      (l.whatsapp?.contains(term) ?? false);
                }).toList();
              }

              // 3. SORT
              if (_sortBy == 'Amount (High)') {
                allLeads.sort((a, b) => b.finalAmount.compareTo(a.finalAmount));
              } else if (_sortBy == 'Name (A-Z)') {
                allLeads.sort((a, b) => (a.leadName ?? '').compareTo(b.leadName ?? ''));
              } else if (_sortBy == 'Date (Oldest)') {
                // Reverse list for oldest first (Assuming insertion order)
                allLeads = allLeads.reversed.toList();
              }
              // Date (Newest) is default Firestore insertion order (usually)

              final hotCount = allLeads.where((l) => l.leadStatus == 'Hot').length;
              final paidCount = allLeads.where((l) => l.leadStatus == 'Paid').length;

              return CustomScrollView(
                slivers: [
                  if (_searchText.isEmpty) ...[
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 140,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.only(left: 20),
                          children: [
                            _buildSummaryCard("Hot", hotCount, Colors.orange, "Immediate Follow-up", () => _openFilteredList('Hot', allLeads)),
                            _buildSummaryCard("Paid", paidCount, Colors.blue, "Completed Deals", () => _openFilteredList('Paid', allLeads)),
                            _buildSummaryCard("Total", allLeads.length, Colors.purple, "All Clients", () {}),
                          ],
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 20)),

                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 40,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.only(left: 20),
                          children: [
                            _buildChip("Payments", Colors.red[100]!, Colors.red[800]!, Icons.payments),
                            _buildChip("Upcoming", Colors.blue[100]!, Colors.blue[800]!, Icons.schedule),
                            _buildChip("Completed", Colors.green[100]!, Colors.green[800]!, Icons.check_circle),
                          ],
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 20)),

                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Recent (${_groupBy == 'None' ? 'All' : 'Grouped'})", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            if (_isSelectionMode)
                              TextButton(
                                onPressed: () => _selectAll(allLeads),
                                child: Text(_selectedIds.length == allLeads.length ? "Deselect All" : "Select All"),
                              )
                          ],
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 10)),
                  ],

                  if (allLeads.isEmpty)
                    const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(40), child: Center(child: Text("No clients found"))))

                  // 4. GROUPED LIST LOGIC
                  else if (_groupBy != 'None')
                    ..._buildGroupedList(allLeads)
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate((ctx, i) {
                        return _buildClientRow(allLeads[i]);
                      }, childCount: allLeads.length),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  // --- GROUPING LOGIC ---
  List<Widget> _buildGroupedList(List<Lead> leads) {
    Map<String, List<Lead>> grouped = {};
    for (var lead in leads) {
      String key = 'Unknown';
      if (_groupBy == 'Status') key = lead.leadStatus;
      if (_groupBy == 'City') key = lead.address?.split(',').last.trim() ?? 'Unknown';

      if (!grouped.containsKey(key)) grouped[key] = [];
      grouped[key]!.add(lead);
    }

    List<Widget> slivers = [];
    grouped.forEach((key, groupLeads) {
      slivers.add(
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              color: Colors.grey[200],
              child: Text("$key (${groupLeads.length})", style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          )
      );
      slivers.add(
          SliverList(
            delegate: SliverChildBuilderDelegate((ctx, i) {
              return _buildClientRow(groupLeads[i]);
            }, childCount: groupLeads.length),
          )
      );
    });
    return slivers;
  }

  Widget _buildSummaryCard(String title, int count, Color color, String sub, VoidCallback onTap) {
    return GestureDetector(onTap: onTap, child: Container(width: 170, margin: const EdgeInsets.only(right: 15), padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("$count $title", style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)), const SizedBox(height: 5), Text(sub, style: const TextStyle(color: Colors.white70, fontSize: 12))]), const Text("Tap for Details", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))])));
  }
  Widget _buildChip(String label, Color bg, Color text, IconData icon) {
    return Container(margin: const EdgeInsets.only(right: 10), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)), child: Row(children: [Icon(icon, size: 16, color: text), const SizedBox(width: 5), Text(label, style: TextStyle(color: text, fontWeight: FontWeight.bold, fontSize: 12))]));
  }
  Widget _buildClientRow(Lead lead) {
    final isSelected = _selectedIds.contains(lead.id);
    Color statusBg; Color statusText;
    String status = lead.leadStatus;
    switch (status.toLowerCase()) { case 'hot': statusBg = Colors.red[50]!; statusText = Colors.red; break; case 'paid': statusBg = Colors.green[50]!; statusText = Colors.green; break; case 'cold': statusBg = Colors.blue[50]!; statusText = Colors.blue; break; case 'hold': statusBg = Colors.orange[50]!; statusText = Colors.orange; break; default: statusBg = Colors.grey[100]!; statusText = Colors.grey; }

    return GestureDetector(
      onLongPress: () { if (!_isSelectionMode) setState(() { _isSelectionMode = true; _selectedIds.add(lead.id); }); },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.white, borderRadius: BorderRadius.circular(16), border: isSelected ? Border.all(color: Colors.blue, width: 2) : null, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            key: PageStorageKey(lead.id), tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), childrenPadding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
            leading: isSelected ? const CircleAvatar(backgroundColor: Colors.blue, child: Icon(Icons.check, color: Colors.white)) : CircleAvatar(radius: 24, backgroundColor: Colors.grey[100], child: const Icon(Icons.person_outline, color: Colors.grey)),
            title: Text(lead.leadName ?? "Unknown", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const SizedBox(height: 4), Text(lead.company ?? "No Desc", style: const TextStyle(color: Colors.grey, fontSize: 12)), const SizedBox(height: 6), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(6)), child: Text(status, style: TextStyle(color: statusText, fontSize: 10, fontWeight: FontWeight.bold)))]),
            trailing: _isSelectionMode ? null : Row(mainAxisSize: MainAxisSize.min, children: [InkWell(onTap: () => _recordCallAndLaunch(lead, lead.whatsapp ?? lead.contact2), child: const CircleAvatar(radius: 18, backgroundColor: Color(0xFF42A5F5), child: Icon(Icons.call, color: Colors.white, size: 18))), const SizedBox(width: 8), InkWell(onTap: () async { final uri = PhoneHelper.whatsappUri(lead.whatsapp); if (uri != null && await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication); }, child: const CircleAvatar(radius: 18, backgroundColor: Color(0xFF25D366), child: Icon(Icons.chat, color: Colors.white, size: 18)))]),
            children: [
              const Divider(), const SizedBox(height: 8),
              SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: () => _quickAddPayment(lead), icon: const Icon(Icons.add_card, size: 18), label: const Text("Add Quick Payment"), style: ElevatedButton.styleFrom(backgroundColor: Colors.green[50], foregroundColor: Colors.green[800], elevation: 0))),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("Deal Value", style: TextStyle(color: Colors.grey, fontSize: 12)), Text("₹${lead.finalAmount.toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))]), Column(crossAxisAlignment: CrossAxisAlignment.end, children: [const Text("Pending", style: TextStyle(color: Colors.grey, fontSize: 12)), Text("₹${lead.pendingAmount.toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.redAccent))])]),
              const SizedBox(height: 12),

              if (lead.payments.isNotEmpty) ...[
                const Align(alignment: Alignment.centerLeft, child: Text("Recent Payments:", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey))),
                const SizedBox(height: 5),
                ...lead.payments.take(3).map((p) => Container(
                    margin: const EdgeInsets.only(bottom: 4), padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(6)),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text(p['date'] ?? '-', style: const TextStyle(fontSize: 12)),
                      Text("₹${(p['amount'] as num).toDouble().toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green))
                    ])
                )),
                const SizedBox(height: 12),
              ],

              SizedBox(width: double.infinity, child: OutlinedButton(onPressed: () => _openDetail(lead), style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.blue), foregroundColor: Colors.blue), child: const Text("View Full Profile"))),
            ],
            onExpansionChanged: (val) { if (_isSelectionMode) _toggleSelection(lead.id); },
          ),
        ),
      ),
    );
  }
}

class FilteredListScreen extends StatelessWidget {
  final String status;
  final List<Lead> leads;
  final void Function(Lead) onOpenDetail;
  const FilteredListScreen({super.key, required this.status, required this.leads, required this.onOpenDetail});
  @override
  Widget build(BuildContext context) {
    final items = status == 'All' ? leads : leads.where((l) => l.leadStatus.toLowerCase() == status.toLowerCase()).toList();
    return Scaffold(
      appBar: AppBar(title: Text('$status Leads')),
      body: ListView.separated(padding: const EdgeInsets.all(16), itemCount: items.length, separatorBuilder: (_,__) => const Divider(), itemBuilder: (_, i) { final l = items[i]; return ListTile(leading: const CircleAvatar(child: Icon(Icons.person)), title: Text(l.leadName ?? '(No name)', style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text('${l.company ?? ''}'), trailing: Text(l.leadStatus, style: const TextStyle(fontWeight: FontWeight.bold)), onTap: () => onOpenDetail(l)); }),
    );
  }
}