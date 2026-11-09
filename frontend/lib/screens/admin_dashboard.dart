import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/announcement_provider.dart';
import '../services/api_client.dart';
import '../widgets/ui.dart';
import 'login_screen.dart';
import 'manage_schedules.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';

const _statuses = <String, String>{
  'submitted': 'Submitted',
  'under_review': 'Under review',
  'in_progress': 'In progress',
  'resolved': 'Resolved',
  'rejected': 'Rejected',
};
const _transitions = <String, List<String>>{
  'submitted': ['under_review', 'rejected'],
  'under_review': ['in_progress', 'resolved', 'rejected'],
  'in_progress': ['resolved', 'rejected'],
  'resolved': [],
  'rejected': [],
};

class AdminDashboard extends StatefulWidget {
  final ApiClient? api;
  const AdminDashboard({super.key, this.api});
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  late final ApiClient _api = widget.api ?? ApiClient.instance;
  Map<String, dynamic> _summary = {};
  List<Map<String, dynamic>> _reports = [];
  String? _status;
  String? _error;
  bool _loading = true;
  int _page = 1;
  int _total = 0;
  int _generation = 0;
  int? _opening;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final generation = ++_generation;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await Future.wait([
        _api.request('GET', '/reports/summary', authenticated: true),
        _api.request(
          'GET',
          '/reports?page=$_page&limit=10${_status == null ? '' : '&status=$_status'}',
          authenticated: true,
        ),
      ]);
      final summary = Map<String, dynamic>.from(result[0]['data']);
      final reports = (result[1]['data'] as List)
          .map((r) => Map<String, dynamic>.from(r))
          .toList();
      final total = result[1]['meta']['total'] as int;
      if (mounted && generation == _generation) {
        setState(() {
          _summary = summary;
          _reports = reports;
          _total = total;
        });
      }
    } catch (e) {
      if (mounted && generation == _generation) {
        setState(
          () => _error = e is ApiException
              ? e.message
              : 'Could not load dashboard data. Please try again.',
        );
      }
    } finally {
      if (mounted && generation == _generation) {
        setState(() => _loading = false);
      }
    }
  }

  void _signOut() {
    _api.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => LoginScreen(api: widget.api)),
      (_) => false,
    );
  }

  Future<void> _postAnnouncement() async {
    final controller = TextEditingController();
    final route = DialogRoute<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Ui.of(context).surface,
        title: Text(
          'Community announcement',
          style: TextStyle(color: Ui.of(context).text),
        ),
        content: SizedBox(
          width: 440,
          child: TextField(
            controller: controller,
            maxLines: 4,
            maxLength: 500,
            style: TextStyle(color: Ui.of(context).text),
            decoration: const InputDecoration(labelText: 'Announcement'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(dialogContext, controller.text.trim());
              }
            },
            child: const Text('Post announcement'),
          ),
        ],
      ),
    );
    final text = await Navigator.of(context).push(route);
    if (text != null && mounted) {
      context.read<AnnouncementProvider>().updateAnnouncement(text);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Announcement updated.')));
    }
    await route.completed;
    controller.dispose();
  }

  Future<void> _openReport(int id) async {
    if (_opening != null) return;
    setState(() => _opening = id);
    try {
      final result = await _api.request(
        'GET',
        '/reports/$id',
        authenticated: true,
      );
      final report = Map<String, dynamic>.from(result['data']);
      if (!mounted) return;
      await _showReport(report);
    } catch (e) {
      if (mounted) {
        setState(
          () => _error = e is ApiException
              ? e.message
              : 'Could not open this report.',
        );
      }
    } finally {
      if (mounted) setState(() => _opening = null);
    }
  }

  Future<void> _showReport(Map<String, dynamic> report) async {
    final remarks = TextEditingController();
    String? nextStatus;
    String? error;
    bool saving = false;
    final choices = _api.user?['role'] == 'admin'
        ? (_transitions[report['status']] ?? <String>[])
        : <String>[];
    final route = DialogRoute<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, update) => PopScope(
          canPop: !saving,
          child: AlertDialog(
            backgroundColor: Ui.of(context).surface,
            title: Text(
              report['reference_no']?.toString() ?? 'Report #${report['id']}',
              style: TextStyle(color: Ui.of(context).text),
            ),
            content: SizedBox(
              width: 480,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _label(report['category']),
                      style: TextStyle(
                        color: Ui.of(context).green,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      report['description']?.toString() ?? '',
                      style: TextStyle(color: Ui.of(context).text, height: 1.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${report['reporter_name']}\n${report['barangay_name']} / ${report['area_name']}',
                      style: TextStyle(
                        color: Ui.of(context).muted,
                        height: 1.5,
                      ),
                    ),
                    if (report['location_note'] != null)
                      Text(
                        report['location_note'].toString(),
                        style: TextStyle(color: Ui.of(context).muted),
                      ),
                    const SizedBox(height: 16),
                    Text(
                      'Status: ${_statuses[report['status']] ?? report['status']}',
                      style: TextStyle(color: Ui.of(context).green),
                    ),
                    if (choices.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        dropdownColor: Ui.of(context).surface,
                        style: TextStyle(color: Ui.of(context).text),
                        decoration: const InputDecoration(
                          labelText: 'Update status',
                        ),
                        items: choices
                            .map(
                              (s) => DropdownMenuItem(
                                value: s,
                                child: Text(_statuses[s]!),
                              ),
                            )
                            .toList(),
                        onChanged: saving
                            ? null
                            : (value) => update(() => nextStatus = value),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: remarks,
                        enabled: !saving,
                        maxLength: 500,
                        maxLines: 3,
                        style: TextStyle(color: Ui.of(context).text),
                        decoration: const InputDecoration(
                          labelText: 'Remarks',
                          hintText: 'Required when rejecting a report',
                        ),
                      ),
                    ],
                    if (error != null) InlineError(message: error!),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: saving ? null : () => Navigator.pop(dialogContext),
                child: const Text('Close'),
              ),
              if (choices.isNotEmpty)
                FilledButton(
                  onPressed: saving || nextStatus == null
                      ? null
                      : () async {
                          if (nextStatus == 'rejected' &&
                              remarks.text.trim().length < 3) {
                            update(
                              () => error = 'Add a reason of at least 3 characters before rejecting.',
                            );
                            return;
                          }
                          update(() {
                            saving = true;
                            error = null;
                          });
                          try {
                            await _api.request(
                              'PATCH',
                              '/reports/${report['id']}/status',
                              authenticated: true,
                              body: {
                                'status': nextStatus,
                                if (remarks.text.trim().isNotEmpty)
                                  'remarks': remarks.text.trim(),
                              },
                            );
                            if (!dialogContext.mounted) return;
                            Navigator.pop(dialogContext);
                            if (mounted) {
                              ScaffoldMessenger.of(this.context).showSnackBar(
                                const SnackBar(
                                  content: Text('Report status updated.'),
                                ),
                              );
                              await _load();
                            }
                          } catch (e) {
                            if (e is ApiException &&
                                e.status == 401 &&
                                dialogContext.mounted) {
                              Navigator.pop(dialogContext);
                              if (mounted) setState(() => _error = e.message);
                              return;
                            }
                            if (dialogContext.mounted) {
                              update(() {
                                saving = false;
                                error = e is ApiException
                                    ? e.message
                                    : 'Could not update this report.';
                              });
                            }
                          }
                        },
                  child: Text(saving ? 'Saving…' : 'Save status'),
                ),
            ],
          ),
        ),
      ),
    );
    await Navigator.of(context).push(route);
    await route.completed;
    remarks.dispose();
  }

  String _label(dynamic value) => value.toString().replaceAll('_', ' ');
  Color _color(String status) => switch (status) {
    'resolved' => Ui.of(context).green,
    'rejected' => Ui.of(context).danger,
    'in_progress' => Ui.of(context).blue,
    _ => Ui.of(context).amber,
  };

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Ui.of(context).background,
    appBar: AppBar(
      backgroundColor: Ui.of(context).background,
      foregroundColor: Ui.of(context).text,
      title: const Text('Admin workspace'),
      actions: [
        IconButton(
          tooltip: 'Settings',
          icon: const Icon(Icons.settings_outlined),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => SettingsScreen(api: _api)),
          ),
        ),
        IconButton(
          tooltip: 'My profile',
          icon: const Icon(Icons.person_outline),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => Scaffold(
                backgroundColor: Ui.of(context).background,
                appBar: AppBar(title: const Text('My profile')),
                body: ProfileScreen(api: _api),
              ),
            ),
          ),
        ),
        if (_api.user?['role'] == 'admin')
          PopupMenuButton<String>(
            tooltip: 'Community tools',
            onSelected: (value) {
              if (value == 'announcement') {
                _postAnnouncement();
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ManageSchedules()),
                );
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'announcement',
                child: Text('Post announcement'),
              ),
              const PopupMenuItem(
                value: 'schedules',
                child: Text('Manage schedules'),
              ),
            ],
          ),
        IconButton(
          tooltip: 'Refresh dashboard',
          onPressed: _loading ? null : _load,
          icon: const Icon(Icons.refresh),
        ),
        IconButton(
          tooltip: 'Sign out',
          onPressed: _signOut,
          icon: const Icon(Icons.logout),
        ),
      ],
    ),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: ListView(
          padding: EdgeInsets.all(
            MediaQuery.sizeOf(context).width < 600 ? 20 : 36,
          ),
          children: [
            const PageHeading(
              eyebrow: 'Community operations',
              title: 'Every report matters.',
              subtitle: 'Review community issues and keep residents informed with timely updates.',
            ),
            const SizedBox(height: 24),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null) ...[
              InlineError(
                message: _error!,
                onRetry: _api.token == null ? null : _load,
              ),
              if (_api.token == null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: _signOut,
                    child: const Text('Sign in again'),
                  ),
                ),
            ] else ...[
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 900 ? 4 : 2;
                  final stats = [
                    ('Total reports', _summary['total'], Icons.folder_outlined),
                    (
                      'Awaiting review',
                      _summary['submitted'],
                      Icons.inbox_outlined,
                    ),
                    ('In progress', _summary['in_progress'], Icons.autorenew),
                    ('Resolved', _summary['resolved'], Icons.task_alt),
                  ];
                  return Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    children: stats
                        .map(
                          (s) => SizedBox(
                            width:
                                (constraints.maxWidth - (columns - 1) * 14) /
                                columns,
                            child: SurfaceCard(
                              padding: const EdgeInsets.all(18),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(s.$3, color: Ui.of(context).green),
                                  const SizedBox(height: 18),
                                  Text(
                                    '${s.$2 ?? 0}',
                                    style: TextStyle(
                                      color: Ui.of(context).text,
                                      fontSize: 30,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    s.$1,
                                    style: TextStyle(
                                      color: Ui.of(context).muted,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
              const SizedBox(height: 32),
              Text(
                'Community reports',
                style: TextStyle(
                  color: Ui.of(context).text,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('All'),
                    selected: _status == null,
                    onSelected: (_) {
                      setState(() {
                        _status = null;
                        _page = 1;
                      });
                      _load();
                    },
                  ),
                  ..._statuses.entries.map(
                    (s) => ChoiceChip(
                      label: Text(s.value),
                      selected: _status == s.key,
                      onSelected: (_) {
                        setState(() {
                          _status = s.key;
                          _page = 1;
                        });
                        _load();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (_reports.isEmpty)
                SurfaceCard(
                  child: Column(
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        color: Ui.of(context).green,
                        size: 36,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No reports to show',
                        style: TextStyle(
                          color: Ui.of(context).text,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Reports matching this filter will appear here.',
                        style: TextStyle(color: Ui.of(context).muted),
                      ),
                    ],
                  ),
                )
              else
                ..._reports.map(
                  (r) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SurfaceCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            spacing: 12,
                            runSpacing: 10,
                            children: [
                              Text(
                                r['reference_no']?.toString() ??
                                    'Report #${r['id']}',
                                style: TextStyle(
                                  color: Ui.of(context).muted,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                _statuses[r['status']] ??
                                    r['status'].toString(),
                                style: TextStyle(
                                  color: _color(r['status']),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _label(r['category']),
                            style: TextStyle(
                              color: Ui.of(context).text,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            r['description']?.toString() ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Ui.of(context).muted,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${r['reporter_name']} · ${r['barangay_name']} / ${r['area_name']}',
                            style: TextStyle(
                              color: Ui.of(context).muted,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: _opening != null
                                  ? null
                                  : () => _openReport(r['id']),
                              icon: const Icon(Icons.arrow_forward, size: 18),
                              label: Text(
                                _opening == r['id']
                                    ? 'Opening…'
                                    : 'Review report',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 8,
                children: [
                  Text(
                    '$_total reports · Page $_page',
                    style: TextStyle(color: Ui.of(context).muted),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Previous page',
                        onPressed: _page > 1
                            ? () {
                                setState(() => _page--);
                                _load();
                              }
                            : null,
                        icon: const Icon(Icons.chevron_left),
                      ),
                      IconButton(
                        tooltip: 'Next page',
                        onPressed: _page * 10 < _total
                            ? () {
                                setState(() => _page++);
                                _load();
                              }
                            : null,
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    ),
  );
}
