import 'package:flutter/material.dart';

class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Waste Segregation Guide',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Tun-i unsaon pag-segregate sa basura.',
          style: TextStyle(fontSize: 14, color: Color(0xFFA7B8B2)),
        ),
        const SizedBox(height: 24),
        _buildGuideCard(
          'Biodegradable (Nabubulok)',
          'Mga basura nga madunot. (e.g., Dahon, Pagkaon)',
          const Color(0xFFB6EF86),
          Icons.eco,
        ),
        _buildGuideCard(
          'Non-Biodegradable (Di-Nabubulok)',
          'Mga basura nga dili madunot. (e.g., Plastic, Styro)',
          const Color(0xFF00B0FF),
          Icons.delete,
        ),
        _buildGuideCard(
          'Recyclable (Nare-recycle)',
          'Mga basura nga pwede pa himuong bag-ong gamit. (e.g., Botelya, Lata)',
          const Color(0xFFFFA000),
          Icons.recycling,
        ),
        _buildGuideCard(
          'Special Waste (Mapanganib)',
          'Mga basura nga delikado. (e.g., Baterya, Ilaw)',
          Colors.redAccent,
          Icons.warning,
        ),
        const SizedBox(height: 32),
        const Text(
          'Emergency Contacts',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        _buildContactCard(
          'Barangay Waste Office',
          '0912-345-6789',
          const Color(0xFFB6EF86),
        ),
        _buildContactCard(
          'LGU Sanitation Department',
          '(02) 8123-4567',
          const Color(0xFF00B0FF),
        ),
      ],
    );
  }

  Widget _buildGuideCard(
    String title,
    String description,
    Color color,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF192626),
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
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFFA7B8B2),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(String title, String number, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF192626),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(Icons.phone, color: color),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        subtitle: Text(
          number,
          style: const TextStyle(color: Color(0xFFA7B8B2)),
        ),
      ),
    );
  }
}
