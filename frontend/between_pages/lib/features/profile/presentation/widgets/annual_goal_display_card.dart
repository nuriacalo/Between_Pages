import 'package:between_pages/features/profile/application/providers/annual_goal_provider.dart';
import 'package:between_pages/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class AnnualGoalDisplayCard extends ConsumerWidget {
  final AnnualGoal goal;

  const AnnualGoalDisplayCard({super.key, required this.goal});

  void _showGoalDialog(BuildContext context, WidgetRef ref, AnnualGoal currentGoal) {
    final controller = TextEditingController(text: currentGoal.target.toString());
    showDialog(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(l10n.editGoal),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: l10n.setYourGoal),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancelButton),
            ),
            FilledButton(
              onPressed: () {
                final newTarget = int.tryParse(controller.text);
                if (newTarget != null) {
                  ref.read(annualGoalProvider.notifier).setGoal(newTarget);
                  Navigator.pop(context);
                }
              },
              child: Text(l10n.saveButton),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final double percent = (goal.completed / (goal.target > 0 ? goal.target : 1)).clamp(0.0, 1.0);
    final bool isGoalMet = goal.completed >= goal.target;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: InkWell(
        onTap: () => _showGoalDialog(context, ref, goal),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.annualGoal,
                      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isGoalMet
                          ? l10n.goalAchieved
                          : l10n.booksToGo(goal.target - goal.completed),
                      style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${goal.completed} / ${goal.target} ${l10n.booksRead}',
                      style: textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              CircularPercentIndicator(
                radius: 40.0,
                lineWidth: 8.0,
                percent: percent,
                center: Icon(
                  isGoalMet ? Icons.emoji_events : Icons.book,
                  size: 30.0,
                  color: isGoalMet ? Colors.amber : colorScheme.primary,
                ),
                progressColor: isGoalMet ? Colors.amber : colorScheme.primary,
                backgroundColor: colorScheme.primary.withValues(alpha:0.2),
                circularStrokeCap: CircularStrokeCap.round,
                animation: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}