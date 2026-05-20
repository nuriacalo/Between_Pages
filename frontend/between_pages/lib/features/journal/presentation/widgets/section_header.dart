import 'package:flutter/material.dart';

// ── Header de sección ─────────────────────────────────────────────────────

@Deprecated('Unused')
class _SectionHeader extends StatelessWidget {

  final String label;
  final IconData icon;

  const _SectionHeader({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Divider(
            color: Theme.of(context).colorScheme.primary.withValues(alpha:0.2),
          ),
        ),
      ],
    );
  }
}

// ── Tarjeta "Segundo Cerebro" ─────────────────────────────────────────────

class _SecondBrainCard extends StatelessWidget {
  final TextEditingController pageController;
  final TextEditingController quotesController;
  final VoidCallback onScannerTap;

  const _SecondBrainCard({
    required this.pageController,
    required this.quotesController,
    required this.onScannerTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1C1B2E) : const Color(0xFFF3F0FF);
    final borderColor = isDark ? const Color(0xFF3D3660) : const Color(0xFFD4CCF5);
    const accent = Color(0xFF7C6FC4);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con icono y botón scanner
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha:0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.psychology_outlined, color: accent, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Segundo Cerebro',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: accent,
                      ),
                    ),
                    Text(
                      'Tus notas y citas de este libro',
                      style: TextStyle(
                        fontSize: 11,
                        color: accent.withValues(alpha:0.7),
                      ),
                    ),
                  ],
                ),
              ),
              // Botón scanner — funcionalidad pendiente
              Tooltip(
                message: 'Escanear texto (próximamente)',
                child: InkWell(
                  onTap: onScannerTap,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha:0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: accent.withValues(alpha:0.25)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.document_scanner_outlined, color: accent, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'Escanear',
                          style: TextStyle(
                            fontSize: 12,
                            color: accent.withValues(alpha:0.85),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Campo página actual
          TextField(
            controller: pageController,
            decoration: InputDecoration(
              labelText: 'Página actual',
              prefixIcon: const Icon(Icons.book_outlined, size: 18),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),

          // Campo citas
          TextField(
            controller: quotesController,
            maxLines: 5,
            minLines: 3,
            decoration: InputDecoration(
              hintText: 'Guarda frases que te han marcado...',
              hintStyle: TextStyle(color: accent.withValues(alpha:0.4), fontSize: 13),
              filled: true,
              fillColor: isDark
                  ? const Color(0xFF16152A)
                  : Colors.white.withValues(alpha:0.7),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: accent, width: 1.5),
              ),
              prefixIcon: const Padding(
                padding: EdgeInsets.only(left: 12, right: 8, top: 12),
                child: Icon(Icons.format_quote_rounded, color: accent, size: 20),
              ),
              prefixIconConstraints: const BoxConstraints(),
              contentPadding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bottom sheet "próximamente" ───────────────────────────────────────────

void _showComingSoonSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) {
      return Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFF7C6FC4).withValues(alpha:0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.document_scanner_outlined,
                color: Color(0xFF7C6FC4),
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Funcionalidad en camino',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'El escáner OCR te permitirá fotografiar cualquier página y extraer el texto automáticamente. Estamos trabajando en ello.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF7C6FC4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Entendido'),
              ),
            ),
          ],
        ),
      );
    },
  );
}