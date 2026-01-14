import 'package:flutter/material.dart';

class DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showBack;
  final VoidCallback? onBack;

  const DashboardAppBar({
    Key? key,
    this.showBack = false,
    this.onBack,
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
      title: Text('Dashboard',style: TextStyle(fontWeight: FontWeight.bold),),
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

          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Profile options coming soon')),
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}