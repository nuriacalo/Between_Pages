import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_colors.dart'; 

class BetweenPagesLogo extends StatelessWidget {
  final double fontSize;
  final bool useSvg;

  const BetweenPagesLogo({
    super.key, 
    this.fontSize = 28.0,
    // Pon esto a 'true' cuando hayas añadido el archivo SVG a tus assets
    this.useSvg = false, 
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Aquí decidimos si mostrar el SVG o un icono temporal
        if (useSvg)
          SvgPicture.asset(
            'assets/icons/between_pages_icon.svg', // Asegúrate de que la ruta coincida
            height: fontSize * 1.3,
          )
        else
          Icon(
            Icons.menu_book_rounded, // Icono más parecido al de tu captura
            color: AppColors.accent(context),
            size: fontSize * 1.2,
          ),
          
        const SizedBox(width: 8.0),
        
        // Tipografía del logo
        Text.rich(
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
      ],
    );
  }
}