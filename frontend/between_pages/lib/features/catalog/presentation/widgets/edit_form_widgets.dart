import 'package:between_pages/core/theme/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CoverPreviewHeader
//
// Shows a live preview of the cover as the user types a URL.
// Accepts [accentColor] and [fallbackIcon] to adapt to book / manga / fanfic.
// ─────────────────────────────────────────────────────────────────────────────

class CoverPreviewHeader extends StatefulWidget {
  final TextEditingController coverUrlController;
  final Color                 accentColor;
  final IconData              fallbackIcon;

  const CoverPreviewHeader({
    super.key,
    required this.coverUrlController,
    required this.accentColor,
    required this.fallbackIcon,
  });

  @override
  State<CoverPreviewHeader> createState() => _CoverPreviewHeaderState();
}

class _CoverPreviewHeaderState extends State<CoverPreviewHeader> {
  String? _displayUrl;

  @override
  void initState() {
    super.initState();
    _displayUrl = widget.coverUrlController.text.trim().isEmpty
        ? null
        : widget.coverUrlController.text.trim();
    widget.coverUrlController.addListener(_onUrlChanged);
  }

  void _onUrlChanged() {
    final url = widget.coverUrlController.text.trim();
    if (url != _displayUrl) {
      setState(() => _displayUrl = url.isEmpty ? null : url);
    }
  }

  @override
  void dispose() {
    widget.coverUrlController.removeListener(_onUrlChanged);
    super.dispose();
  }

  void _editUrl(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          20, 16, 20,
          MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36, height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color:        Theme.of(ctx).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              'URL de la portada',
              style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller:   widget.coverUrlController,
              label:        'https://…',
              icon:         Icons.image_outlined,
              accentColor:  widget.accentColor,
              keyboardType: TextInputType.url,
              autofocus:    true,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(ctx),
                style: FilledButton.styleFrom(
                  backgroundColor: widget.accentColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Confirmar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.accentColor;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: GestureDetector(
          onTap: () => _editUrl(context),
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  // Cover or placeholder
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox( //FIX: Changed border radius from 12 to 14
                      width: 90,
                      height: 135,
                      child: _displayUrl != null && _displayUrl!.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl:    _displayUrl!,
                              fit:         BoxFit.cover,
                              placeholder: (_, _) => _Placeholder(
                                color: color,
                                icon:  widget.fallbackIcon,
                              ),
                              errorWidget: (_, _, _) => _Placeholder(
                                color: color,
                                icon:  widget.fallbackIcon,
                              ),
                            )
                          : _Placeholder(
                              color: color,
                              icon:  widget.fallbackIcon,
                            ),
                    ),
                  ),
                  // Edit badge
                  Positioned(
                    bottom: -6,
                    right:  -6,
                    child: Container(
                      width:  26,
                      height: 26,
                      decoration: BoxDecoration(
                        color:  color,
                        shape:  BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).colorScheme.surface,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        size:  13,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Toca para cambiar la portada',
                style: TextStyle(
                  fontSize: 11,
                  color:    AppColors.textSecondary(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  final Color    color;
  final IconData icon;
  const _Placeholder({required this.color, required this.icon});

  @override
  Widget build(BuildContext context) => Container(
        color: color.withValues(alpha:0.12),
        child: Center(
          child: Icon(icon, size: 34, color: color.withValues(alpha:0.5)),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// FormSection
//
// Labelled section header that groups related form fields.
// ─────────────────────────────────────────────────────────────────────────────

class FormSection extends StatelessWidget {
  final String         label;
  final List<Widget>   children;
  final Color?         accentColor;

  const FormSection({
    super.key,
    required this.label,
    required this.children,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? AppColors.accent(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section label
        Row(
          children: [
            Container(
              width:  3,
              height: 13,
              margin: const EdgeInsets.only(right: 7),
              decoration: BoxDecoration(
                color:        color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize:      10,
                fontWeight:    FontWeight.bold,
                color:         AppColors.textSecondary(context),
                letterSpacing: 0.7,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...children,
        const SizedBox(height: 20),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AppTextField
//
// Styled form field using AppColors. Shared by all three edit pages.
// ─────────────────────────────────────────────────────────────────────────────

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String                label;
  final IconData?             icon;
  final Color?                accentColor;
  final bool                  isRequired;
  final TextInputType?        keyboardType;
  final int?                  maxLines;
  final bool                  autofocus;
  final String?               hint;
  final List<TextInputFormatter>? inputFormatters;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.icon,
    this.accentColor,
    this.isRequired     = false,
    this.keyboardType,
    this.maxLines       = 1,
    this.autofocus      = false,
    this.hint,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    final isDark      = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final accent      = accentColor ?? colorScheme.primary;
    final fillColor   = isDark ? AppColors.darkCard : AppColors.lightCard;

    return TextFormField(
      controller:       controller,
      autofocus:        autofocus,
      keyboardType:     keyboardType,
      maxLines:         maxLines,
      inputFormatters:  inputFormatters ??
          (keyboardType == TextInputType.number
              ? [FilteringTextInputFormatter.digitsOnly]
              : null),
      validator: isRequired
          ? (v) => (v == null || v.trim().isEmpty) ? 'Campo requerido' : null
          : null,
      decoration: InputDecoration(
        labelText:   isRequired ? '$label *' : label,
        hintText:    hint,
        prefixIcon:  icon != null
            ? Icon(icon, size: 18, color: accent.withValues(alpha:0.75))
            : null,
        filled:      true,
        fillColor:   fillColor,
        // Default border
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.border(context),
          ),
        ),
        // Focused border
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accent, width: 1.5),
        ),
        // Error border
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        labelStyle: TextStyle(color: AppColors.textSecondary(context)),
        floatingLabelStyle: TextStyle(
          color:      accent,
          fontWeight: FontWeight.w600,
          fontSize:   13,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 14,
          vertical:   maxLines != null && maxLines! > 1 ? 14 : 0,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TwoColumnRow
//
// Lays out two fields side-by-side. Used for short numeric fields.
// ─────────────────────────────────────────────────────────────────────────────

class TwoColumnRow extends StatelessWidget {
  final Widget left;
  final Widget right;

  const TwoColumnRow({super.key, required this.left, required this.right});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(child: left),
          const SizedBox(width: 10),
          Expanded(child: right),
        ],
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// SaveButton
//
// Full-width save button, adapts colour and label per content type.
// ─────────────────────────────────────────────────────────────────────────────

class SaveButton extends StatelessWidget {
  final String       label;
  final IconData     icon;
  final Color        color;
  final bool         isLoading;
  final VoidCallback onTap;

  const SaveButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: isLoading ? null : onTap,
          icon:  isLoading
              ? const SizedBox(
                  width: 18, height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Icon(icon),
          label: Text(label, style: const TextStyle(fontSize: 15)),
          style: FilledButton.styleFrom(
            backgroundColor: color,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
}
