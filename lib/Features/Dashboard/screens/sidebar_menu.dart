import 'package:flutter/material.dart';
import '../widgets/sidebar_logo.dart';
import 'package:go_router/go_router.dart';
import 'package:lightatech/core/session/session_manager.dart';
import 'package:provider/provider.dart';
import 'package:lightatech/core/theme/theme_provider.dart';

import '../../adminAccess/screens/admin_panel_screen.dart';
import '../../adminAccess/screens/user_rights_screen.dart';
import 'package:lightatech/customer/intro/viewmodel/order_detail_view.dart';

class SidebarMenu extends StatelessWidget {
  const SidebarMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    final bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final iconColor = isDark ? const Color(0xFFF8D94B) : Colors.blue;
    final dividerColor = isDark ? Colors.grey.shade800 : Colors.grey.shade200;

    return Drawer(
      backgroundColor: bgColor,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          children: [
            const SidebarLogo(),

            buildMenuItem(
              context,
              'Reach Dashboard',
              Icons.people_outline,
              () {
                Navigator.pop(context);
                context.push('/dashboard');
              },
              textColor,
              iconColor,
            ),

            if (SessionManager.getDepartment() == 'Admin')
              buildMenuItem(
                context,
                'Admin Access',
                Icons.admin_panel_settings,
                () {
                  Navigator.pop(context);
                  context.push('/admin-panel');
                },
                textColor,
                iconColor,
              ),

            buildMenuItem(
              context,
              'Projects',
              Icons.work_outline,
              () {},
              textColor,
              iconColor,
            ),

            buildMenuItem(
              context,
              'Turnover',
              Icons.bar_chart,
              () {},
              textColor,
              iconColor,
            ),

            buildMenuItem(
              context,
              'Packages',
              Icons.card_giftcard,
              () {},
              textColor,
              iconColor,
            ),

            buildMenuItem(
              context,
              'Productivity',
              Icons.show_chart,
              () {
                Navigator.pop(context);
                context.go('/dashboard');
              },
              textColor,
              iconColor,
            ),

            Divider(color: dividerColor),

            buildMenuItem(
              context,
              'About',
              Icons.info_outline,
              () {},
              textColor,
              iconColor,
            ),

            buildMenuItem(
              context,
              'Feedback',
              Icons.feedback_outlined,
              () {},
              textColor,
              iconColor,
            ),

            buildMenuItem(
              context,
              'Share',
              Icons.share_outlined,
              () {
                Navigator.pop(context);
                context.go('/dashboard');
              },
              textColor,
              iconColor,
            ),

            Divider(color: dividerColor),

            buildMenuItem(
              context,
              'App Gallery',
              Icons.apps,
              () {
                Navigator.pop(context);
              },
              textColor,
              iconColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMenuItem(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap,
    Color textColor,
    Color iconColor,
  ) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(label, style: TextStyle(color: textColor)),
      onTap: onTap,
    );
  }
}
