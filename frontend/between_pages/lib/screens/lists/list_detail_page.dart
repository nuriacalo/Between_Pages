import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:between_pages/models/lists/list_response_dto.dart';
import 'package:between_pages/core/router/app_router.dart';
import 'package:between_pages/l10n/app_localizations.dart';

class ListDetailPage extends ConsumerWidget {
  final ListResponseDTO list;

  const ListDetailPage({super.key, required this.list});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(list.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {}, // TODO: Edit list
          ),
        ],
      ),
      body: Column(
        children: [
          if (list.description != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: colorScheme.surfaceVariant,
              child: Text(
                list.description!,
                style: textTheme.bodyLarge,
              ),
            ),
          ],
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 0, // MVP: lista vacía hasta add items impl
              itemBuilder: (context, index) => const Card(
                child: ListTile(title: Text('Item de lista (placeholder)')),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {}, // TODO: Add item to list
        child: const Icon(Icons.add),
      ),
    );
  }
}
