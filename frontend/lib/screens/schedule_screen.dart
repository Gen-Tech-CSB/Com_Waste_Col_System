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
            color: Ui.of(context).green,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.local_shipping_outlined,
                color: Ui.of(context).onAccent,
                size: 36,
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'COLLECTION REMINDER',
                      style: TextStyle(
                        fontSize: 10,
                        color: Ui.of(context).onAccent,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.8,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      schedules.isEmpty
                          ? 'No collections scheduled'
                          : '${schedules.first.day} collection',
                      style: TextStyle(
                        fontSize: 25,
                        color: Ui.of(context).onAccent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      schedules.isEmpty
                          ? 'Check back for updates from your community.'
                          : 'Collection window: ${schedules.first.time}',
                      style: TextStyle(
                        color: Ui.of(context).onAccent,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Have your sorted waste ready before collection begins.',
                      style: TextStyle(
                        color: Ui.of(context).onAccent.withValues(alpha: 0.8),
                        height: 1.5,
                      ),
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
              Icon(Icons.campaign_outlined, color: Ui.of(context).amber),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Community update',
                      style: TextStyle(
                        color: Ui.of(context).text,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      announcement,
                      style: TextStyle(
                        color: Ui.of(context).muted,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Weekly collections',
          style: TextStyle(
            color: Ui.of(context).text,
            fontSize: 19,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Keep each waste type in a separate, securely closed bag.',
          style: TextStyle(color: Ui.of(context).muted, height: 1.5),
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
                              Icon(
                                Icons.calendar_today_outlined,
                                color: Ui.of(context).green,
                                size: 20,
                              ),
                              const Spacer(),
                              Text(
                                schedule.day.toUpperCase(),
                                style: TextStyle(
                                  color: Ui.of(context).muted,
                                  fontSize: 10,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 22),
                          Text(
                            schedule.day,
                            style: TextStyle(
                              color: Ui.of(context).text,
                              fontSize: 23,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            schedule.time,
                            style: TextStyle(color: Ui.of(context).muted),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: Ui.of(context).green
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              schedule.type,
                              style: TextStyle(
                                color: Ui.of(context).green,
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
          SurfaceCard(
            child: Text(
              'Your community has no scheduled collections yet.',
              style: TextStyle(color: Ui.of(context).muted),
            ),
          ),
        const SizedBox(height: 28),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.tips_and_updates_outlined,
              size: 18,
              color: Ui.of(context).muted,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Rinse recyclable containers and keep them dry before disposal.',
                style: TextStyle(color: Ui.of(context).muted, height: 1.5),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
