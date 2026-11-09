import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/announcement_provider.dart';
import 'manage_schedules.dart';
import 'login_screen.dart';
import 'activity_log_screen.dart';
import 'report_review_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final List<Map<String, String>> _reports = [
    {'title': 'Missed Pickup', 'location': 'Poblacion - Zone 1', 'status': 'Pending', 'color': 'orange'},
    {'title': 'Missed Pickup', 'location': 'Poblacion - Zone 1', 'status': 'Pending', 'color': 'orange'},
    {'title': 'Illegal Dumping', 'location': 'San Isidro - Zone 2', 'status': 'In Progress', 'color': 'purple'},
    {'title': 'Overflowing Bin', 'location': 'Poblacion - Zone 3', 'status': 'Resolved', 'color': 'green'},
  ];

  String _searchQuery = '';

  bool _hasDuplicate(String title, String location) {
    int count = 0;
    for (var report in _reports) {
      if (report['title'] == title && report['location'] == location) {
        count++;
      }
    }
    return count > 1;
  }

  void _showAnnouncementDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    final provider = Provider.of<AnnouncementProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF222B36),
          title: const Text('Post Announcement', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Type your announcement here...',
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFF161C24),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF00E676), foregroundColor: Colors.black),
              onPressed: () {
                provider.updateAnnouncement(controller.text);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Announcement Posted!'), backgroundColor: Colors.green),
                );
              },
              child: const Text('Post'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredReports = _reports.where((report) {
      final title = report['title']!.toLowerCase();
      final location = report['location']!.toLowerCase();
      final query = _searchQuery.toLowerCase();
      return title.contains(query) || location.contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF161C24),
      appBar: AppBar(
        automaticallyImplyLeading: false, // ✅ KINI ANG MOTANGGAL SA BACK ARROW
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.blueAccent),
            tooltip: 'Activity Log',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ActivityLogScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.campaign, color: Color(0xFFFFA000)),
            tooltip: 'Post Announcement',
            onPressed: () => _showAnnouncementDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month, color: Color(0xFF00E676)),
            tooltip: 'Manage Schedules',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageSchedules())),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            tooltip: 'Logout',
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('System Overview', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(child: _buildStatCard('Total', '12', const Color(0xFF1976D2), Icons.folder)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard('Pending', '5', const Color(0xFFFFA000), Icons.hourglass_empty)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildStatCard('In Progress', '3', const Color(0xFF8E24AA), Icons.autorenew)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard('Resolved', '4', const Color(0xFF00E676), Icons.check_circle)),
              ],
            ),
            const SizedBox(height: 20),
            
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF00E676).withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search reports by title or location...',
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF00E676)),
                  filled: true,
                  fillColor: const Color(0xFF222B36),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF00E676), width: 1.5)),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 20),

            const Text('Recent Reports', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 12),
            
            filteredReports.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Center(child: Text('No reports found.', style: TextStyle(color: Colors.grey))),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredReports.length,
                    itemBuilder: (context, index) {
                      final report = filteredReports[index];
                      Color statusColor = report['color'] == 'orange' 
                          ? const Color(0xFFFFA000) 
                          : (report['color'] == 'purple' ? const Color(0xFF8E24AA) : const Color(0xFF00E676));

                      bool isDuplicate = _hasDuplicate(report['title']!, report['location']!);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isDuplicate)
                            Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 16),
                                  SizedBox(width: 8),
                                  Text('Possible duplicate detected!', style: TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          _buildReportTile(report['title']!, report['location']!, report['status']!, statusColor),
                        ],
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.2), const Color(0xFF222B36)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color, size: 22),
              ),
              Icon(Icons.trending_up, color: color.withOpacity(0.7), size: 16),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildReportTile(String title, String location, String status, Color statusColor) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReportReviewScreen(
              reportTitle: title,
              reportLocation: location,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF222B36),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2C3A47)),
        ),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.report, color: statusColor, size: 24),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
          subtitle: Text(location, style: const TextStyle(fontSize: 13)),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Text(status, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}