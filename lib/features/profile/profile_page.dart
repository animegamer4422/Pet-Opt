import 'package:flutter/material.dart';

import '../../models/auth_models.dart';
import '../auth/data/auth_store.dart';
import '../onboarding/data/profile_store.dart';

String accountTypeLabel(AccountType v) =>
    v == AccountType.individual ? 'Individual' : 'Organization';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

enum _Field { name, location, phone }

class _ProfilePageState extends State<ProfilePage> {
  final _name = TextEditingController();
  final _location = TextEditingController();
  final _phone = TextEditingController();

  bool _editName = false;
  bool _editLocation = false;
  bool _editPhone = false;

  bool _savingName = false;
  bool _savingLocation = false;
  bool _savingPhone = false;

  @override
  void initState() {
    super.initState();
    _syncControllersFromStore();
  }

  @override
  void dispose() {
    _name.dispose();
    _location.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _syncControllersFromStore() {
    final p = ProfileStore.instance.profile;
    _name.text = p?.name ?? '';
    _location.text = p?.location ?? '';
    _phone.text = p?.phone ?? '';
  }

  Future<void> _saveProfile({
    String? name,
    String? location,
    String? phone,
  }) async {
    final p = ProfileStore.instance.profile;
    await ProfileStore.instance.saveProfile(
      name: (name ?? p?.name ?? '').trim(),
      location: (location ?? p?.location ?? '').trim(),
      phone: (phone ?? p?.phone ?? '').trim(),
    );
  }

  String? _validateName(String value) {
    if (value.trim().isEmpty) return 'Name is required';
    return null;
  }

  String? _validatePhone(String value) {
    final v = value.trim();
    if (v.isEmpty) return null;
    if (v.length < 7) return 'Enter a valid phone number';
    return null;
  }

  void _revertField(_Field f) {
    final p = ProfileStore.instance.profile;
    switch (f) {
      case _Field.name:
        _name.text = p?.name ?? '';
        _editName = false;
        break;
      case _Field.location:
        _location.text = p?.location ?? '';
        _editLocation = false;
        break;
      case _Field.phone:
        _phone.text = p?.phone ?? '';
        _editPhone = false;
        break;
    }
    FocusScope.of(context).unfocus();
    setState(() {});
  }

  Future<void> _confirmField(_Field f) async {
    switch (f) {
      case _Field.name:
        final err = _validateName(_name.text);
        if (err != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
          return;
        }
        setState(() => _savingName = true);
        try {
          await _saveProfile(name: _name.text);
          if (!mounted) return;
          setState(() => _editName = false);
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Name updated')));
        } finally {
          if (mounted) setState(() => _savingName = false);
        }
        break;

      case _Field.location:
        setState(() => _savingLocation = true);
        try {
          await _saveProfile(location: _location.text);
          if (!mounted) return;
          setState(() => _editLocation = false);
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Location updated')));
        } finally {
          if (mounted) setState(() => _savingLocation = false);
        }
        break;

      case _Field.phone:
        final err = _validatePhone(_phone.text);
        if (err != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
          return;
        }
        setState(() => _savingPhone = true);
        try {
          await _saveProfile(phone: _phone.text);
          if (!mounted) return;
          setState(() => _editPhone = false);
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Phone updated')));
        } finally {
          if (mounted) setState(() => _savingPhone = false);
        }
        break;
    }

    if (!mounted) return;
    FocusScope.of(context).unfocus();
    _syncControllersFromStore();
  }

  Future<void> _confirmLogout() async {
    final cs = Theme.of(context).colorScheme;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('This clears your local demo session on this device.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: cs.error,
              foregroundColor: cs.onError,
            ),
            child: const Text('Log out'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    await AuthStore.instance.logout();
    await ProfileStore.instance.clear();

    if (!mounted) return;

    // Return to app root; PetOptApp(home: ...) will decide next screen.
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final profileStore = ProfileStore.instance;
    final authStore = AuthStore.instance;

    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: AnimatedBuilder(
        animation: Listenable.merge([profileStore, authStore]),
        builder: (context, _) {
          final p = profileStore.profile;

          // Keep controllers synced unless actively editing that field.
          if (!_editName && !_editLocation && !_editPhone) {
            _syncControllersFromStore();
          } else {
            if (!_editName) _name.text = p?.name ?? '';
            if (!_editLocation) _location.text = p?.location ?? '';
            if (!_editPhone) _phone.text = p?.phone ?? '';
          }

          final displayName =
              (p != null && p.name.trim().isNotEmpty) ? p.name.trim() : 'User';

          final session = authStore.session;
          final email = session?.email.trim() ?? '';
          final acct = session?.accountType ?? AccountType.individual;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _HeaderCard(
                nameController: _name,
                displayNameFallback: displayName,
                subtitle: email.isNotEmpty ? email : 'Demo user',
                badgeLabel: accountTypeLabel(acct),
                editing: _editName,
                saving: _savingName,
                onEdit: () => setState(() => _editName = true),
                onCancel: () => _revertField(_Field.name),
                onConfirm: () => _confirmField(_Field.name),
              ),
              const SizedBox(height: 12),

              _DetailsCard(
                locationController: _location,
                phoneController: _phone,
                editLocation: _editLocation,
                editPhone: _editPhone,
                savingLocation: _savingLocation,
                savingPhone: _savingPhone,
                onEditLocation: () => setState(() => _editLocation = true),
                onEditPhone: () => setState(() => _editPhone = true),
                onCancelLocation: () => _revertField(_Field.location),
                onCancelPhone: () => _revertField(_Field.phone),
                onConfirmLocation: () => _confirmField(_Field.location),
                onConfirmPhone: () => _confirmField(_Field.phone),
              ),

              const SizedBox(height: 12),

              Container(
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.badge_outlined),
                      title: const Text('Identity'),
                      subtitle: Text('Signed in as $displayName'),
                    ),
                    Divider(height: 1, color: cs.outlineVariant.withOpacity(0.7)),
                    ListTile(
                      leading: const Icon(Icons.logout),
                      title: const Text('Log out'),
                      subtitle: const Text('Clear demo session on this device'),
                      onTap: _confirmLogout,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              Divider(color: cs.outlineVariant),
              const SizedBox(height: 12),
              Text(
                "Demo Mode",
                style: t.bodySmall?.copyWith(
                  color: cs.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Profile data is stored locally on this device.",
                style: t.bodySmall?.copyWith(
                  color: cs.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final TextEditingController nameController;
  final String displayNameFallback;
  final String subtitle;
  final String badgeLabel;

  final bool editing;
  final bool saving;
  final VoidCallback onEdit;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const _HeaderCard({
    required this.nameController,
    required this.displayNameFallback,
    required this.subtitle,
    required this.badgeLabel,
    required this.editing,
    required this.saving,
    required this.onEdit,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    final nameShown = nameController.text.trim().isNotEmpty
        ? nameController.text.trim()
        : displayNameFallback;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: cs.primary,
            child: Text(
              nameShown.isNotEmpty ? nameShown[0].toUpperCase() : "?",
              style: t.headlineMedium?.copyWith(
                color: cs.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!editing)
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          nameShown,
                          style: t.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Edit name',
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit),
                      ),
                    ],
                  )
                else
                  TextField(
                    controller: nameController,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Name *',
                      border: const OutlineInputBorder(),
                      isDense: true,
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (saving)
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          else ...[
                            IconButton(
                              tooltip: 'Confirm',
                              onPressed: onConfirm,
                              icon: const Icon(Icons.check),
                            ),
                            IconButton(
                              tooltip: 'Cancel',
                              onPressed: onCancel,
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ],
                      ),
                    ),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => onConfirm(),
                  ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: t.bodySmall?.copyWith(
                    color: cs.onSurface.withOpacity(0.7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: cs.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    badgeLabel,
                    style: t.labelMedium?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  final TextEditingController locationController;
  final TextEditingController phoneController;

  final bool editLocation;
  final bool editPhone;

  final bool savingLocation;
  final bool savingPhone;

  final VoidCallback onEditLocation;
  final VoidCallback onEditPhone;

  final VoidCallback onCancelLocation;
  final VoidCallback onCancelPhone;

  final VoidCallback onConfirmLocation;
  final VoidCallback onConfirmPhone;

  const _DetailsCard({
    required this.locationController,
    required this.phoneController,
    required this.editLocation,
    required this.editPhone,
    required this.savingLocation,
    required this.savingPhone,
    required this.onEditLocation,
    required this.onEditPhone,
    required this.onCancelLocation,
    required this.onCancelPhone,
    required this.onConfirmLocation,
    required this.onConfirmPhone,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Details", style: t.titleSmall?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),

          if (!editLocation)
            _ReadRow(
              icon: Icons.location_on,
              label: 'Location',
              value: locationController.text.trim().isEmpty
                  ? 'Not set'
                  : locationController.text.trim(),
              muted: locationController.text.trim().isEmpty,
              onEdit: onEditLocation,
            )
          else
            _EditRow(
              controller: locationController,
              label: 'Location (City / Area)',
              prefixIcon: Icons.location_on,
              saving: savingLocation,
              onConfirm: onConfirmLocation,
              onCancel: onCancelLocation,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => onConfirmLocation(),
            ),

          const SizedBox(height: 14),

          if (!editPhone)
            _ReadRow(
              icon: Icons.phone,
              label: 'Phone',
              value: phoneController.text.trim().isEmpty
                  ? 'Not set'
                  : phoneController.text.trim(),
              muted: phoneController.text.trim().isEmpty,
              onEdit: onEditPhone,
            )
          else
            _EditRow(
              controller: phoneController,
              label: 'Phone number',
              prefixIcon: Icons.phone,
              saving: savingPhone,
              keyboardType: TextInputType.phone,
              onConfirm: onConfirmPhone,
              onCancel: onCancelPhone,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => onConfirmPhone(),
            ),
        ],
      ),
    );
  }
}

class _ReadRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool muted;
  final VoidCallback onEdit;

  const _ReadRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.muted,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return Row(
      children: [
        Icon(icon, size: 18, color: cs.onSurface.withOpacity(0.7)),
        const SizedBox(width: 10),
        SizedBox(
          width: 76,
          child: Text(
            label,
            style: t.bodySmall?.copyWith(
              color: cs.onSurface.withOpacity(0.65),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: t.bodyMedium?.copyWith(
              color: muted
                  ? cs.onSurface.withOpacity(0.5)
                  : cs.onSurface.withOpacity(0.9),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        IconButton(
          tooltip: 'Edit',
          onPressed: onEdit,
          icon: const Icon(Icons.edit),
        ),
      ],
    );
  }
}

class _EditRow extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData prefixIcon;
  final bool saving;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;
  final TextInputType? keyboardType;

  const _EditRow({
    required this.controller,
    required this.label,
    required this.prefixIcon,
    required this.saving,
    required this.onConfirm,
    required this.onCancel,
    required this.textInputAction,
    required this.onSubmitted,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: true,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(prefixIcon),
        border: const OutlineInputBorder(),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (saving)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else ...[
              IconButton(
                tooltip: 'Confirm',
                onPressed: onConfirm,
                icon: const Icon(Icons.check),
              ),
              IconButton(
                tooltip: 'Cancel',
                onPressed: onCancel,
                icon: const Icon(Icons.close),
              ),
            ],
          ],
        ),
      ),
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
    );
  }
}
