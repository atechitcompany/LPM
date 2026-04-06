import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:lightatech/core/theme/theme_provider.dart';

class DashboardAppBar extends StatefulWidget implements PreferredSizeWidget {
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
  State<DashboardAppBar> createState() => _DashboardAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _DashboardAppBarState extends State<DashboardAppBar>
    with SingleTickerProviderStateMixin {

  // ── Animation (ported from customer app) ─────────────────────────────────
  bool _searchOpen = false;
  late AnimationController _animController;
  late Animation<double> _widthAnim;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _widthAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() => _searchOpen = !_searchOpen);
    if (_searchOpen) {
      _animController.forward();
      Future.delayed(
        const Duration(milliseconds: 260),
            () => _focusNode.requestFocus(),
      );
    } else {
      _animController.reverse();
      _focusNode.unfocus();
      _searchController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    final bgColor =
    isDark ? const Color(0xFF121212) : const Color(0xFFEEF2FF);
    final iconColor = isDark ? Colors.white : Colors.black87;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return AppBar(
      backgroundColor: bgColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 0,

      // ── Leading: hamburger or back ────────────────────────────────────
      leading: widget.showBack
          ? IconButton(
        icon: Icon(Icons.arrow_back, color: iconColor),
        onPressed: widget.onBack,
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
                    color: Colors.black
                        .withOpacity(isDark ? 0.3 : 0.06),
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

      // ── Title: "Dashboard" collapses when search opens ───────────────
      title: Row(
        children: [
          // Title — hidden while search is open
          if (!_searchOpen)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  'Dashboard',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: iconColor,
                  ),
                ),
              ),
            ),

          // ── Animated expanding search bar ─────────────────────────
          AnimatedBuilder(
            animation: _widthAnim,
            builder: (context, _) {
              final maxW =
                  MediaQuery.of(context).size.width * 0.48;
              final currentW = maxW * _widthAnim.value;
              if (currentW <= 10) return const SizedBox.shrink();
              return SizedBox(
                width: currentW.clamp(0.0, maxW),
                child: Container(
                  height: 36,
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withOpacity(isDark ? 0.3 : 0.08),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _focusNode,
                    style: TextStyle(
                        fontSize: 13, color: iconColor),
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 13,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        size: 18,
                        color: Colors.grey.shade400,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 9,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          if (_searchOpen) const Spacer(),
        ],
      ),

      // ── Actions ──────────────────────────────────────────────────────
      actions: [
        // Search toggle / close — animated icon swap
        IconButton(
          tooltip: _searchOpen ? 'Close search' : 'Search',
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              _searchOpen ? Icons.close : Icons.search,
              key: ValueKey(_searchOpen),
              color: iconColor,
              size: 22,
            ),
          ),
          onPressed: _toggleSearch,
        ),

        // ── Notification bell (Designer only) ─────────────────────────
        if (widget.department == 'Designer')
          Padding(
            padding: const EdgeInsets.only(right: 4),
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

        // ── Profile icon ───────────────────────────────────────────────
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
}