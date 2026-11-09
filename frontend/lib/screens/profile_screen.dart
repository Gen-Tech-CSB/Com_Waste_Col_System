import 'package:flutter/material.dart';

import '../services/api_client.dart';
import '../widgets/ui.dart';
import 'login_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  final ApiClient? api;
  final VoidCallback? onChanged;
  const ProfileScreen({super.key, this.api, this.onChanged});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ApiClient _api = widget.api ?? ApiClient.instance;
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  Map<String, dynamic>? _profile;
  List<Map<String, dynamic>> _areas = [];
  int? _areaId;
  bool _loading = true;
  bool _areasLoading = true;
  bool _saving = false;
  bool _dirty = false;
  String? _error;
  String? _areaError;
  Map<String, String> _fields = {};
  int _areaGeneration = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _apply(Map<String, dynamic> profile) {
    _profile = profile;
    _api.user = profile;
    _name.text = profile['full_name'] as String;
    _phone.text = profile['phone']?.toString() ?? '';
    _areaId = profile['area_id'] as int?;
    _dirty = false;
    _fields = {};
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await _api.request('GET', '/auth/me', authenticated: true);
      final profile = Map<String, dynamic>.from(result['data']);
      if (profile['full_name'] is! String || profile['email'] is! String) {
        throw const ApiException('Could not read your account details.');
      }
      if (!mounted) return;
      setState(() {
        _apply(profile);
        _loading = false;
      });
      widget.onChanged?.call();
      await _loadAreas();
    } catch (e) {
      if (mounted) {
        setState(
          () => _error = e is ApiException
              ? e.message
              : 'Could not load your profile. Please try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadAreas() async {
    final generation = ++_areaGeneration;
    setState(() => _areasLoading = true);
    try {
      final result = await _api.request('GET', '/areas');
      final areas = (result['data'] as List)
          .map((a) => Map<String, dynamic>.from(a))
          .toList();
      if (mounted && generation == _areaGeneration) {
        setState(() {
          _areas = areas;
          _areaError = null;
        });
      }
    } catch (_) {
      if (mounted && generation == _areaGeneration) {
        setState(
          () => _areaError = 'Collection areas could not be loaded. Your saved area will be kept.',
        );
      }
    } finally {
      if (mounted && generation == _areaGeneration) {
        setState(() => _areasLoading = false);
      }
    }
  }

  void _edit(String key) {
    setState(() {
      _dirty = true;
      _fields.remove(key);
    });
  }

  Future<void> _save() async {
    if (_saving || !_dirty || !_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _saving = true;
      _fields = {};
    });
    try {
      final result = await _api.request(
        'PATCH',
        '/auth/me',
        authenticated: true,
        body: {
          'full_name': _name.text.trim(),
          'phone': _phone.text.trim().isEmpty ? null : _phone.text.trim(),
          'area_id': _areaId,
        },
      );
      final profile = Map<String, dynamic>.from(result['data']);
      if (profile['full_name'] is! String || profile['email'] is! String) {
        throw const ApiException(
          'The server returned an incomplete profile. Refresh to check your saved changes.',
        );
      }
      if (!mounted) return;
      setState(() => _apply(profile));
      widget.onChanged?.call();
      showNotice(context, 'Your profile has been updated.', isError: false);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _fields = e.fields;
        if (e.status == 401) _error = e.message;
      });
      showNotice(context, e.message);
    } catch (_) {
      if (mounted) {
        showNotice(context, 'Could not save your changes. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _signOut() {
    _api.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => LoginScreen(api: widget.api)),
      (_) => false,
    );
  }

  String get _initials {
    final words = (_profile?['full_name']?.toString() ?? '')
        .trim()
        .split(RegExp(r'\s+'))
        .where((s) => s.isNotEmpty)
        .toList();
    return words.isEmpty
        ? '?'
        : words.take(2).map((s) => s.characters.first.toUpperCase()).join();
  }

  Widget _identity() => Container(
    padding: const EdgeInsets.all(26),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Ui.of(context).green.withValues(alpha: 0.16),
          Ui.of(context).surface,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: Ui.of(context).border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 36,
          backgroundColor: Ui.of(context).green,
          child: Text(
            _initials,
            style: TextStyle(
              fontSize: 26,
              color: Ui.of(context).onAccent,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 22),
        Text(
          _profile!['full_name'],
          style: TextStyle(
            color: Ui.of(context).text,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        SelectableText(
          _profile!['email'],
          style: TextStyle(color: Ui.of(context).muted, height: 1.5),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: Ui.of(context).green.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(
            '${_profile!['role'] ?? 'resident'} account',
            style: TextStyle(color: Ui.of(context).green, fontSize: 12),
          ),
        ),
        const SizedBox(height: 26),
        Divider(color: Ui.of(context).border),
        const SizedBox(height: 14),
        Text(
          'YOUR CORNER OF THE COMMUNITY',
          style: TextStyle(
            color: Ui.of(context).muted,
            fontSize: 10,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Keep your contact and collection details up to date.',
          style: TextStyle(color: Ui.of(context).muted, height: 1.6),
        ),
      ],
    ),
  );
  Widget _details() => SurfaceCard(
    child: Form(
      key: _form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Personal details',
            style: TextStyle(
              color: Ui.of(context).text,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Make yourself at home. Update the details your community uses to reach you.',
            style: TextStyle(color: Ui.of(context).muted, height: 1.5),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _name,
            enabled: !_saving,
            style: TextStyle(color: Ui.of(context).text),
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: 'Full name',
              prefixIcon: const Icon(Icons.person_outline),
              errorText: _fields['full_name'],
              errorMaxLines: 2,
            ),
            onChanged: (_) => _edit('full_name'),
            validator: (v) => (v?.trim().length ?? 0) < 2
                ? 'Use at least 2 characters.'
                : (v!.trim().length > 150
                      ? 'Use 150 characters or fewer.'
                      : null),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _phone,
            enabled: !_saving,
            style: TextStyle(color: Ui.of(context).text),
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Phone number (optional)',
              prefixIcon: const Icon(Icons.phone_outlined),
              errorText: _fields['phone'],
            ),
            onChanged: (_) => _edit('phone'),
            validator: (v) => (v?.trim().length ?? 0) > 20
                ? 'Use 20 characters or fewer.'
                : null,
          ),
          const SizedBox(height: 20),
          if (_areasLoading)
            const LinearProgressIndicator()
          else if (_areaError != null) ...[
            Text(
              _areaError!,
              style: TextStyle(
                color: Ui.of(context).muted,
                fontSize: 12,
                height: 1.5,
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _saving ? null : _loadAreas,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Reload collection areas'),
              ),
            ),
          ] else if (_areas.isNotEmpty)
            DropdownButtonFormField<int>(
              key: ValueKey('area-$_areaId'),
              isExpanded: true,
              initialValue: _areas.any((a) => a['id'] == _areaId)
                  ? _areaId
                  : null,
              dropdownColor: Ui.of(context).surface,
              style: TextStyle(color: Ui.of(context).text),
              decoration: InputDecoration(
                labelText: 'Collection area',
                prefixIcon: const Icon(Icons.location_on_outlined),
                errorText: _fields['area_id'],
                errorMaxLines: 2,
              ),
              hint: Text(
                _areaId == null ? 'Choose your area' : 'Saved area #$_areaId',
              ),
              items: [
                const DropdownMenuItem<int>(
                  value: null,
                  child: Text('No area selected'),
                ),
                ..._areas.map(
                  (a) => DropdownMenuItem<int>(
                    value: a['id'],
                    child: Text(
                      '${a['barangay_name']} / ${a['area_name']}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
              onChanged: _saving
                  ? null
                  : (value) {
                      setState(() => _areaId = value);
                      _edit('area_id');
                    },
            )
          else
            Text(
              'No collection areas are available yet.',
              style: TextStyle(color: Ui.of(context).muted),
            ),
          const SizedBox(height: 28),
          Wrap(
            alignment: WrapAlignment.end,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              if (_dirty)
                TextButton(
                  onPressed: _saving
                      ? null
                      : () => setState(() => _apply(_profile!)),
                  child: const Text('Discard changes'),
                ),
              FilledButton.icon(
                onPressed: _saving || !_dirty ? null : _save,
                icon: Icon(
                  _saving ? Icons.hourglass_top : Icons.check,
                  size: 18,
                ),
                label: Text(_saving ? 'Saving…' : 'Save changes'),
              ),
            ],
          ),
        ],
      ),
    ),
  );
  @override
  Widget build(BuildContext context) => ListView(
    padding: EdgeInsets.all(MediaQuery.sizeOf(context).width < 600 ? 20 : 36),
    children: [
      const PageHeading(
        eyebrow: 'Made for your everyday',
        title: 'Your profile',
        subtitle: 'A little about you. One place to keep it all up to date.',
      ),
      const SizedBox(height: 28),
      if (_loading)
        const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: CircularProgressIndicator(),
          ),
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
      ] else if (_profile != null) ...[
        LayoutBuilder(
          builder: (context, constraints) => constraints.maxWidth >= 760
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: _identity()),
                    const SizedBox(width: 24),
                    Expanded(flex: 3, child: _details()),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _identity(),
                    const SizedBox(height: 20),
                    _details(),
                  ],
                ),
        ),
        const SizedBox(height: 24),
        SurfaceCard(
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 12,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Account & sign-in',
                    style: TextStyle(
                      color: Ui.of(context).text,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Your account email is shown above.',
                    style: TextStyle(color: Ui.of(context).muted, fontSize: 12),
                  ),
                ],
              ),
              OutlinedButton.icon(
                onPressed: _saving ? null : _signOut,
                icon: const Icon(Icons.logout, size: 18),
                label: const Text('Sign out'),
              ),
              TextButton.icon(
                onPressed: _saving
                    ? null
                    : () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SettingsScreen(api: _api),
                        ),
                      ),
                icon: const Icon(Icons.settings_outlined, size: 18),
                label: const Text('Settings'),
              ),
            ],
          ),
        ),
      ],
    ],
  );
}
