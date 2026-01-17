import 'package:flutter/material.dart';
import '../widgets/sidebar_logo.dart';

// Screens
import '../../adminAccess/screens/user_rights_screen.dart';
import 'package:lightatech/customer/intro/screens/order_detail_screen.dart';

class SidebarMenu extends StatelessWidget {
  const SidebarMenu({Key? key}) : super(key: key);

  Widget buildMenuItem(
      BuildContext context,
      String label,
      IconData icon,
      VoidCallback onTap,
      ) {
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
            const SidebarLogo(),

            buildMenuItem(
              context,
              'All Staffs Dashboard',
              Icons.dashboard,
                  () {},
            ),
            buildMenuItem(
              context,
              'Projects',
              Icons.work_outline,
                  () {},
            ),
            buildMenuItem(
              context,
              'Reach Dashboard',
              Icons.people_outline,
                  () {},
            ),
            buildMenuItem(
              context,
              'Turnover',
              Icons.bar_chart,
                  () {},
            ),
            buildMenuItem(
              context,
              'Packages',
              Icons.card_giftcard,
                  () {},
            ),
            buildMenuItem(
              context,
              'Productivity',
              Icons.show_chart,
                  () {},
            ),

            const Divider(),

            buildMenuItem(
              context,
              'About',
              Icons.info_outline,
                  () {},
            ),
            buildMenuItem(
              context,
              'Feedback',
              Icons.feedback_outlined,
                  () {},
            ),
            buildMenuItem(
              context,
              'Share',
              Icons.share_outlined,
                  () {},
            ),

            const Divider(),

            buildMenuItem(
              context,
              'App Gallery',
              Icons.apps,
                  () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const OrderDetailScreen(),
                  ),
                );
              },
            ),

            buildMenuItem(
              context,
              'Add Shortcut',
              Icons.add_box_outlined,
                  () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => UserRightsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
