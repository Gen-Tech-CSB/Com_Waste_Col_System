import 'package:flutter/material.dart';

import '../widgets/ui.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});
  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _descController = TextEditingController();
  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      const PageHeading(
        eyebrow: 'Make a difference',
        title: 'Report an issue',
        subtitle: 'Help your community spot collection problems and keep shared spaces clean.',
      ),
      const SizedBox(height: 28),
      SurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Issue details',
              style: TextStyle(
                color: Ui.of(context).text,
                fontSize: 19,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tell us what happened so the team can understand the issue.',
              style: TextStyle(color: Ui.of(context).muted, height: 1.5),
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              isExpanded: true,
              dropdownColor: Ui.of(context).surface,
              style: TextStyle(color: Ui.of(context).text),
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              hint: Text(
                'Select an issue',
                style: TextStyle(color: Ui.of(context).muted),
              ),
              items: const [
                DropdownMenuItem(value: 'missed', child: Text('Missed pickup')),
                DropdownMenuItem(
                  value: 'dumping',
                  child: Text('Illegal dumping'),
                ),
              ],
              onChanged: (value) {},
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _descController,
              maxLines: 5,
              maxLength: 1000,
              style: TextStyle(color: Ui.of(context).text),
              decoration: const InputDecoration(
                labelText: 'Description',
                alignLabelWithHint: true,
                hintText: 'What happened? Include any useful location details.',
              ),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                ),
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Report Submitted!')),
                ),
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: const Text('Submit report'),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
