import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF161C24),
      appBar: AppBar(
        title: const Text('Monthly Reports'),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Report Analytics', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            const Text('Overview of community reports for this month.', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),

            // ✅ PIE CHART SECTION
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF222B36),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF2C3A47)),
              ),
              child: Column(
                children: [
                  const Text('Reports by Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 4,
                        centerSpaceRadius: 60,
                        sections: [
                          PieChartSectionData(color: const Color(0xFFFFA000), value: 5, title: 'Pending', radius: 40, titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                          PieChartSectionData(color: const Color(0xFF8E24AA), value: 3, title: 'In Progress', radius: 40, titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                          PieChartSectionData(color: const Color(0xFF00E676), value: 4, title: 'Resolved', radius: 40, titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Legend
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegend('Pending', const Color(0xFFFFA000)),
                      const SizedBox(width: 16),
                      _buildLegend('In Progress', const Color(0xFF8E24AA)),
                      const SizedBox(width: 16),
                      _buildLegend('Resolved', const Color(0xFF00E676)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ✅ BAR CHART SECTION
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
                  const Text('Reports per Barangay', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 200,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: 10,
                        barTouchData: BarTouchData(enabled: false),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                const style = TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10);
                                switch (value.toInt()) {
                                  case 0: return const Text('Pob.', style: style);
                                  case 1: return const Text('San Isidro', style: style);
                                  case 2: return const Text('Sta. Cruz', style: style);
                                  default: return const Text('');
                                }
                              },
                            ),
                          ),
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        barGroups: [
                          BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 8, color: const Color(0xFF00E676), width: 20, borderRadius: BorderRadius.circular(4))]),
                          BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 5, color: const Color(0xFF00B0FF), width: 20, borderRadius: BorderRadius.circular(4))]),
                          BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 3, color: const Color(0xFFFFA000), width: 20, borderRadius: BorderRadius.circular(4))]),
                        ],
                      ),
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

  Widget _buildLegend(String text, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}