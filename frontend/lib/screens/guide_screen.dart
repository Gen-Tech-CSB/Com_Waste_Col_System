import 'package:material_ui/material_ui.dart';

import '../widgets/ui.dart';

class GuideScreen extends StatefulWidget {
  const GuideScreen({super.key});
  @override
  State<GuideScreen> createState() => _GuideScreenState();
}

class _GuideScreenState extends State<GuideScreen> {
  final _search = TextEditingController();
  String _query = '';
  final Set<String> _open = {};
  static const _guides = [
    (
      id: 'bio',
      title: 'Biodegradable',
      local: 'Nabubulok',
      description: 'Mga basura nga madunot.',
      examples: ['Food scraps', 'Fruit peels', 'Leaves'],
      icon: Icons.eco_outlined,
    ),
    (
      id: 'nonbio',
      title: 'Non-Biodegradable',
      local: 'Di-Nabubulok',
      description: 'Mga basura nga dili madunot.',
      examples: ['Plastic wrappers', 'Styrofoam', 'Other residual waste'],
      icon: Icons.delete_outline,
    ),
    (
      id: 'recycle',
      title: 'Recyclable',
      local: 'Nare-recycle',
      description: 'Mga basura nga pwede pa himuong bag-ong gamit.',
      examples: ['Bottles', 'Cans', 'Clean paper'],
      icon: Icons.recycling,
    ),
    (
      id: 'special',
      title: 'Special waste',
      local: 'Mapanganib',
      description: 'Mga basura nga kinahanglan ug espesyal nga pagdumala.',
      examples: ['Batteries', 'Light bulbs', 'Electronic waste'],
      icon: Icons.battery_alert_outlined,
    ),
  ];
  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Color _color(BuildContext context, String id) => switch (id) {
    'bio' => Ui.of(context).green,
    'nonbio' => Ui.of(context).amber,
    'recycle' => Ui.of(context).blue,
    _ => Ui.of(context).danger,
  };
  @override
  Widget build(BuildContext context) {
    final colors = Ui.of(context);
    final query = _query.trim().toLowerCase();
    final visible = _guides
        .where(
          (g) =>
              '${g.title} ${g.local} ${g.description} ${g.examples.join(' ')}'
                  .toLowerCase()
                  .contains(query),
        )
        .toList();
    return ListView(
      padding: EdgeInsets.all(MediaQuery.sizeOf(context).width < 600 ? 20 : 36),
      children: [
        const PageHeading(
          eyebrow: 'Sort with a little more confidence',
          title: 'Waste Segregation Guide',
          subtitle: 'Find a category, explore examples, and build a better everyday habit.',
        ),
        const SizedBox(height: 26),
        TextField(
          controller: _search,
          onChanged: (value) => setState(() => _query = value),
          style: TextStyle(color: colors.text),
          decoration: InputDecoration(
            hintText: 'Search bottles, food, batteries…',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: query.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Clear search',
                    onPressed: () {
                      _search.clear();
                      setState(() => _query = '');
                    },
                    icon: const Icon(Icons.close),
                  ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          '${visible.length} ${visible.length == 1 ? 'category' : 'categories'}${query.isEmpty ? ' to explore' : ' found'}',
          style: TextStyle(color: colors.muted, fontSize: 12),
        ),
        const SizedBox(height: 18),
        if (visible.isEmpty)
          SurfaceCard(
            child: Column(
              children: [
                Icon(Icons.search_off_outlined, color: colors.muted, size: 36),
                const SizedBox(height: 14),
                Text(
                  'No matching waste categories',
                  style: TextStyle(
                    color: colors.text,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try a common item such as bottles, leaves, or batteries.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colors.muted, height: 1.5),
                ),
                TextButton(
                  onPressed: () {
                    _search.clear();
                    setState(() => _query = '');
                  },
                  child: const Text('Clear search'),
                ),
              ],
            ),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 700 ? 2 : 1;
              final width =
                  (constraints.maxWidth - (columns - 1) * 16) / columns;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: visible.map((guide) {
                  final color = _color(context, guide.id);
                  final expanded = _open.contains(guide.id);
                  return SizedBox(
                    width: width,
                    child: InteractiveCard(
                      label: '${guide.title} examples',
                      onTap: () => setState(() {
                        if (expanded) {
                          _open.remove(guide.id);
                        } else {
                          _open.add(guide.id);
                        }
                      }),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(13),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Icon(guide.icon, size: 28, color: color),
                              ),
                              const Spacer(),
                              Icon(
                                expanded
                                    ? Icons.remove_circle_outline
                                    : Icons.add_circle_outline,
                                size: 21,
                                color: colors.muted,
                              ),
                            ],
                          ),
                          const SizedBox(height: 22),
                          Text(
                            guide.title,
                            style: TextStyle(
                              color: colors.text,
                              fontSize: 21,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            guide.local,
                            style: TextStyle(
                              color: color,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            guide.description,
                            style: TextStyle(color: colors.muted, height: 1.5),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            expanded
                                ? 'COMMON EXAMPLES'
                                : 'Tap to explore examples',
                            style: TextStyle(
                              color: colors.muted,
                              fontSize: 11,
                              letterSpacing: expanded ? 1.3 : 0,
                            ),
                          ),
                          AnimatedSize(
                            duration:
                                MediaQuery.maybeOf(context)
                                        ?.disableAnimations ==
                                    true
                                ? Duration.zero
                                : const Duration(milliseconds: 180),
                            alignment: Alignment.topLeft,
                            child: expanded
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 14),
                                    child: Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: guide.examples
                                          .map(
                                            (example) => Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 11,
                                                    vertical: 7,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: color.withValues(
                                                  alpha: 0.1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(9),
                                              ),
                                              child: Text(
                                                example,
                                                style: TextStyle(
                                                  color: color,
                                                  fontSize: 12,
                                                ),
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
        const SizedBox(height: 24),
        SurfaceCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, color: colors.green, size: 22),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Local rules come first',
                      style: TextStyle(
                        color: colors.text,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      'Accepted materials and collection arrangements can differ. Confirm current instructions and contact details with your barangay waste office.',
                      style: TextStyle(
                        color: colors.muted,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
