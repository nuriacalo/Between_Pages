import 'package:between_pages/core/theme/app_colors.dart';
import 'package:between_pages/features/catalog/presentation/widgets/edit_form_widgets.dart';
import 'package:between_pages/features/profile/application/providers/user_provider.dart';
import 'package:between_pages/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileEditPage extends ConsumerStatefulWidget {
  const ProfileEditPage({super.key});

  @override
  ConsumerState<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends ConsumerState<ProfileEditPage> {
  static const _accent = AppColors.lightAccent;

  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    final user       = ref.read(userProfileProvider).value;
    _nameController  = TextEditingController(text: user?.name  ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');

    // Rebuild when name changes so the avatar initials update live.
    _nameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  String get _initials {
    final name = _nameController.text.trim();
    if (name.isEmpty) return '?';
    final parts = name.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate() || _isSaving) return;
    setState(() => _isSaving = true);

    try {
      // TODO: llamada real al repositorio
      // await ref.read(userRepositoryProvider).updateProfile(
      //   name:  _nameController.text.trim(),
      //   email: _emailController.text.trim(),
      // );
      // ref.invalidate(userProfileProvider);

      await Future.delayed(const Duration(milliseconds: 600));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Perfil actualizado'),
          ]),
          backgroundColor: AppColors.statusReading,
          behavior:        SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:         Text('${l10n.errorPrefix}: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior:        SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n        = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation:       0,
        foregroundColor: _accent,
        title: Text(
          l10n.profileEditProfile,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color:      colorScheme.onSurface,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          children: [
            _AvatarSection(
              initials:        _initials,
              accent:          _accent,
              onChangePicture: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:  Text('Cambiar foto — próximamente'),
                  behavior: SnackBarBehavior.floating,
                ),
              ),
            ),
            const SizedBox(height: 8),

            FormSection(
              label:       'Información personal',
              accentColor: _accent,
              children: [
                AppTextField(
                  controller:  _nameController,
                  label:       l10n.registerName,
                  icon:        Icons.person_outline_rounded,
                  accentColor: _accent,
                  isRequired:  true,
                ),
                const SizedBox(height: 10),
                AppTextField(
                  controller:   _emailController,
                  label:        l10n.loginEmail,
                  icon:         Icons.email_outlined,
                  accentColor:  _accent,
                  isRequired:   true,
                  keyboardType: TextInputType.emailAddress,
                ),
              ],
            ),

            SaveButton(
              label:     l10n.saveButton,
              icon:      Icons.save_rounded,
              color:     _accent,
              isLoading: _isSaving,
              onTap:     _saveProfile,
            ),

            const SizedBox(height: 20),

            _DangerZone(l10n: l10n),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _AvatarSection
// ─────────────────────────────────────────────────────────────────────────────

class _AvatarSection extends StatelessWidget {
  final String       initials;
  final Color        accent;
  final VoidCallback onChangePicture;

  const _AvatarSection({
    required this.initials,
    required this.accent,
    required this.onChangePicture,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width:  96,
              height: 96,
              decoration: BoxDecoration(
                shape:    BoxShape.circle,
                gradient: LinearGradient(
                  begin:  Alignment.topLeft,
                  end:    Alignment.bottomRight,
                  colors: [accent, accent.withValues(alpha: 0.6)],
                ),
                boxShadow: [
                  BoxShadow(
                    color:      accent.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset:     const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  initials,
                  style: const TextStyle(
                    color:         Colors.white,
                    fontSize:      32,
                    fontWeight:    FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right:  0,
              child: GestureDetector(
                onTap: onChangePicture,
                child: Container(
                  width:  32,
                  height: 32,
                  decoration: BoxDecoration(
                    color:  accent,
                    shape:  BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.surface,
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:      Colors.black.withValues(alpha: 0.15),
                        blurRadius: 6,
                        offset:     const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    size:  15,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _DangerZone
// ─────────────────────────────────────────────────────────────────────────────

class _DangerZone extends StatelessWidget {
  final AppLocalizations l10n;
  const _DangerZone({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark      = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width:  3,
              height: 13,
              margin: const EdgeInsets.only(right: 7),
              decoration: BoxDecoration(
                color:        colorScheme.error.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'ZONA DE PELIGRO',
              style: TextStyle(
                fontSize:      10,
                fontWeight:    FontWeight.bold,
                color:         AppColors.textSecondary(context),
                letterSpacing: 0.7,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color:        isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: BorderRadius.circular(14),
            border:       Border.all(color: colorScheme.error.withValues(alpha: 0.25)),
          ),
          child: ListTile(
            shape:   RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            leading: Icon(Icons.delete_outline_rounded, color: colorScheme.error),
            title: Text(
              'Eliminar cuenta',
              style: TextStyle(color: colorScheme.error, fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              'Esta acción es irreversible',
              style: TextStyle(fontSize: 12, color: colorScheme.error.withValues(alpha: 0.65)),
            ),
            trailing: Icon(Icons.chevron_right_rounded,
                color: colorScheme.error.withValues(alpha: 0.5)),
            onTap: () => _confirmDelete(context),
          ),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title:   const Text('¿Eliminar cuenta?'),
        content: const Text(
          'Se borrarán todos tus datos permanentemente. Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:     const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              // TODO: llamada al repositorio para eliminar cuenta
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}