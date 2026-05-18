import 'package:between_pages/features/notes/presentation/widget/second_brain_tab.dart';
import 'package:flutter/material.dart';

class NotesPage extends StatelessWidget {
  final int bookId;

  const NotesPage({super.key, required this.bookId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
      ),
      body: SafeArea(
        child: SecondBrainTab(itemType: 'BOOK', itemId: bookId),
      ),
    );
  }
}