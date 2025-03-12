import 'package:flutter/material.dart';
import 'package:device_apps/device_apps.dart';
import '../models/health_reminder.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('MindChoice'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.block), text: 'Chặn ứng dụng'),
              Tab(icon: Icon(Icons.timer), text: 'Thời gian'),
              Tab(icon: Icon(Icons.health_and_safety), text: 'Sức khỏe'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildBlockedAppsTab(),
            _buildTimeManagementTab(),
            _buildHealthRemindersTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildBlockedAppsTab() {
    return FutureBuilder<List<Application>>(
      future: DeviceApps.getInstalledApplications(
        onlyAppsWithLaunchIntent: true,
        includeSystemApps: false,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}'));
        }

        final apps = snapshot.data ?? [];
        return ListView.builder(
          itemCount: apps.length,
          itemBuilder: (context, index) {
            final app = apps[index];
            return ListTile(
              leading: const Icon(Icons.android),
              title: Text(app.appName),
              subtitle: Text(app.packageName),
              trailing: IconButton(
                icon: const Icon(Icons.block),
                onPressed: () {
                  // TODO: Implement app blocking
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Đã chặn ${app.appName}'),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTimeManagementTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.timer, size: 64),
          const SizedBox(height: 16),
          const Text(
            'Quản lý thời gian',
            style: TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 8),
          Text(
            'Tính năng đang phát triển',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthRemindersTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildReminderCard(
          'Nhắc nhở uống nước',
          'Đặt lịch nhắc nhở uống nước định kỳ',
          Icons.water_drop,
          () => _showAddReminderDialog(ReminderType.water),
        ),
        const SizedBox(height: 16),
        _buildReminderCard(
          'Nhắc nhở tập thể dục',
          'Đặt lịch nhắc nhở tập thể dục',
          Icons.fitness_center,
          () => _showAddReminderDialog(ReminderType.exercise),
        ),
        const SizedBox(height: 16),
        _buildReminderCard(
          'Nhắc nhở điều chỉnh tư thế',
          'Đặt lịch nhắc nhở điều chỉnh tư thế ngồi',
          Icons.accessibility_new,
          () => _showAddReminderDialog(ReminderType.posture),
        ),
      ],
    );
  }

  Widget _buildReminderCard(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 32),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  Future<void> _showAddReminderDialog(ReminderType type) async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đã đặt nhắc nhở ${type == ReminderType.water ? "uống nước" : type == ReminderType.exercise ? "tập thể dục" : "điều chỉnh tư thế"} lúc ${time.format(context)}',
          ),
        ),
      );
    }
  }
} 