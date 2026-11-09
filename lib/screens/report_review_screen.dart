import 'package:flutter/material.dart';

class ReportReviewScreen extends StatefulWidget {
  final String reportTitle;
  final String reportLocation;

  const ReportReviewScreen({
    super.key,
    required this.reportTitle,
    required this.reportLocation,
  });

  @override
  State<ReportReviewScreen> createState() => _ReportReviewScreenState();
}

class _ReportReviewScreenState extends State<ReportReviewScreen> {
  String _currentStatus = 'Pending'; // Default status
  final TextEditingController _remarksController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF161C24),
      appBar: AppBar(
        title: const Text('Review Report'),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Detalye sa Report
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF222B36),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF2C3A47)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.reportTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 8),
                  Text(widget.reportLocation, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  const SizedBox(height: 16),
                  const Text('Description:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 4),
                  const Text('Walay koleksyon sa among lugar karong semanaha. Nagtapok na ang basura sa daplin.', style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 16),
                  const Text('Photo Attached:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 8),
                  
                  // ✅ PICTURE SA BASURA (Gikan sa Internet)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      'https://images.unsplash.com/photo-1530587191325-3db32d826c18?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 180,
                          color: const Color(0xFF161C24),
                          child: const Center(child: CircularProgressIndicator(color: Color(0xFF00E676))),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 180,
                          color: const Color(0xFF161C24),
                          child: const Center(child: Icon(Icons.broken_image, color: Colors.grey, size: 50)),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Update Status Dropdown
            const Text('Update Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _currentStatus,
              dropdownColor: const Color(0xFF222B36),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF222B36),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                prefixIcon: const Icon(Icons.update, color: Color(0xFF00E676)),
              ),
              items: ['Pending', 'Under Review', 'In Progress', 'Resolved', 'Rejected']
                  .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  _currentStatus = val!;
                });
              },
            ),
            const SizedBox(height: 20),

            // Admin Remarks
            const Text('Admin Remarks', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            TextField(
              controller: _remarksController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Add remarks or notes here...',
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF222B36),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF00E676),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  // Mock save functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Report updated to $_currentStatus'), backgroundColor: Colors.green),
                  );
                  Navigator.pop(context); // Mobalik sa Admin Dashboard
                },
                icon: const Icon(Icons.save),
                label: const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}