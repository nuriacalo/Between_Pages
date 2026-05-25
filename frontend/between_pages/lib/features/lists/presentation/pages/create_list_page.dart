import 'package:between_pages/core/theme/app_colors.dart';
import 'package:between_pages/features/auth/application/repositories/auth_repository.dart';
import 'package:between_pages/features/lists/application/providers/list_provider.dart';
import 'package:between_pages/features/lists/application/repositories/reading_list_repository.dart';
import 'package:between_pages/features/lists/domain/reading_list_request_dto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CreateListPage extends ConsumerStatefulWidget {
  const CreateListPage({super.key});

  @override
  ConsumerState<CreateListPage> createState() => _CreateListPageState();
}

class _CreateListPageState extends ConsumerState<CreateListPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _createList() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final auth = ref.read(authRepositoryProvider);
      final user = await auth.getUserProfile();
      final repo = ref.read(readingListRepositoryProvider);
      await repo.createList(
        user.idUser,
        ReadingListRequestDTO(
          name: _nameController.text.trim(),
          description: _descController.text.trim(),
        ),
      );
      ref.invalidate(listProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Lista creada con éxito'),
          backgroundColor: AppColors.statusReading,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      context.pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al crear la lista: $e'),
          backgroundColor: AppColors.logout(context),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: CustomScrollView(
        slivers: [
          // ── Header ──────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.fromLTRB(
                20,
                MediaQuery.of(context).padding.top + 16,
                20,
                24,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface(context),
                border: Border(
                  bottom:
                      BorderSide(color: AppColors.border(context), width: 1),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Botón atrás
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 38,
                      height: 38,
                      color: Colors.transparent,
                      child: Icon(Icons.arrow_back_rounded,
                          size: 18,
                          color: AppColors.textPrimary(context)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.accent(context)
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'NUEVA COLECCIÓN',
                            style: textTheme.labelSmall?.copyWith(
                              color: AppColors.accent(context),
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              fontSize: 9,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Crear lista',
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary(context),
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Formulario ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Campo nombre ───────────────────────────────────────
                    _FieldLabel(
                      icon: Icons.label_outline_rounded,
                      label: 'Nombre',
                      required: true,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary(context),
                      ),
                      decoration: _inputDecoration(
                        context,
                        hint: 'Ej. Mis lecturas de verano',
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'El nombre es obligatorio'
                          : null,
                    ),

                    const SizedBox(height: 24),

                    // ── Campo descripción ──────────────────────────────────
                    _FieldLabel(
                      icon: Icons.notes_rounded,
                      label: 'Descripción',
                      required: false,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descController,
                      maxLines: 4,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary(context),
                      ),
                      decoration: _inputDecoration(
                        context,
                        hint: 'Una pequeña descripción de tu colección...',
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── Botón crear ────────────────────────────────────────
                    GestureDetector(
                      onTap: _isLoading ? null : _createList,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        height: 52,
                        decoration: BoxDecoration(
                          color: _isLoading
                              ? AppColors.accent(context)
                                  .withValues(alpha: 0.5)
                              : AppColors.accent(context),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: _isLoading
                              ? []
                              : [
                                  BoxShadow(
                                    color: AppColors.accent(context)
                                        .withValues(alpha: 0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                        ),
                        alignment: Alignment.center,
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.collections_bookmark_rounded,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Crear lista',
                                    style: textTheme.labelLarge?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Botón cancelar secundario
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        height: 48,
                        alignment: Alignment.center,
                        child: Text(
                          'Cancelar',
                          style: textTheme.labelLarge?.copyWith(
                            color: AppColors.textSecondary(context),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(BuildContext context,
      {required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: AppColors.textSecondary(context).withValues(alpha: 0.6),
        fontSize: 14,
      ),
      filled: true,
      fillColor: AppColors.card(context),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.border(context)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.border(context)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            BorderSide(color: AppColors.accent(context), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.logout(context)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            BorderSide(color: AppColors.logout(context), width: 1.5),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _FieldLabel  — etiqueta con icono y badge "Opcional"
// ─────────────────────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool required;
  const _FieldLabel({
    required this.icon,
    required this.label,
    required this.required,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.accent(context)),
        const SizedBox(width: 6),
        Text(
          label,
          style: textTheme.labelMedium?.copyWith(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        if (!required) ...[
          const SizedBox(width: 6),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.emphasis(context).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Opcional',
              style: textTheme.labelSmall?.copyWith(
                color: AppColors.emphasis(context),
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }
}