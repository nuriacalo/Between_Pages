import 'package:between_pages/core/theme/app_colors.dart';
import 'package:between_pages/features/auth/application/repositories/auth_repository.dart';
import 'package:between_pages/features/notes/application/providers/note_provider.dart';
import 'package:between_pages/features/notes/domain/note_dto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SecondBrainTab extends ConsumerWidget {
  final int bookId;

  const SecondBrainTab({super.key, required this.bookId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(notesProvider(bookId));

    return entriesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (entries) => _BrainContent(
        bookId: bookId,
        entries: entries,
      ),
    );
  }
}

class _BrainContent extends ConsumerWidget {
  final int bookId;
  final List<NoteDTO> entries;

  const _BrainContent({required this.bookId, required this.entries});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = AppColors.accent(context);

    return Stack(
      children: [
        entries.isEmpty
            ? _EmptyState(accent: accent)
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                itemCount: entries.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _EntryCard(
                  entry: entries[i],
                  bookId: bookId,
                  accent: accent,
                ),
              ),

        // FAB "Añadir"
        Positioned(
          bottom: 20,
          left: 16,
          right: 16,
          child: FilledButton.icon(
            onPressed: () => _showAddEntrySheet(context, ref, bookId),
            icon: const Icon(Icons.add),
            label: const Text('Añadir cita o nota'),
            style: FilledButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Tarjeta de entrada ────────────────────────────────────────────────────────

class _EntryCard extends ConsumerWidget {
  final NoteDTO entry;
  final int bookId;
  final Color accent;

  const _EntryCard({
    required this.entry,
    required this.bookId,
    required this.accent,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasQuote = entry.quote != null && entry.quote!.isNotEmpty;
    final hasNote  = entry.note  != null && entry.note!.isNotEmpty;

    return Dismissible(
      key: ValueKey(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.statusAbandoned.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_outline, color: AppColors.statusAbandoned),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Eliminar entrada'),
            content: const Text('¿Seguro que quieres borrar esta entrada?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.statusAbandoned,
                ),
                child: const Text('Eliminar'),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) {
        if (entry.id != null) {
          ref
              .read(noteNotifierProvider.notifier)
              .deleteEntry(entry.id!, bookId);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border(context)),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Meta: página + fecha
            Row(
              children: [
                if (entry.page != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Pág. ${entry.page}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: accent,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (entry.createdAt != null)
                  Text(
                    _formatDate(entry.createdAt!),
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                const Spacer(),
                if (hasQuote)
                  Icon(Icons.format_quote_rounded,
                      size: 16, color: accent.withValues(alpha: 0.4)),
              ],
            ),

            // Cita
            if (hasQuote) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.only(left: 10),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: accent, width: 3),
                  ),
                ),
                child: Text(
                  entry.quote!,
                  style: TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: AppColors.textPrimary(context),
                    height: 1.5,
                  ),
                ),
              ),
            ],

            // Nota
            if (hasNote) ...[
              SizedBox(height: hasQuote ? 8 : 10),
              Text(
                entry.note!,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary(context),
                  height: 1.4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays == 0) return 'Hoy';
    if (diff.inDays == 1) return 'Ayer';
    if (diff.inDays < 7) return 'Hace ${diff.inDays} días';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

// ── Estado vacío ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final Color accent;
  const _EmptyState({required this.accent});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.psychology_outlined,
                size: 56, color: accent.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text(
              'Tu Segundo Cerebro está vacío',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Guarda citas y reflexiones mientras lees para no perder nada.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary(context),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bottom sheet "Añadir entrada" ─────────────────────────────────────────────

void _showAddEntrySheet(BuildContext context, WidgetRef ref, int bookId) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => AddEntrySheet(ref: ref, bookId: bookId),
  );
}

class AddEntrySheet extends ConsumerStatefulWidget {
  final WidgetRef ref;
  final int bookId;

  const AddEntrySheet({super.key, required this.ref, required this.bookId});

  @override
  ConsumerState<AddEntrySheet> createState() => _AddEntrySheetState();
}

class _AddEntrySheetState extends ConsumerState<AddEntrySheet> {
  final _quoteController = TextEditingController();
  final _noteController  = TextEditingController();
  final _pageController  = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _quoteController.dispose();
    _noteController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final quote = _quoteController.text.trim();
    final note  = _noteController.text.trim();
    final page  = int.tryParse(_pageController.text.trim());

    if (quote.isEmpty && note.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Añade al menos una cita o una nota')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final auth = ref.read(authRepositoryProvider);
      final user = await auth.getUserProfile();

      await ref.read(noteNotifierProvider.notifier).addEntry(
            NoteDTO(
              userId: user.idUser,
              bookId: widget.bookId,
              quote: quote.isEmpty ? null : quote,
              note:  note.isEmpty  ? null : note,
              page:  page,
            ),
          );

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.accent(context);
    final isDark = AppColors.isDark(context);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Icon(Icons.psychology_outlined, color: accent, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Nueva entrada',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Página
            _SheetField(
              controller: _pageController,
              label: 'Página / Capítulo',
              hint: 'ej: 187',
              icon: Icons.bookmark_outline,
              accent: accent,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 10),

            // Cita
            _SheetField(
              controller: _quoteController,
              label: 'Cita o frase',
              hint: 'Escribe la cita aquí...',
              icon: Icons.format_quote_rounded,
              accent: accent,
              maxLines: 3,
            ),
            const SizedBox(height: 10),

            // Nota
            _SheetField(
              controller: _noteController,
              label: 'Tu reflexión (opcional)',
              hint: '¿Qué te ha hecho pensar?',
              icon: Icons.edit_note,
              accent: accent,
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Botón guardar
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isSaving ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: accent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Guardar entrada'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final Color accent;
  final int maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const _SheetField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.accent,
    this.maxLines = 1,
    this.keyboardType,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 18, color: accent),
        filled: true,
        fillColor: AppColors.card(context),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border(context)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accent, width: 1.5),
        ),
      ),
    );
  }
}