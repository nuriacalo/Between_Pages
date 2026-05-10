import 'package:between_pages/features/lists/application/providers/list_provider.dart';
import 'package:between_pages/features/lists/application/repositories/reading_list_repository.dart';
import 'package:between_pages/features/lists/domain/reading_list_request_dto.dart';
import 'package:between_pages/features/profile/application/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'list_detail_page.dart';
import 'package:between_pages/l10n/app_localizations.dart';

class ReadingListsPage extends ConsumerStatefulWidget {
  const ReadingListsPage({super.key});

  @override
  ConsumerState<ReadingListsPage> createState() => _ReadingListsPageState();
}

class _ReadingListsPageState extends ConsumerState<ReadingListsPage> {
  final _formKey = GlobalKey<FormState>();

  void _showCreateListDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    bool isSaving = false;
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.createNewListButton),
        content: StatefulBuilder(
          builder: (context, setDialogState) => Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: l10n.listNameLabel),
                  validator: (value) => value?.isEmpty ?? true ? l10n.validationRequired : null,
                ),
                TextFormField(
                  controller: descController,
                  decoration: InputDecoration(labelText: l10n.listDescLabel),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: isSaving ? null : () => Navigator.pop(context),
            child: Text(l10n.cancelButton),
          ),
          StatefulBuilder(
            builder: (context, setBtnState) => ElevatedButton(
              onPressed: isSaving ? null : () async {
                if (_formKey.currentState!.validate()) {
                  setBtnState(() => isSaving = true);
                  try {
                    final user = await ref.read(userProfileProvider.future);
                    final repo = ref.read(readingListRepositoryProvider);
                    
                    await repo.createList(
                      user.idUser,
                      ReadingListRequestDTO(
                        name: nameController.text.trim(),
                        description: descController.text.trim(),
                      ),
                    );
                    
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.listCreatedSuccess)),
                      );
                      ref.invalidate(listProvider);
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${l10n.listCreateError}: $e')),
                      );
                    }
                  } finally {
                    if (context.mounted) setBtnState(() => isSaving = false);
                  }
                }
              },
              child: isSaving 
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(l10n.createButton),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final listsAsync = ref.watch(listProvider);


    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.myListsTitle,
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        backgroundColor: colorScheme.surface,
      ),
      body: listsAsync.when(
        data: (lists) {
          if (lists.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.list_alt,
                    size: 64,
                    color: colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.emptyListsTitle,
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.emptyListsSubtitle,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _showCreateListDialog(context, ref),
                    icon: const Icon(Icons.add),
                    label: Text(l10n.createListButton),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: lists.length + 1, // +1 para el botón de crear al final
            itemBuilder: (context, index) {
              if (index == lists.length) {
                // Último elemento: botón para crear nueva lista
                return Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: OutlinedButton.icon(
                    onPressed: () => _showCreateListDialog(context, ref),
                    icon: const Icon(Icons.add),
                    label: Text(l10n.createNewListButton),
                  ),
                );
              }

              final list = lists[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: colorScheme.primaryContainer,
                    child: Icon(
                      Icons.list,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  title: Text(
                    list.name,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: list.description != null
                      ? Text(
                          list.description!,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        )
                      : Text(
                          l10n.listNoDescription,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ListDetailPage(list: list),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.errorLoadingLists,
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.error,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(listProvider),
                child: Text(l10n.retryButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
