import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../theme/app_theme.dart';

class DrawerItem {
  final IconData icon;
  final String title;
  final String route;
  final bool dividerAfter;

  const DrawerItem({
    required this.icon,
    required this.title,
    required this.route,
    this.dividerAfter = false,
  });
}

class AppDrawer extends StatelessWidget {
  final String userName;
  final UserRole userRole;
  final List<DrawerItem> items;
  final int selectedIndex;
  final VoidCallback onLogout;

  const AppDrawer({
    super.key,
    required this.userName,
    required this.userRole,
    required this.items,
    required this.selectedIndex,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: AppTheme.emeraldPrimary),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.emeraldPrimary,
                ),
              ),
            ),
            accountName: Text(
              userName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(
              userRole.name.toUpperCase(),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = index == selectedIndex;

                return Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        item.icon,
                        color:
                            isSelected
                                ? AppTheme.emeraldPrimary
                                : AppTheme.textSecondary,
                      ),
                      title: Text(
                        item.title,
                        style: TextStyle(
                          color:
                              isSelected
                                  ? AppTheme.emeraldPrimary
                                  : AppTheme.textPrimary,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        if (!isSelected) {
                          Navigator.pushReplacementNamed(context, item.route);
                        }
                      },
                      selected: isSelected,
                      selectedTileColor: AppTheme.emeraldPrimary.withOpacity(
                        0.1,
                      ),
                    ),
                    if (item.dividerAfter) const Divider(),
                  ],
                );
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
            ),
            onTap: () {
              Navigator.pop(context); // Close drawer
              onLogout();
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
