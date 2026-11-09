import '../widgets/ui.dart';

import 'package:flutter/material.dart';

class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Waste Segregation Guide',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Ui.of(context).text,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tun-i unsaon pag-segregate sa basura.',
          style: TextStyle(fontSize: 14, color: Ui.of(context).muted),
        ),
        const SizedBox(height: 24),
        _buildGuideCard(
          context,
          'Biodegradable (Nabubulok)',
          'Mga basura nga madunot. (e.g., Dahon, Pagkaon)',
          Ui.of(context).green,
          Icons.eco,
        ),
        _buildGuideCard(
          context,
          'Non-Biodegradable (Di-Nabubulok)',
          'Mga basura nga dili madunot. (e.g., Plastic, Styro)',
          Ui.of(context).blue,
          Icons.delete,
        ),
        _buildGuideCard(
          context,
          'Recyclable (Nare-recycle)',
          'Mga basura nga pwede pa himuong bag-ong gamit. (e.g., Botelya, Lata)',
          Ui.of(context).amber,
          Icons.recycling,
        ),
        _buildGuideCard(
          context,
          'Special Waste (Mapanganib)',
          'Mga basura nga delikado. (e.g., Baterya, Ilaw)',
          Ui.of(context).danger,
          Icons.warning,
        ),
        const SizedBox(height: 32),
        Text(
          'Emergency Contacts',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Ui.of(context).text,
          ),
        ),
        const SizedBox(height: 16),
        _buildContactCard(
          context,
          'Barangay Waste Office',
          '0912-345-6789',
          Ui.of(context).green,
        ),
        _buildContactCard(
          context,
          'LGU Sanitation Department',
          '(02) 8123-4567',
          Ui.of(context).blue,
        ),
      ],
    );
  }

  Widget _buildGuideCard(
    BuildContext context,
    String title,
    String description,
    Color color,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Ui.of(context).surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 13, color: Ui.of(context).muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(
    BuildContext context,
    String title,
    String number,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Ui.of(context).surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(Icons.phone, color: color),
        title: Text(title, style: TextStyle(color: Ui.of(context).text)),
        subtitle: Text(number, style: TextStyle(color: Ui.of(context).muted)),
      ),
    );
  }
}
