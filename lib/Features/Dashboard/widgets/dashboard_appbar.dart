import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lightatech/core/session/session_manager.dart';


class DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showBack;
  final VoidCallback? onBack;
  final String department;

  const DashboardAppBar({
    Key? key,
    this.showBack = false,
    this.onBack,
    required this.department,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.blueGrey.shade50,
      leading: showBack
          ? IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: onBack,
      )
          : Builder( // 👈 this is the fix
        builder: (context) => IconButton(
          icon: Icon(Icons.menu),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dashboard',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            department,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
        ],
      ),

      actions: [
        IconButton(
          icon: Icon(Icons.notifications_none),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('No new notifications')),
            );
          },
        ),
        IconButton(
          icon: Image.asset(
            'assets/user.png',
            width: 20, // 👈 adjust size
            height: 20,
          ),

          onPressed: () async {
            await SessionManager.clearSession();
            context.go('/');
          },

        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}