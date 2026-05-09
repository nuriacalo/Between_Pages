import 'package:flutter/material.dart';

class StarRatingWidget extends StatelessWidget {
  final int rating;
  final int maxRating;
  final Color filledColor;
  final Color emptyColor;
  final double size;
  final VoidCallback? onRatingChanged;

  const StarRatingWidget({
    super.key,
    required this.rating,
    this.maxRating = 10,
    this.filledColor = Colors.amber,
    this.emptyColor = Colors.grey,
    this.size = 24.0,
    this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxRating, (index) {
        final isFilled = index < rating;
        return IconButton(
          icon: Icon(
            isFilled ? Icons.star : Icons.star_border,
            color: isFilled ? filledColor : emptyColor,
            size: size,
          ),
          onPressed: onRatingChanged != null ? () => onRatingChanged!() : null,
        );
      }),
    );
  }
}

