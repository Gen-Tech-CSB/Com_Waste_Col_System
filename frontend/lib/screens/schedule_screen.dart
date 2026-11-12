import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../providers/schedule_provider.dart';
import '../providers/announcement_provider.dart';
import '../widgets/ui.dart';

class ScheduleScreen extends StatefulWidget {
  final VoidCallback? onReport;
  final VoidCallback? onGuide;
  final VoidCallback? onProfile;
  const ScheduleScreen({
    super.key,
    this.onReport,
    this.onGuide,
    this.onProfile,
  });
  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  String _filter = 'All';
  final Set<Schedule> _expanded = {};
  bool _announcementOpen = false;
  static const _types = [
    'All',
    'Biodegradable',
    'Non-Biodegradable',
    'Recyclable',
    'Special',
  ];
  List<String> _tips(String type) => switch (type) {
    'Biodegradable' => [
      'Keep food scraps and leaves separate from other waste.',
      'Use a securely closed container or bag.',
    ],
    'Recyclable' => [
      'Rinse containers and keep recyclable materials dry.',
      'Separate paper, bottles, and cans from food waste.',
    ],
    'Special' => [
      'Keep batteries and bulbs separate from everyday waste.',
      'Ask your waste office about accepted collection arrangements.',
    ],
    _ => [
      'Keep this waste separate from biodegradable materials.',
      'Secure the bag before placing it out for collection.',
    ],
  };
  Color _color(BuildContext context, String type) => switch (type) {
    'Biodegradable' => Ui.of(context).green,
    'Recyclable' => Ui.of(context).blue,
    'Special' => Ui.of(context).danger,
    _ => Ui.of(context).amber,
  };
  IconData _icon(String type) => switch (type) {
    'Biodegradable' => Icons.eco_outlined,
    'Recyclable' => Icons.recycling,
    'Special' => Icons.battery_alert_outlined,
    _ => Icons.delete_outline,
  };
  Widget _action(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback action,
    bool compact,
  ) {
    final colors = Ui.of(context);
    return InteractiveCard(
      onTap: action,
      label: title,
      padding: EdgeInsets.all(compact ? 12 : 18),
      child: compact
          ? ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 80),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: colors.green, size: 25),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.text,
                      fontSize: 12,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
          : Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: colors.green.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: colors.green, size: 22),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: colors.text,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: colors.muted,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.north_east, color: colors.muted, size: 17),
              ],
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Ui.of(context);
    final schedules = context.watch<ScheduleProvider>().schedules;
    final announcement = context
        .watch<AnnouncementProvider>()
        .currentAnnouncement;
    final visible = schedules
        .where((s) => _filter == 'All' || s.type == _filter)
        .toList();
    final reducedMotion =
        MediaQuery.maybeOf(context)?.disableAnimations == true;
    return ListView(
      padding: EdgeInsets.all(MediaQuery.sizeOf(context).width < 600 ? 20 : 36),
      children: [
        const PageHeading(
          eyebrow: 'Small habits. Cleaner streets.',
          title: 'Your collection schedule',
          subtitle: 'Everything you need for a cleaner week, in one place.',
        ),
        const SizedBox(height: 26),
        Container(
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colors.green,
                Color.lerp(
                  colors.green,
                  colors.isDark
                      ? const Color(0xFFD5F4BC)
                      : const Color(0xFF1B5230),
                  0.45,
                )!,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(26),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 14,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Icon(
                    Icons.local_shipping_outlined,
                    color: colors.onAccent,
                    size: 32,
                  ),
                  Text(
                    'WEEKLY COLLECTION',
                    style: TextStyle(
                      color: colors.onAccent,
                      fontSize: 11,
                      letterSpacing: 1.8,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Text(
                schedules.isEmpty
                    ? 'A fresh week starts here.'
                    : '${schedules.first.day}, sorted.',
                style: TextStyle(
                  color: colors.onAccent,
                  fontSize: 32,
                  height: 1.15,
                  letterSpacing: -0.8,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                schedules.isEmpty
                    ? 'Check back for collection updates.'
                    : 'Collection window: ${schedules.first.time}',
                style: TextStyle(color: colors.onAccent, height: 1.5),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: colors.onAccent.withValues(alpha: 0.09),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      '${schedules.length} weekly collections',
                      style: TextStyle(
                        color: colors.onAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: colors.onAccent.withValues(alpha: 0.09),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      'Schedule preview',
                      style: TextStyle(color: colors.onAccent, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (widget.onReport != null &&
            widget.onGuide != null &&
            widget.onProfile != null) ...[
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              const count = 3;
              final width = (constraints.maxWidth - (count - 1) * 14) / count;
              return Wrap(
                spacing: 14,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: width,
                    child: _action(
                      context,
                      Icons.add_circle_outline,
                      'Report an issue',
                      'Help improve your area',
                      widget.onReport!,
                      width < 250,
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: _action(
                      context,
                      Icons.spa_outlined,
                      'Sorting guide',
                      'Find the right waste category',
                      widget.onGuide!,
                      width < 250,
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: _action(
                      context,
                      Icons.person_outline,
                      'My profile',
                      'Keep your details up to date',
                      widget.onProfile!,
                      width < 250,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
        const SizedBox(height: 20),
        InteractiveCard(
          onTap: () => setState(() => _announcementOpen = !_announcementOpen),
          label: 'Toggle community update',
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.campaign_outlined, color: colors.amber),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Community update',
                      style: TextStyle(
                        color: colors.text,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    AnimatedSize(
                      duration: reducedMotion
                          ? Duration.zero
                          : const Duration(milliseconds: 200),
                      alignment: Alignment.topLeft,
                      child: Text(
                        announcement,
                        maxLines: _announcementOpen ? null : 2,
                        overflow: _announcementOpen
                            ? TextOverflow.visible
                            : TextOverflow.ellipsis,
                        style: TextStyle(color: colors.muted, height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                _announcementOpen ? Icons.expand_less : Icons.expand_more,
                color: colors.muted,
                size: 20,
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Weekly collections',
          style: TextStyle(
            color: colors.text,
            fontSize: 21,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Explore waste types and tap a collection for preparation tips.',
          style: TextStyle(color: colors.muted, height: 1.5),
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _types
              .map(
                (type) => ChoiceChip(
                  label: Text(type),
                  selected: _filter == type,
                  onSelected: (_) => setState(() => _filter = type),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 18),
        if (visible.isEmpty)
          SurfaceCard(
            child: Column(
              children: [
                Icon(
                  Icons.event_available_outlined,
                  color: colors.muted,
                  size: 32,
                ),
                const SizedBox(height: 14),
                Text(
                  'No collections in this category',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colors.text,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try another waste type to explore the schedule preview.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colors.muted, height: 1.5),
                ),
                if (_filter != 'All')
                  TextButton(
                    onPressed: () => setState(() => _filter = 'All'),
                    child: const Text('Show all collections'),
                  ),
              ],
            ),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 680 ? 2 : 1;
              final width =
                  (constraints.maxWidth - (columns - 1) * 16) / columns;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: visible.map((schedule) {
                  final expanded = _expanded.contains(schedule);
                  final color = _color(context, schedule.type);
                  return SizedBox(
                    width: width,
                    child: InteractiveCard(
                      onTap: () => setState(() {
                        if (expanded) {
                          _expanded.remove(schedule);
                        } else {
                          _expanded.add(schedule);
                        }
                      }),
                      label: '${schedule.day} collection preparation tips',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.10),
                                  borderRadius: BorderRadius.circular(13),
                                ),
                                child: Icon(
                                  _icon(schedule.type),
                                  color: color,
                                  size: 24,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                schedule.day.toUpperCase(),
                                style: TextStyle(
                                  color: colors.muted,
                                  fontSize: 10,
                                  letterSpacing: 1.4,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 22),
                          Text(
                            schedule.day,
                            style: TextStyle(
                              color: colors.text,
                              fontSize: 25,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            schedule.time,
                            style: TextStyle(color: colors.muted),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            schedule.type,
                            style: TextStyle(
                              color: color,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Divider(color: colors.border),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  expanded
                                      ? 'Hide preparation tips'
                                      : 'View preparation tips',
                                  style: TextStyle(
                                    color: colors.muted,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Icon(
                                expanded
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                                size: 20,
                                color: colors.muted,
                              ),
                            ],
                          ),
                          AnimatedSize(
                            duration: reducedMotion
                                ? Duration.zero
                                : const Duration(milliseconds: 200),
                            alignment: Alignment.topLeft,
                            child: expanded
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 14),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: _tips(schedule.type)
                                          .map(
                                            (tip) => Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: 10,
                                              ),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Icon(
                                                    Icons.check_circle_outline,
                                                    size: 16,
                                                    color: color,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      tip,
                                                      style: TextStyle(
                                                        color: colors.muted,
                                                        fontSize: 12,
                                                        height: 1.5,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        const SizedBox(height: 22),
        Text(
          'Preview schedules are demonstration data. Confirm your actual collection arrangements with your community.',
          style: TextStyle(color: colors.muted, fontSize: 11, height: 1.5),
        ),
      ],
    );
  }
}
