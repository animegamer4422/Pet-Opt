import 'package:flutter/material.dart';
import '../../app/routes.dart';

class ProfileSetupPage extends StatefulWidget {
  const ProfileSetupPage({super.key});

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _location = TextEditingController();
  final _phone = TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    _name.dispose();
    _location.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _saveAndContinue() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    // TODO: Save to backend later
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;
    setState(() => _isSaving = false);

    Navigator.pushReplacementNamed(context, Routes.feed);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Set up your profile')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tell us about yourself',
                    style: t.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Your name helps others recognize you. Location helps show pets near you. Phone number is optional but useful for contact.',
                    style: t.bodyMedium?.copyWith(
                      color: cs.onSurface.withOpacity(0.75),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Name (Required)
                  TextFormField(
                    controller: _name,
                    style: const TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      labelText: 'Your name *',
                      prefixIcon: const Icon(Icons.person),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 20,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Name is required';
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.next,
                  ),

                  const SizedBox(height: 26),

                  // Location (Optional)
                  TextFormField(
                    controller: _location,
                    style: const TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      labelText: 'Location (City / Area)',
                      prefixIcon: const Icon(Icons.location_on),
                      hintText: 'Optional',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 20,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    textInputAction: TextInputAction.next,
                  ),

                  const SizedBox(height: 26),

                  // Phone (Optional but validated if filled)
                  TextFormField(
                    controller: _phone,
                    style: const TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      labelText: 'Phone number',
                      prefixIcon: const Icon(Icons.phone),
                      hintText: 'Optional',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 20,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (v) {
                      if (v == null || v.isEmpty) return null;
                      if (v.length < 7) {
                        return 'Enter a valid phone number';
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _saveAndContinue(),
                  ),

                  const SizedBox(height: 34),

                  FilledButton.icon(
                    onPressed: _isSaving ? null : _saveAndContinue,
                    icon: _isSaving
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check),
                    label: Text(_isSaving ? 'Saving…' : 'Continue'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(60),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
