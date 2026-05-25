import 'package:flutter/material.dart';
import '../theme/app_colors.dart'; 

class BetweenPagesLogo extends StatelessWidget {
  final double fontSize;
  final bool useImage;

  const BetweenPagesLogo({
    super.key, 
    this.fontSize = 28.0,
    this.useImage = false, 
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
children: [
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
          
        const SizedBox(width: 8.0),
        
        // Tipografía del logo
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Between',
                    style: TextStyle(
                      fontFamily: 'Lora',
                      fontWeight: FontWeight.w700, // Negrita para el "Between"
                      color: AppColors.textPrimary(context),
                      fontSize: fontSize,
                    ),
                  ),
                  TextSpan(
                    text: 'Pages',
                    style: TextStyle(
                      fontFamily: 'Lora',
                      fontWeight: FontWeight.w500, 
                      fontStyle: FontStyle.italic,
                      color: AppColors.accent(context),
                      fontSize: fontSize,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}