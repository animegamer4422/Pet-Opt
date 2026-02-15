import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../models/auth_models.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _isLogin = true;
  AccountType _accountType = AccountType.individual;

  final _loginEmail = TextEditingController();
  final _loginPassword = TextEditingController();

  final _signupEmail = TextEditingController();
  final _signupPassword = TextEditingController();
  final _signupConfirm = TextEditingController();

  @override
  void dispose() {
    _loginEmail.dispose();
    _loginPassword.dispose();
    _signupEmail.dispose();
    _signupPassword.dispose();
    _signupConfirm.dispose();
    super.dispose();
  }

  void _continueAfterAuth() {
    // Mock success for now.
    Navigator.pushReplacementNamed(context, Routes.feed);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    final roleLabel = _isLogin ? 'Logging in as' : 'Signing up as';

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

            // Login / Sign up (same segmented style)
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Get started',
                    style: t.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 10),
                  _BigSegmented<bool>(
                    value: _isLogin,
                    left: true,
                    right: false,
                    leftLabel: 'Login',
                    rightLabel: 'Sign up',
                    leftIcon: Icons.login,
                    rightIcon: Icons.person_add,
                    onChanged: (v) => setState(() => _isLogin = v),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Role selector (Individual/Organization)
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    roleLabel,
                    style: t.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                  ),
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
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: _isLogin
                    ? _LoginForm(
                        key: const ValueKey('login'),
                        email: _loginEmail,
                        password: _loginPassword,
                        onSubmit: _continueAfterAuth,
                      )
                    : _SignupForm(
                        key: const ValueKey('signup'),
                        email: _signupEmail,
                        password: _signupPassword,
                        confirm: _signupConfirm,
                        onSubmit: _continueAfterAuth,
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
    super.key,
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
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          labelText: 'Email',
          prefixIcon: const Icon(Icons.email),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 20, // ⬅ taller input
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        keyboardType: TextInputType.emailAddress,
      ),

      const SizedBox(height: 26), // ⬅ more space

      TextField(
        controller: password,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          labelText: 'Password',
          prefixIcon: const Icon(Icons.lock),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 20, // ⬅ taller input
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        obscureText: true,
      ),

      const SizedBox(height: 30), // ⬅ clearer separation before button

      FilledButton.icon(
        onPressed: onSubmit,
        icon: const Icon(Icons.login),
        label: const Text('Login'),
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(60), // ⬅ taller button
          textStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),

      const SizedBox(height: 16),

      TextButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Forgot password flow later')),
          );
        },
        style: TextButton.styleFrom(
          foregroundColor: cs.primary,
          textStyle: const TextStyle(fontSize: 15),
        ),
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
    super.key,
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
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            labelText: 'Email',
            prefixIcon: const Icon(Icons.email),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 20, // ⬅ taller field
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          keyboardType: TextInputType.emailAddress,
        ),

        const SizedBox(height: 26),

        TextField(
          controller: password,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            labelText: 'Password',
            prefixIcon: const Icon(Icons.lock),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 20,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          obscureText: true,
        ),

        const SizedBox(height: 26),

        TextField(
          controller: confirm,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            labelText: 'Confirm password',
            prefixIcon: const Icon(Icons.lock_outline),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 20,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          obscureText: true,
        ),

        const SizedBox(height: 32),

        FilledButton.icon(
          onPressed: onSubmit,
          icon: const Icon(Icons.person_add),
          label: const Text('Create account'),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(60), // ⬅ taller button
            textStyle: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
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
