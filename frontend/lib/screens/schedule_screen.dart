import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/schedule_provider.dart';
import '../providers/announcement_provider.dart';
import '../widgets/ui.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final schedules = context.watch<ScheduleProvider>().schedules;
    final announcement = context
        .watch<AnnouncementProvider>()
        .currentAnnouncement;
    return ListView(
      padding: EdgeInsets.all(MediaQuery.sizeOf(context).width < 600 ? 20 : 36),
      children: [
        const PageHeading(
          eyebrow: 'A cleaner community starts here',
          title: 'Your collection schedule',
          subtitle: 'Plan ahead, sort your waste, and never miss a collection.',
        ),
        const SizedBox(height: 28),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Ui.green,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.local_shipping_outlined,
                color: Ui.background,
                size: 36,
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'COLLECTION REMINDER',
                      style: TextStyle(
                        fontSize: 10,
                        color: Ui.background,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.8,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      schedules.isEmpty
                          ? 'No collections scheduled'
                          : '${schedules.first.day} collection',
                      style: const TextStyle(
                        fontSize: 25,
                        color: Ui.background,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      schedules.isEmpty
                          ? 'Check back for updates from your community.'
                          : 'Collection window: ${schedules.first.time}',
                      style: const TextStyle(color: Ui.background, height: 1.5),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Have your sorted waste ready before collection begins.',
                      style: TextStyle(color: Color(0xFF36512D), height: 1.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SurfaceCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.campaign_outlined, color: Color(0xFFE8C783)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Community update',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      announcement,
                      style: const TextStyle(color: Ui.muted, height: 1.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'Weekly collections',
          style: TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Keep each waste type in a separate, securely closed bag.',
          style: TextStyle(color: Ui.muted, height: 1.5),
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 680 ? 2 : 1;
            final width = (constraints.maxWidth - (columns - 1) * 16) / columns;
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                for (final schedule in schedules)
                  SizedBox(
                    width: width,
                    child: SurfaceCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_outlined,
                                color: Ui.green,
                                size: 20,
                              ),
                              const Spacer(),
                              Text(
                                schedule.day.toUpperCase(),
                                style: const TextStyle(
                                  color: Ui.muted,
                                  fontSize: 10,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 22),
                          Text(
                            schedule.day,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 23,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            schedule.time,
                            style: const TextStyle(color: Ui.muted),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: Ui.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              schedule.type,
                              style: const TextStyle(
                                color: Ui.green,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        if (schedules.isEmpty)
          const SurfaceCard(
            child: Text(
              'Your community has no scheduled collections yet.',
              style: TextStyle(color: Ui.muted),
            ),
          ),
        const SizedBox(height: 28),
        const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.tips_and_updates_outlined, size: 18, color: Ui.muted),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Rinse recyclable containers and keep them dry before disposal.',
                style: TextStyle(color: Ui.muted, height: 1.5),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
