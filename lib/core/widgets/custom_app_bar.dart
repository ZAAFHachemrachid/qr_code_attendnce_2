import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showDrawerIcon;
  final VoidCallback? onDrawerIconPressed;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showDrawerIcon = true,
    this.onDrawerIconPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.emeraldPrimary,
      foregroundColor: Colors.white,
      leading:
          showDrawerIcon
              ? IconButton(
                icon: const Icon(Icons.menu),
                onPressed:
                    onDrawerIconPressed ??
                    () => Scaffold.of(context).openDrawer(),
              )
              : null,
      title: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      ),
      centerTitle: true,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class CustomSearchBar extends StatelessWidget {
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback? onFilterTap;

  const CustomSearchBar({
    super.key,
    required this.hintText,
    required this.onChanged,
    this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppTheme.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(color: AppTheme.textSecondary),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (onFilterTap != null) ...[
            const SizedBox(width: 12),
            IconButton(
              icon: const Icon(
                Icons.filter_list,
                color: AppTheme.textSecondary,
              ),
              onPressed: onFilterTap,
            ),
          ],
        ],
      ),
    );
  }
}

class CustomScaffold extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final Widget body;
  final Widget? drawer;
  final Widget? floatingActionButton;
  final bool showDrawerIcon;
  final Widget? bottomNavigationBar;

  const CustomScaffold({
    super.key,
    required this.title,
    this.actions,
    required this.body,
    this.drawer,
    this.floatingActionButton,
    this.showDrawerIcon = true,
    this.bottomNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: title,
        actions: actions,
        showDrawerIcon: showDrawerIcon && drawer != null,
      ),
      drawer: drawer,
      body: body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
