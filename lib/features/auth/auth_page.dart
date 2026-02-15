import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../models/auth_models.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with TickerProviderStateMixin {
  late final TabController _tabs;

  AccountType _accountType = AccountType.individual;

  final _loginEmail = TextEditingController();
  final _loginPassword = TextEditingController();

  final _signupEmail = TextEditingController();
  final _signupPassword = TextEditingController();
  final _signupConfirm = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _loginEmail.dispose();
    _loginPassword.dispose();
    _signupEmail.dispose();
    _signupPassword.dispose();
    _signupConfirm.dispose();
    super.dispose();
  }

  void _continueAfterAuth() {
    // Mock success for now.
    // In the next step, this should go to your bottom-nav home (e.g. Routes.home).
    Navigator.pushReplacementNamed(context, Routes.feed);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    final isLogin = _tabs.index == 0;
    final roleLabel = isLogin ? 'Logging in as' : 'Signing up as';

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    cs.primaryContainer,
                    cs.primaryContainer.withOpacity(0.65),
                  ],
                ),
              ),
              child: Row(
                children: [
                  Container(
                    height: 52,
                    width: 52,
                    decoration: BoxDecoration(
                      color: cs.primary.withOpacity(0.16),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(Icons.pets, size: 28, color: cs.onPrimaryContainer),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PetOpt',
                          style: t.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Browse pets, connect, and adopt responsibly.',
                          style: t.bodyMedium?.copyWith(
                            color: cs.onPrimaryContainer.withOpacity(0.85),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Login / Signup tabs
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Get started', style: t.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: TabBar(
                      controller: _tabs,
                      onTap: (_) => setState(() {}), // update "Logging in as" label
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      labelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                      unselectedLabelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      indicator: BoxDecoration(
                        color: cs.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      tabs: const [
                        Tab(text: 'Login'),
                        Tab(text: 'Sign up'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Role selector (Individual/Organization) — ✅ summary pill removed
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(roleLabel, style: t.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 10),
                  _BigSegmented<AccountType>(
                    value: _accountType,
                    left: AccountType.individual,
                    right: AccountType.organization,
                    leftLabel: 'Individual',
                    rightLabel: 'Organization',
                    leftIcon: Icons.person,
                    rightIcon: Icons.apartment,
                    onChanged: (v) => setState(() => _accountType = v),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Forms
            _SectionCard(
              child: SizedBox(
                height: 340,
                child: TabBarView(
                  controller: _tabs,
                  children: [
                    _LoginForm(
                      email: _loginEmail,
                      password: _loginPassword,
                      onSubmit: _continueAfterAuth,
                    ),
                    _SignupForm(
                      email: _signupEmail,
                      password: _signupPassword,
                      confirm: _signupConfirm,
                      onSubmit: _continueAfterAuth,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  final TextEditingController email;
  final TextEditingController password;
  final VoidCallback onSubmit;

  const _LoginForm({
    required this.email,
    required this.password,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: email,
          decoration: const InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.email),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: password,
          decoration: const InputDecoration(
            labelText: 'Password',
            prefixIcon: Icon(Icons.lock),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: onSubmit,
          icon: const Icon(Icons.login),
          label: const Text('Login'),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(54),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Forgot password flow later')),
            );
          },
          style: TextButton.styleFrom(foregroundColor: cs.primary),
          child: const Text('Forgot password?'),
        ),
      ],
    );
  }
}

class _SignupForm extends StatelessWidget {
  final TextEditingController email;
  final TextEditingController password;
  final TextEditingController confirm;
  final VoidCallback onSubmit;

  const _SignupForm({
    required this.email,
    required this.password,
    required this.confirm,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: email,
          decoration: const InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.email),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: password,
          decoration: const InputDecoration(
            labelText: 'Password',
            prefixIcon: Icon(Icons.lock),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: confirm,
          decoration: const InputDecoration(
            labelText: 'Confirm password',
            prefixIcon: Icon(Icons.lock_outline),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: onSubmit,
          icon: const Icon(Icons.person_add),
          label: const Text('Create account'),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(54),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;
  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      color: cs.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}

class _BigSegmented<T> extends StatelessWidget {
  final T value;
  final T left;
  final T right;
  final String leftLabel;
  final String rightLabel;
  final IconData leftIcon;
  final IconData rightIcon;
  final ValueChanged<T> onChanged;

  const _BigSegmented({
    required this.value,
    required this.left,
    required this.right,
    required this.leftLabel,
    required this.rightLabel,
    required this.leftIcon,
    required this.rightIcon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SegButton(
              selected: value == left,
              icon: leftIcon,
              label: leftLabel,
              onTap: () => onChanged(left),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _SegButton(
              selected: value == right,
              icon: rightIcon,
              label: rightLabel,
              onTap: () => onChanged(right),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegButton extends StatelessWidget {
  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SegButton({
    required this.selected,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: selected ? cs.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: selected ? cs.onPrimary : cs.onSurface),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: selected ? cs.onPrimary : cs.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
