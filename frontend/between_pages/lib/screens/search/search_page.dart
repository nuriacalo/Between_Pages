import 'package:between_pages/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Center(
      child: Text(l10n.searchPlaceholder),
    );
  }
}
