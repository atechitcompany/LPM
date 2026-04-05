import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lightatech/core/session/session_manager.dart';
import 'package:provider/provider.dart';
import 'package:lightatech/core/theme/theme_provider.dart';

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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFEEF2FF);
    final iconColor = isDark ? Colors.white : Colors.black;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return AppBar(
      backgroundColor: bgColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      leadingWidth: 56,
      leading: showBack
          ? IconButton(
              icon: Icon(Icons.arrow_back, color: iconColor),
              onPressed: onBack,
            )
          : Builder(
              builder: (context) => Center(
                child: GestureDetector(
                  onTap: () => Scaffold.of(context).openDrawer(),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: cardColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Icon(Icons.menu, color: iconColor, size: 20),
                  ),
                ),
              ),
            ),
      title: Text(
        'Dashboard',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 22,
          color: iconColor,
        ),
      ),
      actions: [
        if (department == 'Designer')
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => context.push('/customer-requests'),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: cardColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.notifications_none,
                  color: iconColor,
                  size: 20,
                ),
              ),
            ),
          ),

        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: GestureDetector(
            onTap: () => context.push('/profile'),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: cardColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Image.asset(
                  'assets/user.png',
                  width: 20,
                  height: 20,
                  color: iconColor,
                  errorBuilder: (_, __, ___) =>
                      Icon(Icons.person, color: iconColor, size: 20),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
