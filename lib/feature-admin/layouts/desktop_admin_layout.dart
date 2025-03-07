import 'package:flutter/material.dart';
import '../config/admin_platform_config.dart';
import 'package:window_manager/window_manager.dart';

class DesktopAdminLayout extends StatefulWidget {
  final Widget child;
  final String title;

  const DesktopAdminLayout({
    super.key,
    required this.child,
    required this.title,
  });

  @override
  State<DesktopAdminLayout> createState() => _DesktopAdminLayoutState();
}

class _DesktopAdminLayoutState extends State<DesktopAdminLayout>
    with WindowListener {
  @override
  void initState() {
    super.initState();
    _initializeWindow();
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  Future<void> _initializeWindow() async {
    try {
      AdminPlatformConfig.validatePlatform();

      await windowManager.ensureInitialized();
      await windowManager.setTitle(
        '${AdminPlatformConfig.windowTitle} - ${widget.title}',
      );
      await windowManager.setMinimumSize(AdminPlatformConfig.minWindowSize);
      await windowManager.setSize(AdminPlatformConfig.defaultWindowSize);
      await windowManager.center();
    } catch (e) {
      debugPrint('Window initialization error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Custom window title bar for Windows
          if (AdminPlatformConfig.isSupported &&
              !AdminPlatformConfig.supportsNativeMenus)
            _WindowTitleBar(title: widget.title),

          // Main content
          Expanded(
            child: Row(
              children: [
                // Side navigation
                _AdminSideNav(),

                // Main content area
                Expanded(
                  child: Container(
                    color: Theme.of(context).colorScheme.background,
                    child: widget.child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WindowTitleBar extends StatelessWidget {
  final String title;

  const _WindowTitleBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        windowManager.startDragging();
      },
      child: Container(
        height: 32,
        color: Theme.of(context).colorScheme.primary,
        child: Row(
          children: [
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            const Spacer(),
            // Window controls
            IconButton(
              icon: const Icon(Icons.minimize, color: Colors.white, size: 20),
              onPressed: () => windowManager.minimize(),
            ),
            IconButton(
              icon: const Icon(
                Icons.crop_square,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () async {
                if (await windowManager.isMaximized()) {
                  windowManager.restore();
                } else {
                  windowManager.maximize();
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 20),
              onPressed: () => windowManager.close(),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminSideNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Admin profile section
          const _AdminProfileSection(),
          const Divider(),
          // Navigation items
          _buildNavItem(
            context: context,
            icon: Icons.dashboard,
            label: 'Dashboard',
            onTap: () => Navigator.pushNamed(context, '/admin/dashboard'),
          ),
          _buildNavItem(
            context: context,
            icon: Icons.people,
            label: 'User Management',
            onTap: () => Navigator.pushNamed(context, '/admin/users'),
          ),
          _buildNavItem(
            context: context,
            icon: Icons.school,
            label: 'Departments',
            onTap: () => Navigator.pushNamed(context, '/admin/departments'),
          ),
          _buildNavItem(
            context: context,
            icon: Icons.book,
            label: 'Courses',
            onTap: () => Navigator.pushNamed(context, '/admin/courses'),
          ),
          _buildNavItem(
            context: context,
            icon: Icons.groups,
            label: 'Groups',
            onTap: () => Navigator.pushNamed(context, '/admin/groups'),
          ),
          _buildNavItem(
            context: context,
            icon: Icons.analytics,
            label: 'Reports',
            onTap: () => Navigator.pushNamed(context, '/admin/reports'),
          ),
          const Spacer(),
          // Logout button
          _buildNavItem(
            context: context,
            icon: Icons.logout,
            label: 'Logout',
            onTap: () {
              // TODO: Implement logout
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: onTap,
      dense: true,
    );
  }
}

class _AdminProfileSection extends StatelessWidget {
  const _AdminProfileSection();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            child: Icon(Icons.admin_panel_settings, size: 30),
          ),
          SizedBox(height: 8),
          Text(
            'Admin Panel',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(
            'System Administrator',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
