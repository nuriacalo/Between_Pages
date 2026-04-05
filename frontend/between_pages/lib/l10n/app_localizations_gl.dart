// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Galician (`gl`).
class AppLocalizationsGl extends AppLocalizations {
  AppLocalizationsGl([String locale = 'gl']) : super(locale);

  @override
  String get welcomeMessage =>
      'Benvida a Between Pages! O teu espazo para compartir e descubrir libros.';

  @override
  String get homeTitle => 'Inicio';

  @override
  String get homeDescription =>
      'Explora as últimas recensións e recomendacións de libros.';

  @override
  String get searchTitle => 'Buscar';

  @override
  String get searchPlaceholder => 'Busca por título, autor ou xénero...';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get profileEditProfile => 'Editar perfil';

  @override
  String get profileLogout => 'Pechar sesión';

  @override
  String get profileAccount => 'Conta';

  @override
  String get profileSettings => 'Configuración';

  @override
  String get profileNotifications => 'Notificacións';

  @override
  String get profilePrivacy => 'Privacidade e Seguridade';

  @override
  String get profileLanguage => 'Idioma da aplicación';

  @override
  String get loginWelcomeBack => 'Benvida de novo';

  @override
  String get loginEmail => 'Correo electrónico';

  @override
  String get loginPassword => 'Contrasinal';

  @override
  String get loginButton => 'Iniciar sesión';

  @override
  String get loginNoAccount => 'Non tes unha conta? Rexístrate aquí';

  @override
  String get loginRememberMe => 'Lembrarme';

  @override
  String get loginSignUp => 'Rexístrate';

  @override
  String get loginForgotPassword => 'Esqueciches o teu contrasinal?';

  @override
  String get loginOr => 'Ou inicia sesión con';

  @override
  String get loginInvalidCredentials =>
      'Credenciais inválidas. Por favor, inténtao de novo.';

  @override
  String get registerTitle => 'Crear conta';

  @override
  String get registerName => 'Nome completo';

  @override
  String get registerButton => 'Rexistrarse';

  @override
  String get registerAlreadyHaveAccount => 'Xa tes unha conta? Inicia sesión';

  @override
  String get registrationSuccess =>
      'Rexistro completado. Por favor, inicia sesión.';

  @override
  String get register => 'Rexístrate';

  @override
  String get newAccount => 'Crear unha conta';

  @override
  String get registerEmail => 'Correo electrónico';

  @override
  String get registerPassword => 'Contrasinal';

  @override
  String get validationRequired => 'Este campo é obrigatorio';

  @override
  String get validationEmail => 'Introduce un correo electrónico válido';

  @override
  String get validationPasswordLength =>
      'O contrasinal debe ter polo menos 6 caracteres';
}
