import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/sidebar_menu.dart';
import '../widgets/dashboard_appbar.dart';
import '../widgets/payment_status.dart';
import '../widgets/search_bar.dart';
import '../widgets/status_card.dart';
import '../widgets/activity_list_firestore.dart';

import 'package:lightatech/FormComponents/FLoatingButton.dart';

class DashboardScreen extends StatefulWidget {
  final String department;
  final String email;

  const DashboardScreen({super.key,
    required this.department,
    required this.email,});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SidebarMenu(),
      appBar: DashboardAppBar(
        showBack: false,
        department: widget.department,
        onBack: () {},
      ),
      body: Column(
        children: [
          // ✅ Top Section (Cards + Chips + Search)
          Container(
            color: Colors.blueGrey.shade50,
            child: Column(
              children: [
                // ✅ Status Cards (static for now)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;

                      // 📱 MOBILE → KEEP OLD UI (NO CHANGE)
                      if (width < 600) {
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              const SizedBox(width: 12),
                              StatusCard(
                                status: 'Hot',
                                count: 0,
                                color: Colors.orange,
                                onTap: () {},
                              ),
                              StatusCard(
                                status: 'Paid',
                                count: 0,
                                color: Colors.blue,
                                onTap: () {},
                              ),
                              StatusCard(
                                status: 'Cold',
                                count: 0,
                                color: Colors.grey,
                                onTap: () {},
                              ),
                              StatusCard(
                                status: 'Done',
                                count: 0,
                                color: Colors.green,
                                onTap: () {},
                              ),
                              const SizedBox(width: 12),
                            ],
                          ),
                        );
                      }

                      // 🖥 TABLET / WEB → GRID VIEW
                      int crossAxisCount = 2;
                      if (width > 1024) crossAxisCount = 4;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: width > 1024 ? 1.6 : 1.8,
                          children: [
                            StatusCard(
                              status: 'Hot',
                              count: 0,
                              color: Colors.orange,
                              onTap: () {},
                            ),
                            StatusCard(
                              status: 'Paid',
                              count: 0,
                              color: Colors.blue,
                              onTap: () {},
                            ),
                            StatusCard(
                              status: 'Cold',
                              count: 0,
                              color: Colors.grey,
                              onTap: () {},
                            ),
                            StatusCard(
                              status: 'Done',
                              count: 0,
                              color: Colors.green,
                              onTap: () {},
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                ),


                // ✅ Payment Chips
                SizedBox(
                  height: 52,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        const SizedBox(width: 12),
                          PaymentStatusCard(
                            label: 'Payments',
                            count: 4,
                            color: Colors.red,
                            icon: Icons.account_balance_wallet,
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Viewing Payments')),
                              );
                            },
                          ),
                          PaymentStatusCard(
                            label: 'Upcoming',
                            count: 4,
                            color: Colors.blue,
                            icon: Icons.access_time,
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Viewing Upcoming')),
                              );
                            },
                          ),
                          PaymentStatusCard(
                            label: 'Done',
                            count: 4,
                            color: Colors.green,
                            icon: Icons.check_circle,
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Viewing Done')),
                              );
                            },
                          ),

                        const SizedBox(width: 12),
                      ],
                    ),
                  ),
                ),

                // ✅ Search Bar (UI only for now)
                  SearchBarWidget(
                    controller: searchController,
                    onFilterTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Advanced filters coming soon!'),
                        ),
                      );
                    },
                    onSearchChanged: (_) {
                      // ✅ We will connect search to Firestore later
                      setState(() {});
                    },
                  ),
              ],
            ),
          ),

          // ✅ Recent Activities Header
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Recent Activities',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // ✅ Firebase Jobs List
          Expanded(
            child: ActivityListFirestore(
              searchText: searchController.text,
            ),
          ),

        ],
      ),

      // ✅ Floating Add Button → open Job Form
      floatingActionButton: FloatingButton(
        onPressed: () {
          context.push(
            '/jobform',
            extra: {
              'department': widget.department,
              'email': widget.email,
            },
          );

        },
      ),
    );
  }
}

class ShadowWrapper extends StatelessWidget {
  final Widget child;
  const ShadowWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 4,
            spreadRadius: 0.1,
            offset: const Offset(0, 2),
          ),
        ],
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }
}
