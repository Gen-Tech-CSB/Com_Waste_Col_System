import '../widgets/ui.dart';

import 'package:flutter/material.dart';

class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({super.key});

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  // Variable para ma-save ang rating
  int _rating = 0;
  final TextEditingController _feedbackController = TextEditingController();

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'My Reports',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Ui.of(context).text,
          ),
        ),
        const SizedBox(height: 16),

        // Sample nga Resolved nga Report
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Ui.of(context).surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Ui.of(context).border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'Missed Pickup',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Ui.of(context).text,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Ui.of(context).green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Resolved',
                      style: TextStyle(
                        color: Ui.of(context).green,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Poblacion - Zone 1',
                style: TextStyle(color: Ui.of(context).muted, fontSize: 13),
              ),
              const SizedBox(height: 16),

              Divider(color: Ui.of(context).border),
              const SizedBox(height: 8),

              // 🌟 RESIDENT FEEDBACK SECTION
              Text(
                'Rate this service:',
                style: TextStyle(color: Ui.of(context).muted, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Wrap(
                alignment: WrapAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      color: Ui.of(context).amber,
                      size: 32,
                    ),
                    onPressed: () {
                      setState(() {
                        _rating = index + 1;
                      });
                    },
                  );
                }),
              ),
              const SizedBox(height: 8),

              // Comment Box
              TextField(
                controller: _feedbackController,
                style: TextStyle(color: Ui.of(context).text),
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Leave a comment (optional)...',
                  hintStyle: TextStyle(color: Ui.of(context).muted),
                  filled: true,
                  fillColor: Ui.of(context).background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Submit Feedback Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Ui.of(context).green,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    if (_rating == 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select a star rating first!'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Thank you for your feedback!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    // Reset
                    setState(() {
                      _rating = 0;
                      _feedbackController.clear();
                    });
                  },
                  child: const Text(
                    'Submit Feedback',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
