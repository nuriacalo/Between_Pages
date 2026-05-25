import 'package:between_pages/core/theme/app_colors.dart';
import 'package:between_pages/features/notes/application/providers/note_provider.dart';
import 'package:between_pages/features/notes/domain/note_dto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─────────────────────────────────────────────────────────────────────────────
// NotesTab  (formerly SecondBrainTab)
//
// Shows all notes for a given item and lets the user add / delete them.
// Rename all usages of SecondBrainTab → NotesTab in the rest of the app.
// ─────────────────────────────────────────────────────────────────────────────

class NotesTab extends ConsumerWidget {
  final String itemType; // 'BOOK' | 'MANGA' | 'FANFIC'
  final int    itemId;

  const NotesTab({
    super.key,
    required this.itemType,
    required this.itemId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(
      notesProvider((itemType: itemType, itemId: itemId)),
    );
    final accent = AppColors.accent(context);

    return notesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error:   (e, _) => _ErrorState(error: e.toString()),
      data:    (notes) => _NotesContent(
        itemType: itemType,
        itemId:   itemId,
        notes:    notes,
        accent:   accent,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _NotesContent
// ─────────────────────────────────────────────────────────────────────────────

class _NotesContent extends ConsumerWidget {
  final String      itemType;
  final int         itemId;
  final List<NoteDTO> notes;
  final Color       accent;

  const _NotesContent({
    required this.itemType,
    required this.itemId,
    required this.notes,
    required this.accent,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        notes.isEmpty
            ? _EmptyState(
                accent: accent,
                onAdd:  () => _openAddSheet(context, itemType, itemId, accent),
              )
            : ListView.separated(
                padding:          const EdgeInsets.fromLTRB(16, 16, 16, 100),
                itemCount:        notes.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder:      (_, i) => _NoteCard(
                  note:     notes[i],
                  itemType: itemType,
                  itemId:   itemId,
                  accent:   accent,
                ),
              ),

        // ── Fixed bottom CTA ─────────────────────────────────────────
        if (notes.isNotEmpty)
          Positioned(
            bottom: 20,
            left:   16,
            right:  16,
            child: FilledButton.icon(
              onPressed: () => _openAddSheet(context, itemType, itemId, accent),
              icon:  const Icon(Icons.add_rounded),
              label: const Text('Añadir nota'),
              style: FilledButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.white,
                padding:         const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ), 
              ),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _NoteCard
// ─────────────────────────────────────────────────────────────────────────────

class _NoteCard extends ConsumerWidget {
  final NoteDTO note;
  final String  itemType;
  final int     itemId;
  final Color   accent;

  const _NoteCard({
    required this.note,
    required this.itemType,
    required this.itemId,
    required this.accent,
  });

  String get _pageLabel => switch (itemType.toUpperCase()) {
        'MANGA'  => 'Cap. ${note.page}',
        'FANFIC' => 'Cap. ${note.page}',
        _        => 'Pág. ${note.page}',
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final hasQuote = note.quote != null && note.quote!.isNotEmpty;
    final hasNote  = note.note  != null && note.note!.isNotEmpty;

    return Dismissible(
      key:       ValueKey(note.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding:   const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color:        Theme.of(context).colorScheme.error,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_outline_rounded,
            color: Colors.white, size: 22),
      ),
      confirmDismiss: (_) => showDialog<bool>(
        context: context,
        builder: (dialogCtx) => AlertDialog(
          title:   const Text('Eliminar nota'),
          content: const Text('¿Seguro que quieres borrar esta nota?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx, false),
              child:     const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogCtx, true),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Eliminar'),
            ),
          ],
        ),
      ),
      onDismissed: (_) {
        if (note.id != null) {
          ref
              .read(noteNotifierProvider.notifier)
              .deleteEntry(note.id!, itemType, itemId);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color:        AppColors.card(context),
          borderRadius: BorderRadius.circular(14),
          border:       Border.all(color: AppColors.border(context)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header row ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 8, 0),
              child: Row(
                children: [
                  // Page badge
                  if (note.page != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color:        accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border:       Border.all(color: accent.withValues(alpha: 0.28)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.bookmark_rounded,
                              size: 11, color: accent),
                          const SizedBox(width: 4),
                          Text(
                            _pageLabel,
                            style: TextStyle(
                              fontSize:   10,
                              fontWeight: FontWeight.bold,
                              color:      accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  // Relative date
                  if (note.createdAt != null)
                    Text(
                      _relativeDate(note.createdAt!),
                      style: TextStyle(
                        fontSize: 11,
                        color:    AppColors.textSecondary(context),
                      ),
                    ),
                  const Spacer(),
                  // Action menu (copy + delete)
                  _NoteMenu(
                    note:     note,
                    itemType: itemType,
                    itemId:   itemId,
                  ),
                ],
              ),
            ),

            // ── Quote block ──────────────────────────────────────────
            if (hasQuote)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  decoration: BoxDecoration(
                    color:        accent.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(12),
                    border:       Border(
                      left: BorderSide(color: accent, width: 3),
                    ),
                  ),
                  child: Text(
                    '"${note.quote!}"',
                    style: TextStyle(
                      fontSize:  13,
                      fontStyle: FontStyle.italic,
                      color:     AppColors.textPrimary(context),
                      height:    1.5,
                    ),
                  ),
                ),
              ),

            // ── Reflection text ──────────────────────────────────────
            if (hasNote)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  14,
                  hasQuote ? 8 : 12,
                  14,
                  14,
                ),
                child: Text(
                  note.note!,
                  style: TextStyle(
                    fontSize: 13,
                    color:    AppColors.textPrimary(context),
                    height:   1.5,
                  ),
                ),
              )
            else
              const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }

  String _relativeDate(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays == 0)  return 'Hoy';
    if (diff.inDays == 1)  return 'Ayer';
    if (diff.inDays < 7)   return 'Hace ${diff.inDays} días';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _NoteMenu  — copy / delete popup
// ─────────────────────────────────────────────────────────────────────────────

class _NoteMenu extends ConsumerWidget {
  final NoteDTO note;
  final String  itemType;
  final int     itemId;

  const _NoteMenu({
    required this.note,
    required this.itemType,
    required this.itemId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_horiz_rounded,
        size:  18,
        color: AppColors.textSecondary(context),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (action) async {
        if (action == 'copy') {
          final text = [note.quote, note.note]
              .whereType<String>()
              .join('\n\n');
          await Clipboard.setData(ClipboardData(text: text));
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content:  Text('Copiado al portapapeles'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } else if (action == 'delete' && note.id != null) {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (dialogCtx) => AlertDialog(
              title:   const Text('Eliminar nota'),
              content: const Text('¿Seguro que quieres borrar esta nota?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx, false),
                  child:     const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(dialogCtx, true),
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                  child: const Text('Eliminar'),
                ),
              ],
            ),
          );
          if ((confirmed ?? false) && context.mounted) {
            ref
                .read(noteNotifierProvider.notifier)
                .deleteEntry(note.id!, itemType, itemId);
          }
        }
      },
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: 'copy',
          child: Row(children: [
            Icon(Icons.copy_rounded, size: 16),
            SizedBox(width: 10),
            Text('Copiar'),
          ]),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(children: [
            Icon(Icons.delete_outline_rounded,
                size:  16,
                color: Theme.of(context).colorScheme.error),
            const SizedBox(width: 10),
            Text(
              'Eliminar',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.error),
            ),
          ]),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _openAddSheet  — standalone helper (no WidgetRef needed as param)
// ─────────────────────────────────────────────────────────────────────────────

void _openAddSheet(
  BuildContext context,
  String       itemType,
  int          itemId,
  Color        accent,
) {
  showModalBottomSheet<void>(
    context:            context,
    isScrollControlled: true,
    backgroundColor:    Colors.transparent,
    builder:            (_) => AddNoteSheet(
      itemType: itemType,
      itemId:   itemId,
      accent:   accent,
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// AddNoteSheet
// ─────────────────────────────────────────────────────────────────────────────

class AddNoteSheet extends ConsumerStatefulWidget {
  final String itemType;
  final int    itemId;
  final Color  accent;

  const AddNoteSheet({
    super.key,
    required this.itemType,
    required this.itemId,
    required this.accent,
  });

  @override
  ConsumerState<AddNoteSheet> createState() => _AddNoteSheetState();
}

class _AddNoteSheetState extends ConsumerState<AddNoteSheet> {
  final _quoteController = TextEditingController();
  final _noteController  = TextEditingController();
  final _pageController  = TextEditingController();
  bool  _isSaving        = false;

  @override
  void dispose() {
    _quoteController.dispose();
    _noteController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  bool get _isValid =>
      _quoteController.text.trim().isNotEmpty ||
      _noteController.text.trim().isNotEmpty;

  String get _pageLabel => switch (widget.itemType.toUpperCase()) {
        'MANGA'  => 'Capítulo',
        'FANFIC' => 'Capítulo',
        _        => 'Página',
      };

  Future<void> _save() async {
    if (!_isValid || _isSaving) return;
    setState(() => _isSaving = true);

    try {
      // ref comes from ConsumerState — no need to pass it from outside
      await ref.read(noteNotifierProvider.notifier).addEntry(
            NoteDTO(
              itemType: widget.itemType,
              itemId:   widget.itemId,
              quote: _quoteController.text.trim().isEmpty
                  ? null
                  : _quoteController.text.trim(),
              note: _noteController.text.trim().isEmpty
                  ? null
                  : _noteController.text.trim(),
              page: int.tryParse(_pageController.text.trim()),
            ),
          );

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:         Text('Error al guardar: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior:        SnackBarBehavior.floating,
          ),
        );
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.accent;

    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color:        AppColors.surface(context),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize:       MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width:  36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color:        AppColors.border(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:        accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.edit_note_rounded,
                      color: accent, size: 18),
                ),
                const SizedBox(width: 10),
                Text(
                  'Nueva nota',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Page field
            _SheetField(
              controller:      _pageController,
              label:           _pageLabel,
              hint:            'ej. 142',
              icon:            Icons.bookmark_border_rounded,
              accent:          accent,
              keyboardType:    TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 10),

            // Quote field
            _SheetField(
              controller: _quoteController,
              label:      'Cita o frase',
              hint:       '"Una frase que no quieres olvidar…"',
              icon:       Icons.format_quote_rounded,
              accent:     accent,
              maxLines:   3,
              onChanged:  (_) => setState(() {}),
            ),
            const SizedBox(height: 10),

            // Note field
            _SheetField(
              controller: _noteController,
              label:      'Tu reflexión (opcional)',
              hint:       '¿Qué te ha hecho pensar?',
              icon:       Icons.notes_rounded,
              accent:     accent,
              maxLines:   3,
              onChanged:  (_) => setState(() {}),
            ),
            const SizedBox(height: 16),

            // Save button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isValid && !_isSaving ? _save : null,
                style: FilledButton.styleFrom(
                  backgroundColor:        accent,
                  disabledBackgroundColor: accent.withValues(alpha: 0.4),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width:  20,
                        height: 20,
                        child:  CircularProgressIndicator(
                          strokeWidth: 2,
                          color:       Colors.white,
                        ),
                      )
                    : const Text('Guardar nota',
                        style: TextStyle(fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SheetField
// ─────────────────────────────────────────────────────────────────────────────

class _SheetField extends StatelessWidget {
  final TextEditingController       controller;
  final String                      label;
  final String                      hint;
  final IconData                    icon;
  final Color                       accent;
  final int                         maxLines;
  final TextInputType?               keyboardType;
  final List<TextInputFormatter>?   inputFormatters;
  final void Function(String)?      onChanged;

  const _SheetField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.accent,
    this.maxLines       = 1,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) => TextField(
        controller:      controller,
        maxLines:        maxLines,
        keyboardType:    keyboardType,
        inputFormatters: inputFormatters,
        onChanged:       onChanged,
        decoration: InputDecoration(
          labelText:  label,
          hintText:   hint,
          hintStyle:  TextStyle(
            color:    AppColors.textSecondary(context),
            fontSize: 13,
          ),
          prefixIcon: Icon(icon, size: 18, color: accent.withValues(alpha: 0.75)),
          filled:     true,
          fillColor:  AppColors.card(context),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:   BorderSide(color: AppColors.border(context)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:   BorderSide(color: accent, width: 1.5),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:   BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 14,
            vertical:   maxLines > 1 ? 12 : 0,
          ),
          floatingLabelStyle: TextStyle(
            color:      accent,
            fontWeight: FontWeight.w600,
            fontSize:   13,
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _EmptyState
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final Color        accent;
  final VoidCallback onAdd;
  const _EmptyState({required this.accent, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width:  80,
              height: 80,
              decoration: BoxDecoration(
                color:        accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(Icons.edit_note_rounded,
                  size: 38, color: accent.withValues(alpha: 0.55)),
            ),
            const SizedBox(height: 20),
            Text(
              'Sin notas todavía',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Guarda citas y reflexiones mientras lees\npara no perder nada.',
              style: TextStyle(
                fontSize: 13,
                color:    AppColors.textSecondary(context),
                height:   1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: onAdd,
              icon:      const Icon(Icons.add_rounded),
              label:     const Text('Añadir primera nota'),
              style: FilledButton.styleFrom(
                backgroundColor: accent,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ErrorState
// ─────────────────────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final String error;
  const _ErrorState({required this.error});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded,
                  size:  40,
                  color: Theme.of(context).colorScheme.error),
              const SizedBox(height: 12),
              Text('Error al cargar las notas',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(
                error,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color:    AppColors.textSecondary(context),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
}