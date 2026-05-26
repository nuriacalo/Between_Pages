import 'package:flutter/material.dart';
import '../theme/app_colors.dart'; 

class BetweenPagesLogo extends StatelessWidget {
  final double fontSize;
  final bool useImage;

  const BetweenPagesLogo({
    super.key,
    this.fontSize = 38.0,
    this.useImage = false,
  });

  @override
  Widget build(BuildContext context) {
    const baseSizeFactor = 240.0;

    return SizedBox(
      width: baseSizeFactor,
      height: baseSizeFactor,
      child: Center(
        child: useImage
            ? Image.asset(
                'lib/assets/img/logo2.png',
                width: baseSizeFactor,
                height: baseSizeFactor,
                fit: BoxFit.contain,
              )
            : Icon(
                Icons.menu_book_rounded,
                color: AppColors.accent(context),
                size: baseSizeFactor,
              ),
      ),
    );
  }
}

