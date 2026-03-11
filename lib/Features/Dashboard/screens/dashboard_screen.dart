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

  const DashboardScreen({
    super.key,
    required this.department,
    required this.email,
  });

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
      backgroundColor: Colors.white,
      drawer: SidebarMenu(),
      appBar: DashboardAppBar(
        showBack: false,
        department: widget.department,
        onBack: () {},
      ),
      body: Column(
        children: [
          // ── Top Section (white card) ──────────────────────────────────
          Container(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── 1. Search Bar (top, above cards) ─────────────────────
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: searchController,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: 'Search for..',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 13,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.grey.shade400,
                              size: 20,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            contentPadding: EdgeInsets.zero,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Filter button
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Advanced filters coming soon!'),
                            ),
                          );
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8D94B),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.tune,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── 2. Status Cards ───────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.only(left: 12, bottom: 4),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;

                      // 📱 MOBILE → horizontal scroll
                      if (width < 600) {
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
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
                              const SizedBox(width: 12),
                            ],
                          ),
                        );
                      }

                      // 🖥 TABLET / WEB → Grid
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

                // ── 3. Payment Chips ──────────────────────────────────────
                SizedBox(
                  height: 50,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        const SizedBox(width: 12),
                        PaymentStatusCard(
                          label: 'Payments',
                          count: 4,
                          color: Colors.red,
                          icon: Icons.credit_card_rounded,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Viewing Payments')),
                            );
                          },
                        ),
                        PaymentStatusCard(
                          label: 'Upcoming',
                          count: 4,
                          color: Colors.blue,
                          icon: Icons.access_time_rounded,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Viewing Upcoming')),
                            );
                          },
                        ),
                        PaymentStatusCard(
                          label: 'Completed',
                          count: 4,
                          color: Colors.green,
                          icon: Icons.check_circle_outline_rounded,
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

                const SizedBox(height: 4),
              ],
            ),
          ),

          // ── Firebase Jobs List (contains its own tabs) ────────────────
          Expanded(
            child: ActivityListFirestore(
              searchText: searchController.text,
              department: widget.department,
            ),
          ),
        ],
      ),

      // ── Floating Add Button → open Job Form ───────────────────────────
      floatingActionButton: widget.department == 'Designer'
          ? FloatingButton(
        onPressed: () {
          context.push(
            '/jobform',
            extra: {
              'department': 'Designer',
              'email': widget.email,
            },
          );
        },
      )
          : null,
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

//Login Parsing to be done