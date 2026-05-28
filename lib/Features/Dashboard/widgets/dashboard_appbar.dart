import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:lightatech/core/theme/theme_provider.dart';

class DashboardAppBar extends StatefulWidget implements PreferredSizeWidget {
  final bool showBack;
  final VoidCallback? onBack;
  final String department;

  // ✅ ADDED FOR WORKING SEARCH
  final TextEditingController? searchController;
  final Function(String)? onSearchChanged;

  const DashboardAppBar({
    Key? key,
    this.showBack = false,
    this.onBack,
    required this.department,
    this.searchController,
    this.onSearchChanged,
  }) : super(key: key);

  @override
  State<DashboardAppBar> createState() => _DashboardAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _DashboardAppBarState extends State<DashboardAppBar>
    with SingleTickerProviderStateMixin {
  bool _searchOpen = false;
  late AnimationController _animController;
  late Animation<double> _widthAnim;

  final TextEditingController _localSearchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  TextEditingController get _activeSearchController {
    return widget.searchController ?? _localSearchController;
  }

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
    _localSearchController.dispose();
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
      _activeSearchController.clear();

      // ✅ CLEAR DASHBOARD SEARCH ALSO
      widget.onSearchChanged?.call("");
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
                    color: Colors.black.withOpacity(
                      isDark ? 0.3 : 0.06,
                    ),
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

      title: Row(
        children: [
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

          AnimatedBuilder(
            animation: _widthAnim,
            builder: (context, _) {
              final maxW = MediaQuery.of(context).size.width * 0.48;
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
                        color: Colors.black.withOpacity(
                          isDark ? 0.3 : 0.08,
                        ),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _activeSearchController,
                    focusNode: _focusNode,

                    // ✅ MAIN FIX
                    onChanged: widget.onSearchChanged,

                    style: TextStyle(fontSize: 13, color: iconColor),
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

      actions: [
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