import 'package:flutter/material.dart';
import '../widgets/sidebar_logo.dart';

// ✅ Added import for User Rights Screen
import 'package:lightatech/customer/intro/screens/order_detail_screen.dart';

class SidebarMenu extends StatelessWidget {
  const SidebarMenu({Key? key}) : super(key: key);

  Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget buildMenuItem(String label, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(label),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          children: [
            SidebarLogo(), // ✅ Add this here

            // Menu items below
            buildMenuItem('All Staffs Dashboard', Icons.dashboard, () {}),
            buildMenuItem('Projects', Icons.work_outline, () {}),
            buildMenuItem('Reach Dashboard', Icons.people_outline, () {}),
            buildMenuItem('Turnover', Icons.bar_chart, () {}),
            buildMenuItem('Packages', Icons.card_giftcard, () {}),
            buildMenuItem('Productivity', Icons.show_chart, () {}),
            const Divider(),
            buildMenuItem('About', Icons.info_outline, () {}),
            buildMenuItem('Feedback', Icons.feedback_outlined, () {}),
            buildMenuItem('Share', Icons.share_outlined, () {}),
            const Divider(),
            buildMenuItem('App Gallery', Icons.apps, () {
              Navigator.pop(context); // close drawer

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OrderDetailScreen(),
                ),
              );
            }),

            // ✅ Only this item was updated
            buildMenuItem('Add Shortcut', Icons.add_box_outlined, () {

            }),
          ],
        ),
      ),
    );
  }
}