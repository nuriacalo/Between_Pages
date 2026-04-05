// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get welcomeMessage =>
      '¡Bienvenido a Between Pages! Tu espacio para compartir y descubrir libros.';

  @override
  String get homeTitle => 'Inicio';

  @override
  String get homeDescription =>
      'Explora las últimas reseñas y recomendaciones de libros.';

  @override
  String get searchTitle => 'Buscar';

  @override
  String get searchPlaceholder => 'Busca por título, autor o género...';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get profileEditProfile => 'Editar perfil';

  @override
  String get profileLogout => 'Cerrar sesión';

  @override
  String get profileAccount => 'Cuenta';

  @override
  String get profileSettings => 'Configuración';

  @override
  String get profileNotifications => 'Notificaciones';

  @override
  String get profilePrivacy => 'Privacidad y Seguridad';

  @override
  String get profileLanguage => 'Idioma de la aplicación';

  @override
  String get loginWelcomeBack => 'Bienvenido de nuevo';

  @override
  String get loginEmail => 'Correo electrónico';

  @override
  String get loginPassword => 'Contraseña';

  @override
  String get loginButton => 'Iniciar sesión';

  @override
  String get loginNoAccount => '¿No tienes cuenta? Regístrate aquí';

  @override
  String get loginRememberMe => 'Recordarme';

  @override
  String get loginSignUp => 'Regístrate';

  @override
  String get loginForgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get loginOr => 'O inicia sesión con';

  @override
  String get loginInvalidCredentials =>
      'Credenciales inválidas. Por favor, inténtalo de nuevo.';

  @override
  String get registerTitle => 'Crear cuenta';

  @override
  String get registerName => 'Nombre completo';

  @override
  String get registerButton => 'Registrarse';

  @override
  String get registerAlreadyHaveAccount => '¿Ya tienes cuenta? Inicia sesión';

  @override
  String get registrationSuccess =>
      'Registro exitoso. Por favor, inicia sesión.';

  @override
  String get register => 'Regístrate';

  @override
  String get newAccount => 'Crear una cuenta';

  @override
  String get registerEmail => 'Correo electrónico';

  @override
  String get registerPassword => 'Contraseña';

  @override
  String get validationRequired => 'Este campo es obligatorio';

  @override
  String get validationEmail => 'Introduce un correo electrónico válido';

  @override
  String get validationPasswordLength =>
      'La contraseña debe tener al menos 6 caracteres';
}
