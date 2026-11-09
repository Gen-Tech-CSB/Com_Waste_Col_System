import '../services/api_client.dart';
import '../services/form_validation.dart';

import '../widgets/ui.dart';

import 'package:flutter/material.dart';

import 'resident_home.dart';
import 'admin_dashboard.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  final ApiClient? api;
  const LoginScreen({super.key, this.api});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;
  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading || !_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = widget.api ?? ApiClient.instance;
      final user = await api.login(_emailCtrl.text, _passCtrl.text);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => user['role'] != 'resident'
              ? AdminDashboard(api: api)
              : ResidentHome(api: api),
        ),
      );
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Unable to sign in. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Ui.of(context).background,
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 950;
          return Row(
            children: [
              if (wide)
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(24),
                    padding: const EdgeInsets.all(48),
                    decoration: BoxDecoration(
                      color: Ui.of(context).green,
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.recycling,
                                size: 32,
                                color: Ui.of(context).onAccent,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Community Waste',
                                style: TextStyle(
                                  color: Ui.of(context).onAccent,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 48),
                          Icon(
                            Icons.spa_outlined,
                            size: 88,
                            color: Ui.of(context).onAccent
                                .withValues(alpha: 0.65),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            'A little care.\nA cleaner\ncommunity.',
                            style: TextStyle(
                              color: Ui.of(context).onAccent,
                              fontSize: 48,
                              height: 1.1,
                              letterSpacing: -2,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Stay on top of collections, report issues, and build better waste habits together.',
                            style: TextStyle(
                              color: Ui.of(context).onAccent
                                  .withValues(alpha: 0.8),
                              fontSize: 16,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 48),
                          Text(
                            'SORT SMART. LIVE CLEAN.',
                            style: TextStyle(
                              color: Ui.of(context).onAccent,
                              fontSize: 10,
                              letterSpacing: 2,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: AutofillGroup(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (!wide) ...[
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Icon(
                                    Icons.recycling,
                                    size: 42,
                                    color: Ui.of(context).green,
                                  ),
                                ),
                                const SizedBox(height: 32),
                              ],
                              const PageHeading(
                                eyebrow: 'Community Waste',
                                title: 'Welcome back.',
                                subtitle: 'Sign in to take care of your corner of the world.',
                              ),
                              const SizedBox(height: 32),
                              if (_error != null) ...[
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF422A28),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _error!,
                                    style: const TextStyle(
                                      color: Color(0xFFFFB4AB),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                              ],
                              TextFormField(
                                controller: _emailCtrl,
                                style: TextStyle(color: Ui.of(context).text),
                                keyboardType: TextInputType.emailAddress,
                                autofillHints: const [AutofillHints.username],
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  labelText: 'Email address',
                                  hintText: 'you@example.com',
                                  prefixIcon: Icon(Icons.mail_outline),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter your email address.';
                                  }
                                  return validateEmail(value);
                                },
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: _passCtrl,
                                style: TextStyle(color: Ui.of(context).text),
                                obscureText: _obscure,
                                autofillHints: const [AutofillHints.password],
                                onFieldSubmitted: (_) => _submit(),
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    tooltip: _obscure
                                        ? 'Show password'
                                        : 'Hide password',
                                    onPressed: () =>
                                        setState(() => _obscure = !_obscure),
                                    icon: Icon(
                                      _obscure
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                    ),
                                  ),
                                ),
                                validator: (value) =>
                                    value == null || value.isEmpty
                                    ? 'Please enter your password.'
                                    : value.length < 8
                                    ? 'Password must be at least 8 characters.'
                                    : null,
                              ),
                              const SizedBox(height: 28),
                              SizedBox(
                                height: 54,
                                child: FilledButton(
                                  onPressed: _loading ? null : _submit,
                                  child: _loading
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text(
                                          'Log In',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Wrap(
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(
                                    "New to the community?",
                                    style: TextStyle(
                                      color: Ui.of(context).muted,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: _loading
                                        ? null
                                        : () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => RegisterScreen(
                                                api: widget.api,
                                              ),
                                            ),
                                          ),
                                    child: const Text('Create an account'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    ),
  );
}
