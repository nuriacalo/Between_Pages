import 'package:between_pages/features/catalog/domain/fanfiction_response_dto.dart';
import 'package:between_pages/features/journal/domain/journal_types.dart';
import 'package:between_pages/features/journal/domain/records/fanfic_journal_record_dto.dart';
import 'package:between_pages/features/profile/application/providers/user_provider.dart';
import 'package:between_pages/features/catalog/application/repositories/fanfic_search_repository.dart';
import 'package:between_pages/features/journal/application/providers/journal_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FanficEditPage extends ConsumerStatefulWidget {
  final FanfictionResponseDTO? fanfic;

  const FanficEditPage({super.key, this.fanfic});

  @override
  ConsumerState<FanficEditPage> createState() => _FanficEditPageState();
}

class _FanficEditPageState extends ConsumerState<FanficEditPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _sourceMaterialController;
  late TextEditingController _totalChaptersController;
  late TextEditingController _coverUrlController;
  late TextEditingController _descriptionController;
  late TextEditingController _tagsController;

  @override
  void initState() {
    super.initState();
    final fanfic = widget.fanfic;
    _titleController = TextEditingController(text: fanfic?.title ?? '');
    _authorController = TextEditingController(text: fanfic?.author ?? '');
    _sourceMaterialController = TextEditingController(text: fanfic?.sourceMaterial ?? '');
    _totalChaptersController = TextEditingController(text: fanfic?.totalChapters?.toString() ?? '');
    _coverUrlController = TextEditingController(text: fanfic?.coverUrl ?? '');
    _descriptionController = TextEditingController(text: fanfic?.description ?? '');
    _tagsController = TextEditingController(text: (fanfic?.tags ?? []).join(', '));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _sourceMaterialController.dispose();
    _totalChaptersController.dispose();
    _coverUrlController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _saveFanficAndJournal() async {
    if (!_formKey.currentState!.validate() || _isSaving) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final fanficRepo = ref.read(fanficSearchRepositoryProvider);
      final fanficToSave = FanfictionResponseDTO(
        idFanfic: widget.fanfic?.idFanfic ?? 0,
        ao3Id: widget.fanfic?.ao3Id,
        title: _titleController.text,
        author: _authorController.text,
        sourceMaterial: _sourceMaterialController.text,
        totalChapters: int.tryParse(_totalChaptersController.text),
        coverUrl: _coverUrlController.text,
        description: _descriptionController.text,
        tags: _tagsController.text.isNotEmpty
            ? _tagsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList()
            : [],
        publicationStatus: widget.fanfic?.publicationStatus ?? 'ONGOING',
      );

      final savedFanfic = await fanficRepo.saveOrUpdateFanfic(fanficToSave);

      if (widget.fanfic == null) {
        final journalRepo = ref.read(fanficJournalRepositoryProvider);
        final userId = ref.read(userProfileProvider).value!.idUser;

        final journalDto = FanficJournalRecordDTO(
          userId: userId,
          fanficId: savedFanfic.idFanfic ?? 0,
          status: 'TBR',
        );
        await journalRepo.saveRaw(journalDto.toJson());
        ref.invalidate(journalProvider(JournalType.fanfic));
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Fanfic guardado y añadido al diario con éxito'),
          backgroundColor: Colors.green,
        ));
        Navigator.pop(context, savedFanfic);
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = e.toString().replaceFirst('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $errorMessage'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fanfic == null ? 'Añadir Fanfic' : 'Editar Fanfic'),
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(24.0),
                children: [
                  _buildTextField(_titleController, 'Título', isRequired: true, icon: Icons.title),
                  _buildTextField(_authorController, 'Autor', isRequired: true, icon: Icons.person_outline),
                  _buildTextField(_sourceMaterialController, 'Fandom / Material de Origen', icon: Icons.category_outlined),
                  _buildTextField(_totalChaptersController, 'Capítulos totales', keyboardType: TextInputType.number, icon: Icons.format_list_numbered),
                  _buildTextField(_coverUrlController, 'URL de la portada', keyboardType: TextInputType.url, icon: Icons.image_outlined),
                  _buildTextField(_tagsController, 'Tags (separados por coma)', icon: Icons.local_offer_outlined),
                  _buildTextField(_descriptionController, 'Descripción', maxLines: 5, icon: Icons.description_outlined),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _isSaving ? null : _saveFanficAndJournal,
                      icon: const Icon(Icons.save),
                      label: const Text('Guardar Fanfic', style: TextStyle(fontSize: 16)),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool isRequired = false,
    TextInputType? keyboardType,
    int? maxLines = 1,
    IconData? icon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon, size: 20, color: colorScheme.primary) : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: colorScheme.outlineVariant.withOpacity(0.4),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: colorScheme.primary,
              width: 1.5,
            ),
          ),
          filled: true,
          fillColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF8F5FF),
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return 'Este campo es requerido';
          }
          return null;
        },
      ),
    );
  }
}