import 'package:material_ui/material_ui.dart';

import '../services/api_client.dart';
import '../services/form_validation.dart';
import '../widgets/ui.dart';

class RegisterScreen extends StatefulWidget {
  final ApiClient? api;
  const RegisterScreen({super.key, this.api});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _scroll = ScrollController();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  late final ApiClient _api = widget.api ?? ApiClient.instance;
  List<Map<String, dynamic>> _areas = [];
  int? _areaId;
  bool _loadingAreas = true;
  bool _saving = false;
  bool _obscure = true;
  String? _areaError;
  bool _submitted = false;
  Map<String, String> _fields = {};

  @override
  void initState() {
    super.initState();
    _loadAreas();
  }

  @override
  void dispose() {
    _scroll.dispose();
    for (final controller in [_name, _email, _phone, _password, _confirm]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadAreas() async {
    setState(() {
      _loadingAreas = true;
      _areaError = null;
    });
    try {
      final result = await _api.request('GET', '/areas');
      final data = (result['data'] as List)
          .map((row) => Map<String, dynamic>.from(row))
          .toList();
      if (mounted) setState(() => _areas = data);
    } catch (e) {
      if (mounted) {
        setState(
          () => _areaError = e is ApiException
              ? e.message
              : 'Could not load collection areas.',
        );
      }
    } finally {
      if (mounted) setState(() => _loadingAreas = false);
    }
  }

  Future<void> _submit() async {
    if (_saving) return;
    setState(() {
      _fields = {};
      _submitted = true;
    });
    if (!_form.currentState!.validate()) {
      _showTop();
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    try {
      await _api.request(
        'POST',
        '/auth/register',
        body: {
          'full_name': _name.text.trim(),
          'email': _email.text.trim().toLowerCase(),
          'password': _password.text,
          if (_phone.text.trim().isNotEmpty) 'phone': _phone.text.trim(),
          if (_areaId != null) 'area_id': _areaId,
        },
      );
      if (!mounted) return;
      // Only show success after the backend confirms the database insert.
      showNotice(
        context,
        'Account created. You can now sign in.',
        isError: false,
      );
      Navigator.pop(context);
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _fields = e.fields;
        });
        showNotice(
          context,
          e.fields.isEmpty ? e.message : 'Check the highlighted fields.',
        );
        if (e.fields.isNotEmpty) _showTop();
      }
    } catch (_) {
      if (mounted) {
        showNotice(context, 'Could not create your account. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showTop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scroll.hasClients) {
        _scroll.animateTo(
          0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _field(
    TextEditingController controller,
    String label,
    String keyName, {
    bool password = false,
    TextInputType? keyboard,
    String? Function(String?)? validator,
    List<String>? autofill,
  }) => TextFormField(
    controller: controller,
    enabled: !_saving,
    obscureText: password && _obscure,
    keyboardType: keyboard,
    autofillHints: autofill,
    style: TextStyle(color: Ui.of(context).text),
    autovalidateMode: _submitted
        ? AutovalidateMode.onUserInteraction
        : AutovalidateMode.disabled,
    textInputAction: TextInputAction.next,
    onChanged: (_) {
      if (_fields.containsKey(keyName)) setState(() => _fields.remove(keyName));
    },
    decoration: InputDecoration(
      labelText: label,
      errorText: _fields[keyName],
      errorMaxLines: 2,
      errorStyle: const TextStyle(fontSize: 12),
      hintText: keyName == 'email' ? 'name@example.com' : null,
      helperText: keyName == 'password' ? 'At least 8 characters' : null,
      prefixIcon: Icon(
        password
            ? Icons.lock_outline
            : keyName == 'email'
            ? Icons.mail_outline
            : keyName == 'phone'
            ? Icons.phone_outlined
            : Icons.person_outline,
      ),
      suffixIcon: password
          ? IconButton(
              tooltip: _obscure ? 'Show passwords' : 'Hide passwords',
              onPressed: () => setState(() => _obscure = !_obscure),
              icon: Icon(
                _obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
            )
          : null,
    ),
    validator: validator,
  );

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_saving,
    child: Scaffold(
      backgroundColor: Ui.of(context).background,
      appBar: AppBar(
        title: const Text('Create account'),
        backgroundColor: Ui.of(context).background,
        foregroundColor: Ui.of(context).text,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: ListView(
            controller: _scroll,
            padding: const EdgeInsets.all(24),
            children: [
              const PageHeading(
                eyebrow: 'Join your community',
                title: 'Create your account.',
                subtitle: 'A small step toward a cleaner community.',
              ),
              const SizedBox(height: 24),
              SurfaceCard(
                child: AutofillGroup(
                  child: Form(
                    key: _form,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'PERSONAL DETAILS',
                          style: TextStyle(
                            color: Ui.of(context).muted,
                            fontSize: 10,
                            letterSpacing: 1.8,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 18),
                        _field(
                          _name,
                          'Full name',
                          'full_name',
                          autofill: [AutofillHints.name],
                          validator: (v) => (v?.trim().length ?? 0) < 2
                              ? 'Enter your full name (at least 2 characters).'
                              : null,
                        ),
                        const SizedBox(height: 18),
                        _field(
                          _email,
                          'Email address',
                          'email',
                          keyboard: TextInputType.emailAddress,
                          autofill: [AutofillHints.email],
                          validator: validateEmail,
                        ),
                        const SizedBox(height: 18),
                        _field(
                          _phone,
                          'Phone number (optional)',
                          'phone',
                          keyboard: TextInputType.phone,
                          autofill: [AutofillHints.telephoneNumber],
                          validator: (v) => (v?.trim().length ?? 0) > 20
                              ? 'Use 20 characters or fewer.'
                              : null,
                        ),
                        const SizedBox(height: 18),
                        const SizedBox(height: 6),
                        Text(
                          'KEEP IT SECURE',
                          style: TextStyle(
                            color: Ui.of(context).muted,
                            fontSize: 10,
                            letterSpacing: 1.8,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 18),
                        _field(
                          _password,
                          'Password',
                          'password',
                          password: true,
                          autofill: [AutofillHints.newPassword],
                          validator: validateNewPassword,
                        ),
                        const SizedBox(height: 18),
                        _field(
                          _confirm,
                          'Confirm password',
                          'confirm',
                          password: true,
                          validator: (v) => v != _password.text
                              ? 'Passwords do not match.'
                              : null,
                        ),
                        const SizedBox(height: 14),
                        ListenableBuilder(
                          listenable: Listenable.merge([_password, _confirm]),
                          builder: (context, _) {
                            final valid =
                                validateNewPassword(_password.text) == null;
                            final matches =
                                _confirm.text.isNotEmpty &&
                                _confirm.text == _password.text;
                            return Wrap(
                              spacing: 16,
                              runSpacing: 8,
                              children: [
                                for (final item in [
                                  (valid, 'Password meets requirements'),
                                  (matches, 'Passwords match'),
                                ])
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        item.$1
                                            ? Icons.check_circle
                                            : Icons.radio_button_unchecked,
                                        size: 16,
                                        color: item.$1
                                            ? Ui.of(context).green
                                            : Ui.of(context).muted,
                                      ),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          item.$2,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: item.$1
                                                ? Ui.of(context).green
                                                : Ui.of(context).muted,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        Theme(
                          data: Theme.of(context)
                              .copyWith(dividerColor: Colors.transparent),
                          child: Material(
                            color: Ui.of(context).surface,
                            child: ExpansionTile(
                              tilePadding: EdgeInsets.zero,
                              childrenPadding: const EdgeInsets.only(
                                bottom: 12,
                              ),
                              leading: Icon(
                                Icons.location_on_outlined,
                                color: Ui.of(context).green,
                              ),
                              title: Text(
                                'Collection area (optional)',
                                style: TextStyle(
                                  color: Ui.of(context).text,
                                  fontSize: 14,
                                ),
                              ),
                              subtitle: Text(
                                'Choose your barangay and purok',
                                style: TextStyle(
                                  color: Ui.of(context).muted,
                                  fontSize: 12,
                                ),
                              ),
                              children: [
                                if (_loadingAreas)
                                  const LinearProgressIndicator()
                                else if (_areaError != null)
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Areas are unavailable. You can choose one later.',
                                          style: TextStyle(
                                            color: Ui.of(context).muted,
                                            fontSize: 12,
                                            height: 1.5,
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: _saving ? null : _loadAreas,
                                        child: const Text('Retry'),
                                      ),
                                    ],
                                  )
                                else if (_areas.isEmpty)
                                  Text(
                                    'No collection areas have been added yet.',
                                    style: TextStyle(
                                      color: Ui.of(context).muted,
                                    ),
                                  )
                                else
                                  DropdownButtonFormField<int>(
                                    isExpanded: true,
                                    initialValue: _areaId,
                                    dropdownColor: Ui.of(context).surface,
                                    style: TextStyle(
                                      color: Ui.of(context).text,
                                    ),
                                    decoration: InputDecoration(
                                      labelText: 'Barangay / Purok',
                                      errorText: _fields['area_id'],
                                    ),
                                    items: [
                                      const DropdownMenuItem<int>(
                                        value: null,
                                        child: Text('Choose later'),
                                      ),
                                      ..._areas.map(
                                        (a) => DropdownMenuItem(
                                          value: a['id'] as int,
                                          child: Text(
                                            '${a['barangay_name']} / ${a['area_name']}',
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ],
                                    onChanged: _saving
                                        ? null
                                        : (value) =>
                                              setState(() => _areaId = value),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        FilledButton(
                          onPressed: _saving ? null : _submit,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.all(18),
                          ),
                          child: _saving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Create account'),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: _saving
                              ? null
                              : () => Navigator.pop(context),
                          child: const Text('Already have an account? Sign in'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
