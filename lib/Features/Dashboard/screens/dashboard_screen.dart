import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/status_card.dart';
import '../widgets/activity_list.dart';
import '../widgets/add_activity_dialog.dart';
import '../widgets/search_bar.dart';
import '../screens/sidebar_menu.dart';
import '../widgets/dashboard_appbar.dart';
import '../widgets/payment_status.dart';
import 'package:lightatech/FormComponents/FLoatingButton.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}
class WindowsPopupMenu {
  static OverlayEntry show({
    required BuildContext context,
    required Rect position,
    required List<Widget> children,
  }) {
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => Positioned(
        left: position.left,
        top: position.top,
        child: Material(
          elevation: 6,
          borderRadius: BorderRadius.circular(8),
          child: IntrinsicWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(entry);
    return entry;
  }
}

Widget _menuHeader(String text) => Container(
  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  child: Text(
    text,
    style: TextStyle(
      fontSize: 9,
      fontWeight: FontWeight.bold,
      color: Colors.grey,
    ),
  ),
);

Widget _menuItem(String label, IconData icon, VoidCallback onTap) {
  return InkWell(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey[700]),
          SizedBox(width: 8),
          Text(label, style: TextStyle(fontSize: 12)),
        ],
      ),
    ),
  );
}

Widget _submenuItem(String label, IconData icon, VoidCallback onTap) {
  return InkWell(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: Colors.grey[700]),
              SizedBox(width: 8),
              Text(label, style: TextStyle(fontSize: 12)),
            ],
          ),
          Icon(Icons.arrow_right, size: 14, color: Colors.grey[700]),
        ],
      ),
    ),
  );
}

class _DashboardScreenState extends State<DashboardScreen> {


  List<Map<String, String>> allActivities = [];
  List<Map<String, String>> filteredActivities = [];

  String activeFilter = 'All';
  String selectedSortOption = 'Date';

  final nameController = TextEditingController();
  final companyController = TextEditingController();
  final roleController = TextEditingController();
  final searchController = TextEditingController();
  String selectedStatus = 'Hot';
  final GlobalKey _groupByKey = GlobalKey();

  OverlayEntry? _currentMenuEntry;
  OverlayEntry? _currentSubMenuEntry;
  OverlayEntry? _currentBackdropEntry;
  final GlobalKey _filterButtonKey = GlobalKey();


  @override
  void dispose() {
    _closeMenus();
    nameController.dispose();
    companyController.dispose();
    roleController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    filteredActivities = List.from(allActivities);
  }

  void filterActivities(String status) {
    setState(() {
      activeFilter = status;
      List<Map<String, String>> baseList = status == 'All'
          ? allActivities
          : allActivities.where((a) => a['status'] == status).toList();

      String query = searchController.text.toLowerCase();
      if (query.isNotEmpty) {
        filteredActivities = baseList.where((a) =>
        a['name']!.toLowerCase().contains(query) ||
            a['company']!.toLowerCase().contains(query) ||
            a['role']!.toLowerCase().contains(query)).toList();
      } else {
        filteredActivities = baseList;
      }
    });
  }

  void handleSortOption(String value) {
    setState(() {
      selectedSortOption = value;

      if (value == 'Ascending') {
        filteredActivities.sort((a, b) =>
            a['name']!.toLowerCase().compareTo(b['name']!.toLowerCase()));
      } else if (value == 'Descending') {
        filteredActivities.sort((a, b) =>
            b['name']!.toLowerCase().compareTo(a['name']!.toLowerCase()));
      } else {
        // Other sort options like Date, Type, Size can be added
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Applied: $value'), duration: Duration(milliseconds: 500)),
      );
    });
  }


  void addActivity() {
    if (nameController.text.isEmpty ||
        companyController.text.isEmpty ||
        roleController.text.isEmpty) return;

    final newEntry = {
      'name': nameController.text,
      'company': companyController.text,
      'role': roleController.text,
      'status': selectedStatus,
    };

    setState(() {
      allActivities.add(newEntry);
      filterActivities(activeFilter);
    });

    nameController.clear();
    companyController.clear();
    roleController.clear();
    selectedStatus = 'Hot';
    Navigator.pop(context);
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Hot':
        return Colors.orange;
      case 'Paid':
        return Colors.blue;
      case 'Cold':
        return Colors.grey;
      case 'Done':
        return Colors.green;
      default:
        return Colors.black;
    }
  }



  int countStatus(String status) {
    return allActivities.where((a) => a['status'] == status).length;
  }

  // -----------------------------
  // NEW: Group By Popup
  // -----------------------------
  void _showGroupByMenu(BuildContext context) {
    final RenderBox mainBox = context.findRenderObject() as RenderBox;
    final RenderBox itemBox = _groupByKey.currentContext!.findRenderObject() as RenderBox;

    final Offset itemPosition =
    itemBox.localToGlobal(Offset.zero, ancestor: mainBox);

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        itemPosition.dx + itemBox.size.width + 4, // open RIGHT OF the item
        itemPosition.dy - 6,
        0,
        0,
      ),
      items: [
        PopupMenuItem(
          enabled: false,
          height: 30,
          child: Text(
            'GROUP BY',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        PopupMenuItem(
          value: 'Group: Name',
          child: _buildMenuItem('Name', Icons.person),
        ),
        PopupMenuItem(
          value: 'Group: Company',
          child: _buildMenuItem('Company', Icons.business),
        ),
        PopupMenuItem(
          value: 'Group: Status',
          child: _buildMenuItem('Status', Icons.flag),
        ),
      ],
    ).then((value) {
      if (value != null) {
        handleSortOption(value);
      }
    });
  }
  void _openSortMenu(TapDownDetails details) {
    // Close any existing menu before opening a new one
    _closeMenus();

    // Get the filter button position - always use button center, not tap position
    final RenderBox buttonBox = _filterButtonKey.currentContext!.findRenderObject() as RenderBox;
    final Offset buttonPosition = buttonBox.localToGlobal(Offset.zero);
    final double buttonCenterX = buttonPosition.dx + (buttonBox.size.width / 2);
    final double buttonCenterY = buttonPosition.dy + buttonBox.size.height;

    // Add backdrop overlay to close menu when tapping outside
    _currentBackdropEntry = OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: _closeMenus,
        child: Container(
          color: Colors.transparent,
        ),
      ),
    );
    Overlay.of(context).insert(_currentBackdropEntry!);

    _currentMenuEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: buttonCenterX - 80,
        top: buttonCenterY + 8,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: IntrinsicWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _menuHeader("SORT BY"),
                  _menuItem("Date", Icons.calendar_today, () {
                    handleSortOption("Date");
                    _closeMenus();
                  }),
                  _menuItem("Type", Icons.category, () {
                    handleSortOption("Type");
                    _closeMenus();
                  }),
                  _menuItem("Size", Icons.format_size, () {
                    handleSortOption("Size");
                    _closeMenus();
                  }),
                  Divider(height: 1),
                  _menuItem("Ascending", Icons.arrow_upward, () {
                    handleSortOption("Ascending");
                    _closeMenus();
                  }),
                  _menuItem("Descending", Icons.arrow_downward, () {
                    handleSortOption("Descending");
                    _closeMenus();
                  }),
                  Divider(height: 1),
                  _submenuItem("Group By", Icons.group, () {
                    // More accurate calculation with smaller menu heights
                    // Header(20) + Date(30) + Type(30) + Size(30) + Divider(1) + Ascending(30) + Descending(30) + Divider(1) = 172
                    double groupByYPos = buttonCenterY + 8 + 172 - 15;
                    _openGroupBySubMenu(buttonCenterX - 80, groupByYPos);
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_currentMenuEntry!);
  }
  void _openGroupBySubMenu(double mainMenuLeftPosition, double groupByYPos) {
    // Close existing submenu if open
    _currentSubMenuEntry?.remove();

    // Get screen width to check if submenu will fit
    final screenWidth = MediaQuery.of(context).size.width;

    // Position submenu below the Group By option
    double submenuLeft = mainMenuLeftPosition + 110; // Align with main menu
    double submenuTop = groupByYPos+10; // Position below Group By option (~30px height)

    // If submenu would go off screen to the right, adjust left position
    if (submenuLeft + 100 > screenWidth) {
      submenuLeft = screenWidth - 160;
    }

    _currentSubMenuEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: submenuLeft,
        top: submenuTop,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: IntrinsicWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _menuHeader("GROUP BY"),
                  _menuItem("Status", Icons.flag, () {
                    handleSortOption("Group: Status");
                    _closeMenus();
                  }),
                  _menuItem("Company", Icons.business, () {
                    handleSortOption("Group: Company");
                    _closeMenus();
                  }),
                  _menuItem("Priority", Icons.priority_high, () {
                    handleSortOption("Group: Priority");
                    _closeMenus();
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_currentSubMenuEntry!);
  }

  void _closeMenus() {
    _currentBackdropEntry?.remove();
    _currentMenuEntry?.remove();
    _currentSubMenuEntry?.remove();
    _currentBackdropEntry = null;
    _currentMenuEntry = null;
    _currentSubMenuEntry = null;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SidebarMenu(),
      appBar: DashboardAppBar(
        showBack: activeFilter != 'All',
        onBack: () => filterActivities('All'),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.blueGrey.shade50,
            child: Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      SizedBox(width: 12),

                      ShadowWrapper(
                        child: StatusCard(
                          status: 'Hot',
                          count: countStatus('Hot'),
                          color: Colors.orange,
                          onTap: () => filterActivities('Hot'),
                        ),
                      ),

                      ShadowWrapper(
                        child: StatusCard(
                          status: 'Paid',
                          count: countStatus('Paid'),
                          color: Colors.blue,
                          onTap: () => filterActivities('Paid'),
                        ),
                      ),

                      ShadowWrapper(
                        child: StatusCard(
                          status: 'Cold',
                          count: countStatus('Cold'),
                          color: Colors.grey,
                          onTap: () => filterActivities('Cold'),
                        ),
                      ),

                      ShadowWrapper(
                        child: StatusCard(
                          status: 'Done',
                          count: countStatus('Done'),
                          color: Colors.green,
                          onTap: () => filterActivities('Done'),
                        ),
                      ),

                      SizedBox(width: 12),
                    ],
                  ),
                ),



                SizedBox(
                  height: 52,
                  child: SingleChildScrollView(

                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        SizedBox(width: 12),
                        ShadowWrapper(child:
                        PaymentStatusCard(
                          label: 'Payments',
                          count: 4,
                          color: Colors.red,
                          icon: Icons.account_balance_wallet,
                          onTap: () {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBar(content: Text('Viewing Payments')));
                          },
                        ),),
                        ShadowWrapper(child:
                        PaymentStatusCard(
                          label: 'Upcoming',
                          count: 4,
                          color: Colors.blue,
                          icon: Icons.access_time,
                          onTap: () {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBar(content: Text('Viewing Upcoming')));
                          },
                        ),),
                        ShadowWrapper(child:
                        PaymentStatusCard(
                          label: 'Done',
                          count: 4,
                          color: Colors.green,
                          icon: Icons.check_circle,
                          onTap: () {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBar(content: Text('Viewing Done')));
                          },
                        ),),
                        SizedBox(width: 12),
                      ],
                    ),
                  ),
                ),
                ShadowWrapper(child:
                SearchBarWidget(
                  controller: searchController,
                  onFilterTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Advanced filters coming soon!')),
                    );
                  },
                  onSearchChanged: (_) => filterActivities(activeFilter),
                ),
                ),
              ],
            ),
          ),



          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                Text(
                  'Recent Activities',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                // -----------------------------
                // UPDATED FILTER MENU
                // -----------------------------
                GestureDetector(
                  key: _filterButtonKey,
                  onTapDown: _openSortMenu,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.filter_list, size: 18, color: Colors.grey[700]),
                        SizedBox(width: 6),
                        Text(
                          selectedSortOption,
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Icon(Icons.arrow_drop_down, color: Colors.grey[700]),
                      ],
                    ),
                  ),
                ),

                SizedBox(width: 20),
              ],
            ),
          ),

          Expanded(
            child: ActivityList(
              activities: filteredActivities,
              getStatusColor: getStatusColor,
            ),
          ),
        ],
      ),
      
      floatingActionButton: FloatingButton(onPressed: (){context.push('/jobform');}),


    );
  }

  Widget _buildMenuItem(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[700]),
        SizedBox(width: 10),
        Text(title),
      ],
    );
  }

}
class ShadowWrapper extends StatelessWidget {
  final Widget child;
  const ShadowWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 2, vertical: 6),// 👈 spacing around the shadow
      padding: EdgeInsets.all(0),
      decoration: BoxDecoration(

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08), // 👈 softer shadow
            blurRadius: 4, // 👈 tighter blur
            spreadRadius: 0.1, // 👈 minimal spread
            offset: Offset(0, 2), // 👈 subtle downward offset
          ),
        ],
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }
}
