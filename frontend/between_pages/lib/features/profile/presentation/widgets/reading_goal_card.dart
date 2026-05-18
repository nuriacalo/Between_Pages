import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class ReadingGoalCard extends StatefulWidget {
  final int booksRead;
  final int goal;
  final VoidCallback onEditGoal;

  const ReadingGoalCard({
    super.key,
    required this.booksRead,
    required this.goal,
    required this.onEditGoal,
  });

  @override
  State<ReadingGoalCard> createState() => _ReadingGoalCardState();
}

class _ReadingGoalCardState extends State<ReadingGoalCard> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void didUpdateWidget(ReadingGoalCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the goal was not met before, but is met now, play animation!
    if (oldWidget.booksRead < widget.goal && widget.booksRead >= widget.goal) {
      _confettiController.play();
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double percent = (widget.booksRead / (widget.goal > 0 ? widget.goal : 1)).clamp(0.0, 1.0);
    final bool isGoalMet = widget.booksRead >= widget.goal;
    final theme = Theme.of(context);

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            onTap: widget.onEditGoal,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${DateTime.now().year} Reading Goal',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isGoalMet
                              ? 'Goal Achieved! Keep it up!'
                              : '${widget.goal - widget.booksRead} more to go',
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  CircularPercentIndicator(
                    radius: 32.0,
                    lineWidth: 6.0,
                    percent: percent,
                    center: Text(
                      '${widget.booksRead}/${widget.goal}',
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    progressColor: isGoalMet ? Colors.amber : theme.colorScheme.primary,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                    circularStrokeCap: CircularStrokeCap.round,
                    animation: true,
                  ),
                ],
              ),
            ),
          ),
        ),
        ConfettiWidget(
          confettiController: _confettiController,
          blastDirectionality: BlastDirectionality.explosive,
          shouldLoop: false,
          numberOfParticles: 20,
          gravity: 0.3,
          emissionFrequency: 0.05,
          colors: const [
            Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple
          ],
        ),
      ],
    );
  }
}
