// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get welcomeMessage =>
      'Welcome to Between Pages! Your space to share and discover books.';

  @override
  String get homeTitle => 'Home';

  @override
  String get homeDescription =>
      'Explore the latest book reviews and recommendations.';

  @override
  String get searchTitle => 'Search';

  @override
  String get searchPlaceholder => 'Search by title, author, or genre...';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileEditProfile => 'Edit Profile';

  @override
  String get profileLogout => 'Log Out';

  @override
  String get profileAccount => 'Account';

  @override
  String get profileSettings => 'Settings';

  @override
  String get profileNotifications => 'Notifications';

  @override
  String get profilePrivacy => 'Privacy and Security';

  @override
  String get profileLanguage => 'App Language';

  @override
  String get loginWelcomeBack => 'Welcome back';

  @override
  String get loginEmail => 'Email address';

  @override
  String get loginPassword => 'Password';

  @override
  String get loginButton => 'Login';

  @override
  String get loginNoAccount => 'Don\'t have an account? Register here';

  @override
  String get loginRememberMe => 'Remember me';

  @override
  String get loginSignUp => 'Sign Up';

  @override
  String get loginForgotPassword => 'Forgot your password?';

  @override
  String get loginOr => 'Or log in with';

  @override
  String get loginInvalidCredentials =>
      'Invalid credentials. Please try again.';

  @override
  String get registerTitle => 'Create Account';

  @override
  String get registerName => 'Full Name';

  @override
  String get registerButton => 'Sign Up';

  @override
  String get registerAlreadyHaveAccount => 'Already have an account? Log in';

  @override
  String get registrationSuccess => 'Registration successful. Please log in.';

  @override
  String get register => 'Sign Up';

  @override
  String get newAccount => 'Create an account';

  @override
  String get registerEmail => 'Email address';

  @override
  String get registerPassword => 'Password';

  @override
  String get validationRequired => 'This field is required';

  @override
  String get validationEmail => 'Enter a valid email address';

  @override
  String get validationPasswordLength =>
      'Password must be at least 6 characters';
}
