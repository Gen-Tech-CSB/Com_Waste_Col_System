import 'package:flutter/material.dart';
import 'manage_schedules.dart'; // ✅ Import sa Manage Schedules

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
        actions: [
          // ✅ Kini ang bag-ong button sa taas
          IconButton(
            icon: const Icon(Icons.calendar_month),
            tooltip: 'Manage Schedules',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ManageSchedules()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: _buildStatCard('Total', '12', Colors.blue)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard('Pending', '5', Colors.orange)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildStatCard('In Progress', '3', Colors.amber)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard('Resolved', '4', Colors.green)),
              ],
            ),
            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Recent Reports', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: const [
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.warning, color: Colors.orange),
                      title: Text('Missed Pickup'),
                      subtitle: Text('Poblacion - Zone 1'),
                      trailing: Chip(label: Text('Pending')),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.delete, color: Colors.red),
                      title: Text('Illegal Dumping'),
                      subtitle: Text('Poblacion - Zone 2'),
                      trailing: Chip(label: Text('In Progress')),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }
}