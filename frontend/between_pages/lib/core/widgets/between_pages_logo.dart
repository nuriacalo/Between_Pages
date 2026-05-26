import 'package:flutter/material.dart';
import '../theme/app_colors.dart'; 

class BetweenPagesLogo extends StatelessWidget {
  final double fontSize;
  final bool useImage;

  const BetweenPagesLogo({
    super.key, 
    this.fontSize = 108.0,
    this.useImage = false, 
  });

  @override
  Widget build(BuildContext context) {
return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // TEMP: marcador para verificar que cambie fontSize
        Text(
          'fontSize=$fontSize useImage=$useImage',
          style: const TextStyle(color: Colors.red, fontSize: 12),
        ),
        if (useImage)
          Image.asset(
            'assets/img/logo.png',
            height: fontSize * 1.3,
          )
        else
          Icon(
            Icons.menu_book_rounded,
            color: AppColors.accent(context),
            size: fontSize * 1.2,
          ),
      ],
    );
  }
}