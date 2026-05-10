import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_gl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('gl')
  ];

  /// No description provided for @welcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Between Pages! Your space to share and discover books.'**
  String get welcomeMessage;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTitle;

  /// No description provided for @homeDescription.
  ///
  /// In en, this message translates to:
  /// **'Explore the latest book reviews and recommendations.'**
  String get homeDescription;

  /// No description provided for @searchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchTitle;

  /// No description provided for @catalogTitle.
  ///
  /// In en, this message translates to:
  /// **'Catalog'**
  String get catalogTitle;

  /// No description provided for @journalTitle.
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get journalTitle;

  /// No description provided for @searchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search by title, author, or genre...'**
  String get searchPlaceholder;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileEditProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get profileEditProfile;

  /// No description provided for @profileLogout.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get profileLogout;

  /// No description provided for @profileAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get profileAccount;

  /// No description provided for @profileSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profileSettings;

  /// No description provided for @profileNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get profileNotifications;

  /// No description provided for @profilePrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy and Security'**
  String get profilePrivacy;

  /// No description provided for @profileLanguage.
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get profileLanguage;

  /// No description provided for @loginWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get loginWelcomeBack;

  /// No description provided for @loginEmail.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get loginEmail;

  /// No description provided for @loginPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPassword;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @loginNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Register here'**
  String get loginNoAccount;

  /// No description provided for @loginRememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get loginRememberMe;

  /// No description provided for @loginSignUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get loginSignUp;

  /// No description provided for @loginForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get loginForgotPassword;

  /// No description provided for @loginOr.
  ///
  /// In en, this message translates to:
  /// **'Or log in with'**
  String get loginOr;

  /// No description provided for @loginInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid credentials. Please try again.'**
  String get loginInvalidCredentials;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get registerTitle;

  /// No description provided for @registerName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get registerName;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get registerButton;

  /// No description provided for @registerAlreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Log in'**
  String get registerAlreadyHaveAccount;

  /// No description provided for @registrationSuccess.
  ///
  /// In en, this message translates to:
  /// **'Registration successful. Please log in.'**
  String get registrationSuccess;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get register;

  /// No description provided for @newAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get newAccount;

  /// No description provided for @registerEmail.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get registerEmail;

  /// No description provided for @registerPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get registerPassword;

  /// No description provided for @validationRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get validationRequired;

  /// No description provided for @validationEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get validationEmail;

  /// No description provided for @validationPasswordLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get validationPasswordLength;

  /// No description provided for @secondBrainTooltip.
  ///
  /// In en, this message translates to:
  /// **'Second Brain'**
  String get secondBrainTooltip;

  /// No description provided for @tabBooks.
  ///
  /// In en, this message translates to:
  /// **'Books'**
  String get tabBooks;

  /// No description provided for @tabMangas.
  ///
  /// In en, this message translates to:
  /// **'Manga'**
  String get tabMangas;

  /// No description provided for @tabFanfics.
  ///
  /// In en, this message translates to:
  /// **'Fanfics'**
  String get tabFanfics;

  /// No description provided for @emptyJournalBooksTitle.
  ///
  /// In en, this message translates to:
  /// **'You have no books in your Journal'**
  String get emptyJournalBooksTitle;

  /// No description provided for @emptyJournalBooksSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start adding books to see your progress.'**
  String get emptyJournalBooksSubtitle;

  /// No description provided for @emptyJournalMangasTitle.
  ///
  /// In en, this message translates to:
  /// **'You have no manga in your Journal'**
  String get emptyJournalMangasTitle;

  /// No description provided for @emptyJournalMangasSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start adding manga to see your progress.'**
  String get emptyJournalMangasSubtitle;

  /// No description provided for @emptyJournalFanficsTitle.
  ///
  /// In en, this message translates to:
  /// **'You have no fanfics in your Journal'**
  String get emptyJournalFanficsTitle;

  /// No description provided for @emptyJournalFanficsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start adding fanfics to see your progress.'**
  String get emptyJournalFanficsSubtitle;

  /// No description provided for @statusReading.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get statusReading;

  /// No description provided for @statusTBR.
  ///
  /// In en, this message translates to:
  /// **'To Be Read'**
  String get statusTBR;

  /// No description provided for @statusPaused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get statusPaused;

  /// No description provided for @statusFinished.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get statusFinished;

  /// No description provided for @statusWishlist.
  ///
  /// In en, this message translates to:
  /// **'Wishlist'**
  String get statusWishlist;

  /// No description provided for @statusDropped.
  ///
  /// In en, this message translates to:
  /// **'Dropped'**
  String get statusDropped;

  /// No description provided for @emptyCatalogBooks.
  ///
  /// In en, this message translates to:
  /// **'No books in the catalog'**
  String get emptyCatalogBooks;

  /// No description provided for @emptyCatalogMangas.
  ///
  /// In en, this message translates to:
  /// **'No manga in the catalog'**
  String get emptyCatalogMangas;

  /// No description provided for @emptyCatalogFanfics.
  ///
  /// In en, this message translates to:
  /// **'No fanfics in the catalog'**
  String get emptyCatalogFanfics;

  /// No description provided for @greetingNight.
  ///
  /// In en, this message translates to:
  /// **'Good night'**
  String get greetingNight;

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get greetingAfternoon;

  /// No description provided for @inProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgressTitle;

  /// No description provided for @nothingReading.
  ///
  /// In en, this message translates to:
  /// **'You are not reading anything right now'**
  String get nothingReading;

  /// No description provided for @searchBooksHint.
  ///
  /// In en, this message translates to:
  /// **'Type something to search for books'**
  String get searchBooksHint;

  /// No description provided for @searchBooksEmpty.
  ///
  /// In en, this message translates to:
  /// **'No books found'**
  String get searchBooksEmpty;

  /// No description provided for @searchFanficsHint.
  ///
  /// In en, this message translates to:
  /// **'Type something to search for fanfics'**
  String get searchFanficsHint;

  /// No description provided for @searchFanficsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No fanfics found'**
  String get searchFanficsEmpty;

  /// No description provided for @searchMangasHint.
  ///
  /// In en, this message translates to:
  /// **'Type something to search for manga'**
  String get searchMangasHint;

  /// No description provided for @searchMangasEmpty.
  ///
  /// In en, this message translates to:
  /// **'No manga found'**
  String get searchMangasEmpty;

  /// No description provided for @createNewListButton.
  ///
  /// In en, this message translates to:
  /// **'Create new list'**
  String get createNewListButton;

  /// No description provided for @listNameLabel.
  ///
  /// In en, this message translates to:
  /// **'List Name'**
  String get listNameLabel;

  /// No description provided for @listDescLabel.
  ///
  /// In en, this message translates to:
  /// **'Description (Optional)'**
  String get listDescLabel;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @listCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'List created successfully'**
  String get listCreatedSuccess;

  /// No description provided for @listCreateError.
  ///
  /// In en, this message translates to:
  /// **'Error creating list'**
  String get listCreateError;

  /// No description provided for @createButton.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get createButton;

  /// No description provided for @emptyListsTitle.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any lists yet'**
  String get emptyListsTitle;

  /// No description provided for @emptyListsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create a list to organize your books, manga, and fanfics.'**
  String get emptyListsSubtitle;

  /// No description provided for @createListButton.
  ///
  /// In en, this message translates to:
  /// **'Create List'**
  String get createListButton;

  /// No description provided for @listNoDescription.
  ///
  /// In en, this message translates to:
  /// **'No description'**
  String get listNoDescription;

  /// No description provided for @errorLoadingLists.
  ///
  /// In en, this message translates to:
  /// **'Error loading lists'**
  String get errorLoadingLists;

  /// No description provided for @retryButton.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryButton;

  /// No description provided for @myListsTitle.
  ///
  /// In en, this message translates to:
  /// **'My Lists'**
  String get myListsTitle;

  /// No description provided for @noTitle.
  ///
  /// In en, this message translates to:
  /// **'No title'**
  String get noTitle;

  /// No description provided for @unknownAuthor.
  ///
  /// In en, this message translates to:
  /// **'Unknown author'**
  String get unknownAuthor;

  /// No description provided for @errorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorPrefix;

  /// No description provided for @startedReading.
  ///
  /// In en, this message translates to:
  /// **'Started reading'**
  String get startedReading;

  /// No description provided for @addedToWishlist.
  ///
  /// In en, this message translates to:
  /// **'Added to wishlist'**
  String get addedToWishlist;

  /// No description provided for @addedToList.
  ///
  /// In en, this message translates to:
  /// **'added to your list'**
  String get addedToList;

  /// No description provided for @startReading.
  ///
  /// In en, this message translates to:
  /// **'Start reading'**
  String get startReading;

  /// No description provided for @toRead.
  ///
  /// In en, this message translates to:
  /// **'To read'**
  String get toRead;

  /// No description provided for @reading.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get reading;

  /// No description provided for @addToWishlist.
  ///
  /// In en, this message translates to:
  /// **'Add to Wishlist'**
  String get addToWishlist;

  /// No description provided for @viewReadingProgress.
  ///
  /// In en, this message translates to:
  /// **'View reading progress'**
  String get viewReadingProgress;

  /// No description provided for @startReadingSession.
  ///
  /// In en, this message translates to:
  /// **'Start reading session'**
  String get startReadingSession;

  /// No description provided for @pauseOrAbandonReading.
  ///
  /// In en, this message translates to:
  /// **'Pause or abandon reading'**
  String get pauseOrAbandonReading;

  /// No description provided for @viewInJournal.
  ///
  /// In en, this message translates to:
  /// **'View in journal'**
  String get viewInJournal;

  /// No description provided for @statusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get statusLabel;

  /// No description provided for @editJournal.
  ///
  /// In en, this message translates to:
  /// **'Edit journal'**
  String get editJournal;

  /// No description provided for @genres.
  ///
  /// In en, this message translates to:
  /// **'Genres'**
  String get genres;

  /// No description provided for @chapters.
  ///
  /// In en, this message translates to:
  /// **'Chapters'**
  String get chapters;

  /// No description provided for @pages.
  ///
  /// In en, this message translates to:
  /// **'Pages'**
  String get pages;

  /// No description provided for @publishYear.
  ///
  /// In en, this message translates to:
  /// **'Publish year'**
  String get publishYear;

  /// No description provided for @publisher.
  ///
  /// In en, this message translates to:
  /// **'Publisher'**
  String get publisher;

  /// No description provided for @malScore.
  ///
  /// In en, this message translates to:
  /// **'MAL Score'**
  String get malScore;

  /// No description provided for @demographic.
  ///
  /// In en, this message translates to:
  /// **'Demographic'**
  String get demographic;

  /// No description provided for @mainShip.
  ///
  /// In en, this message translates to:
  /// **'Main Ship'**
  String get mainShip;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @synopsis.
  ///
  /// In en, this message translates to:
  /// **'Synopsis'**
  String get synopsis;

  /// No description provided for @physical.
  ///
  /// In en, this message translates to:
  /// **'Physical'**
  String get physical;

  /// No description provided for @digital.
  ///
  /// In en, this message translates to:
  /// **'Digital'**
  String get digital;

  /// No description provided for @borrowed.
  ///
  /// In en, this message translates to:
  /// **'Borrowed'**
  String get borrowed;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'es', 'gl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'gl': return AppLocalizationsGl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
