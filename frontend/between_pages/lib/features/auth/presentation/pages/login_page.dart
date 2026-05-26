import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Asegúrate de que las rutas de importación coinciden con tu estructura de carpetas
import 'package:between_pages/core/theme/app_colors.dart';
import 'package:between_pages/core/widgets/between_pages_logo.dart';
import 'package:between_pages/features/auth/application/controllers/auth_controller.dart';
import 'package:between_pages/l10n/app_localizations.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Método para mostrar el pop-up de "En desarrollo"
  void _showComingSoonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.build_circle_outlined, color: AppColors.accent(context)),
            const SizedBox(width: 8),
            Text(
              'En desarrollo',
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'Esta funcionalidad de inicio de sesión social estará disponible en próximas actualizaciones. ¡Estamos trabajando en ello!',
          style: TextStyle(color: AppColors.textSecondary(context)),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(), // Cierra el pop-up
            child: Text(
              'Entendido',
              style: TextStyle(
                color: AppColors.accent(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    // Escuchamos el estado de autenticación para mostrar errores
    ref.listen<AsyncValue<void>>(authControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stackTrace) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.toString()),
              backgroundColor: AppColors.logout(context),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        },
      );
    });

    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    // Estilos comunes para los inputs utilizando tu clase AppColors
    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: AppColors.surface(context),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.border(context), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.accent(context), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.logout(context), width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.logout(context), width: 2),
      ),
      labelStyle: TextStyle(color: AppColors.textSecondary(context)),
      prefixIconColor: AppColors.icons(context),
    );

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 32.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo visual
                  const Center(child: BetweenPagesLogo(fontSize: 34.0, useImage: true)),
                  const SizedBox(height: 32),

                  // Input Email
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(color: AppColors.textPrimary(context)),
                    decoration: inputDecoration.copyWith(
                      labelText: l10n.loginEmail,
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return l10n.validationRequired;
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) return l10n.validationEmail;
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Input Contraseña
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: TextStyle(color: AppColors.textPrimary(context)),
                    decoration: inputDecoration.copyWith(
                      labelText: l10n.loginPassword,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        color: AppColors.icons(context),
                        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return l10n.validationRequired;
                      return null;
                    },
                  ),
                  const SizedBox(height: 4),

                  // Checkbox Recordarme
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        activeColor: AppColors.accent(context),
                        side: BorderSide(color: AppColors.border(context), width: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        onChanged: (value) => setState(() => _rememberMe = value ?? false),
                      ),
                      Expanded(
                        child: Text(
                          l10n.loginRememberMe,
                          style: TextStyle(color: AppColors.textSecondary(context)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Botón Principal de Iniciar Sesión
                  ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              ref.read(authControllerProvider.notifier).login(
                                    _emailController.text,
                                    _passwordController.text,
                                  );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent(context),
                      foregroundColor: AppColors.lightSurface,
                      minimumSize: const Size(double.infinity, 50),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                          )
                        : Text(
                            l10n.loginButton,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                  const SizedBox(height: 4),

                  // Enlace a Registro
                  TextButton(
                    onPressed: () => context.push('/register'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.accent(context),
                    ),
                    child: Text(
                      l10n.loginNoAccount,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Divisor visual (O inicia sesión con)
                  Row(
                    children: [
                      Expanded(child: Divider(color: AppColors.border(context))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          l10n.loginOr,
                          style: TextStyle(color: AppColors.textSecondary(context)),
                        ),
                      ),
                      Expanded(child: Divider(color: AppColors.border(context))),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Botones Sociales con Pop-up integrado
                  OutlinedButton.icon(
                    icon: Icon(Icons.g_mobiledata, size: 28, color: AppColors.textPrimary(context)),
                    label: Text(
                      'Google',
                      style: TextStyle(color: AppColors.textPrimary(context), fontWeight: FontWeight.w600),
                    ),
                    onPressed: () => _showComingSoonDialog(context),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      side: BorderSide(color: AppColors.border(context), width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    icon: Icon(Icons.menu_book, color: AppColors.textPrimary(context)),
                    label: Text(
                      'Goodreads',
                      style: TextStyle(color: AppColors.textPrimary(context), fontWeight: FontWeight.w600),
                    ),
                    onPressed: () => _showComingSoonDialog(context),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      side: BorderSide(color: AppColors.border(context), width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}