import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../layouts/desktop_admin_layout.dart';
import '../../config/admin_platform_config.dart';
import '../../providers/admin_provider.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    _validatePlatform();
    _loadDashboardData();
  }

  void _validatePlatform() {
    try {
      AdminPlatformConfig.validatePlatform();
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/login');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      });
    }
  }

  Future<void> _loadDashboardData() async {
    try {
      await ref.read(adminDashboardProvider.notifier).loadDashboardStats();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading dashboard data: ${e.toString()}'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(adminDashboardProvider);

    return DesktopAdminLayout(
      title: 'Dashboard',
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome, Administrator',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),

            // Quick Stats Grid
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildStatCard(
                  title: 'Total Students',
                  value: stats.totalStudents.toString(),
                  icon: Icons.school,
                  color: Colors.blue,
                ),
                _buildStatCard(
                  title: 'Total Teachers',
                  value: stats.totalTeachers.toString(),
                  icon: Icons.person,
                  color: Colors.green,
                ),
                _buildStatCard(
                  title: 'Active Sessions',
                  value: stats.activeSessions.toString(),
                  icon: Icons.timer,
                  color: Colors.orange,
                ),
                _buildStatCard(
                  title: 'Today\'s Attendance',
                  value:
                      '${stats.todayAttendancePercentage.toStringAsFixed(1)}%',
                  icon: Icons.check_circle,
                  color: Colors.purple,
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Recent Activity
            const Text(
              'Recent Activity',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                child:
                    stats.recentActivities.isEmpty
                        ? const Center(child: Text('No recent activities'))
                        : ListView.builder(
                          itemCount: stats.recentActivities.length,
                          itemBuilder: (context, index) {
                            final activity = stats.recentActivities[index];
                            return ListTile(
                              leading: const CircleAvatar(
                                child: Icon(Icons.notifications),
                              ),
                              title: Text(activity.title),
                              subtitle: Text(activity.description),
                              trailing: Text(
                                _formatTimestamp(activity.timestamp),
                              ),
                            );
                          },
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 16),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
