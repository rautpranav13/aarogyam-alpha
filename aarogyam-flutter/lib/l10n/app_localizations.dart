import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_mr.dart';

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
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
    Locale('mr')
  ];

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profilePrescription.
  ///
  /// In en, this message translates to:
  /// **'Prescription'**
  String get profilePrescription;

  /// No description provided for @profileInsights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get profileInsights;

  /// No description provided for @profileButton.
  ///
  /// In en, this message translates to:
  /// **'Button'**
  String get profileButton;

  /// No description provided for @reportScannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Upload Image Here'**
  String get reportScannerTitle;

  /// No description provided for @reportScannerQuestion.
  ///
  /// In en, this message translates to:
  /// **'What are you looking for?'**
  String get reportScannerQuestion;

  /// No description provided for @reportScannerPrescriptionAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Prescription Analysis'**
  String get reportScannerPrescriptionAnalysis;

  /// No description provided for @reportScannerReportInsights.
  ///
  /// In en, this message translates to:
  /// **'Report Insights'**
  String get reportScannerReportInsights;

  /// No description provided for @reportScannerCustomQuery.
  ///
  /// In en, this message translates to:
  /// **'Set your own query'**
  String get reportScannerCustomQuery;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'आरोग्यम् धनसंपदा'**
  String get homeTitle;

  /// No description provided for @homeReportScanner.
  ///
  /// In en, this message translates to:
  /// **'Report Scanner'**
  String get homeReportScanner;

  /// No description provided for @homeSanjeevani.
  ///
  /// In en, this message translates to:
  /// **'Sanjeevani'**
  String get homeSanjeevani;

  /// No description provided for @homeFirstAid.
  ///
  /// In en, this message translates to:
  /// **'First Aid'**
  String get homeFirstAid;

  /// No description provided for @homeSwipeCards.
  ///
  /// In en, this message translates to:
  /// **'Swipe the cards'**
  String get homeSwipeCards;

  /// No description provided for @responsePageInsights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get responsePageInsights;

  /// No description provided for @responsePageSaveTxt.
  ///
  /// In en, this message translates to:
  /// **'saveTXT'**
  String get responsePageSaveTxt;

  /// No description provided for @responsePageAppendTxt.
  ///
  /// In en, this message translates to:
  /// **'appendTXT'**
  String get responsePageAppendTxt;

  /// No description provided for @responsePageRemainder.
  ///
  /// In en, this message translates to:
  /// **'Remainder'**
  String get responsePageRemainder;

  /// No description provided for @responsePageNotification.
  ///
  /// In en, this message translates to:
  /// **'awsmnotification'**
  String get responsePageNotification;

  /// No description provided for @responsePageExtractMedications.
  ///
  /// In en, this message translates to:
  /// **'extractmedications'**
  String get responsePageExtractMedications;

  /// No description provided for @responsePageSetNotification.
  ///
  /// In en, this message translates to:
  /// **'setawsmnotifi'**
  String get responsePageSetNotification;

  /// No description provided for @responsePageUpdated.
  ///
  /// In en, this message translates to:
  /// **'updatedbb'**
  String get responsePageUpdated;

  /// No description provided for @firstAidTitle.
  ///
  /// In en, this message translates to:
  /// **'First Aid'**
  String get firstAidTitle;

  /// No description provided for @authHomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get authHomeTitle;

  /// No description provided for @authHomeDescription.
  ///
  /// In en, this message translates to:
  /// **'You can delete this and create your home page here.'**
  String get authHomeDescription;

  /// No description provided for @welcomeTagline.
  ///
  /// In en, this message translates to:
  /// **'Health Made Easy \nBecause You Deserve to Know!'**
  String get welcomeTagline;

  /// No description provided for @welcomeAppName.
  ///
  /// In en, this message translates to:
  /// **'aarogyam'**
  String get welcomeAppName;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Welcomes You!'**
  String get welcomeSubtitle;

  /// No description provided for @welcomeLogin.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get welcomeLogin;

  /// No description provided for @welcomeCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an Account'**
  String get welcomeCreateAccount;

  /// No description provided for @createAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Aarogyam!'**
  String get createAccountTitle;

  /// No description provided for @createAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your health, your responsibilty.'**
  String get createAccountSubtitle;

  /// No description provided for @createAccountDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get createAccountDisplayName;

  /// No description provided for @createAccountEmail.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get createAccountEmail;

  /// No description provided for @createAccountPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get createAccountPassword;

  /// No description provided for @createAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccountButton;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Get to my account'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Access your health tools by logging in below.'**
  String get loginSubtitle;

  /// No description provided for @loginEmail.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get loginEmail;

  /// No description provided for @loginPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPassword;

  /// No description provided for @loginForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get loginForgotPassword;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We will send you a reset link.'**
  String get forgotPasswordSubtitle;

  /// No description provided for @forgotPasswordEmail.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get forgotPasswordEmail;

  /// No description provided for @forgotPasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Send Link'**
  String get forgotPasswordButton;

  /// No description provided for @reminderPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get reminderPageTitle;

  /// No description provided for @profileCopyDisplayName.
  ///
  /// In en, this message translates to:
  /// **'[Display name]'**
  String get profileCopyDisplayName;

  /// No description provided for @profileCopyEmail.
  ///
  /// In en, this message translates to:
  /// **'[Email id]'**
  String get profileCopyEmail;

  /// No description provided for @allergiesTitle.
  ///
  /// In en, this message translates to:
  /// **'Allergies'**
  String get allergiesTitle;

  /// No description provided for @allergiesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Let us know what triggers your allergies to help you stay safe.'**
  String get allergiesSubtitle;

  /// No description provided for @allergiesSelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Your Allergies'**
  String get allergiesSelectTitle;

  /// No description provided for @allergiesFoodTitle.
  ///
  /// In en, this message translates to:
  /// **'Food Allergies'**
  String get allergiesFoodTitle;

  /// No description provided for @allergiesPeanuts.
  ///
  /// In en, this message translates to:
  /// **'Peanuts'**
  String get allergiesPeanuts;

  /// No description provided for @allergiesTreeNuts.
  ///
  /// In en, this message translates to:
  /// **'Tree nuts (e.g., almonds, walnuts)'**
  String get allergiesTreeNuts;

  /// No description provided for @allergiesMilk.
  ///
  /// In en, this message translates to:
  /// **'Milk (lactose intolerance or dairy allergy)'**
  String get allergiesMilk;

  /// No description provided for @allergiesEggs.
  ///
  /// In en, this message translates to:
  /// **'Eggs'**
  String get allergiesEggs;

  /// No description provided for @allergiesShellfish.
  ///
  /// In en, this message translates to:
  /// **'Shellfish (e.g., shrimp, crab, lobster)'**
  String get allergiesShellfish;

  /// No description provided for @allergiesFish.
  ///
  /// In en, this message translates to:
  /// **'Fish (e.g., salmon, tuna)'**
  String get allergiesFish;

  /// No description provided for @allergiesSoy.
  ///
  /// In en, this message translates to:
  /// **'Soy'**
  String get allergiesSoy;

  /// No description provided for @allergiesWheat.
  ///
  /// In en, this message translates to:
  /// **'Wheat (gluten intolerance or allergy)'**
  String get allergiesWheat;

  /// No description provided for @allergiesEnvironmentalTitle.
  ///
  /// In en, this message translates to:
  /// **'Environmental Allergies'**
  String get allergiesEnvironmentalTitle;

  /// No description provided for @allergiesPollen.
  ///
  /// In en, this message translates to:
  /// **'Pollen (grass, trees, or flowers)'**
  String get allergiesPollen;

  /// No description provided for @allergiesDustMites.
  ///
  /// In en, this message translates to:
  /// **'Dust mites'**
  String get allergiesDustMites;

  /// No description provided for @allergiesMold.
  ///
  /// In en, this message translates to:
  /// **'Mold spores'**
  String get allergiesMold;

  /// No description provided for @allergiesAnimalDander.
  ///
  /// In en, this message translates to:
  /// **'Animal dander (cats, dogs, etc.)'**
  String get allergiesAnimalDander;

  /// No description provided for @allergiesCockroach.
  ///
  /// In en, this message translates to:
  /// **'Cockroach droppings'**
  String get allergiesCockroach;

  /// No description provided for @allergiesLatex.
  ///
  /// In en, this message translates to:
  /// **'Latex'**
  String get allergiesLatex;

  /// No description provided for @allergiesMedicationTitle.
  ///
  /// In en, this message translates to:
  /// **'Medication Allergies'**
  String get allergiesMedicationTitle;

  /// No description provided for @allergiesPenicillin.
  ///
  /// In en, this message translates to:
  /// **'Penicillin or other antibiotics'**
  String get allergiesPenicillin;

  /// No description provided for @allergiesAspirin.
  ///
  /// In en, this message translates to:
  /// **'Aspirin'**
  String get allergiesAspirin;

  /// No description provided for @allergiesIbuprofen.
  ///
  /// In en, this message translates to:
  /// **'Ibuprofen'**
  String get allergiesIbuprofen;

  /// No description provided for @allergiesSulfa.
  ///
  /// In en, this message translates to:
  /// **'Sulfa drugs'**
  String get allergiesSulfa;

  /// No description provided for @allergiesAnesthesia.
  ///
  /// In en, this message translates to:
  /// **'Anesthesia (e.g., lidocaine)'**
  String get allergiesAnesthesia;

  /// No description provided for @allergiesInsectTitle.
  ///
  /// In en, this message translates to:
  /// **'Insect Allergies'**
  String get allergiesInsectTitle;

  /// No description provided for @allergiesBeeSting.
  ///
  /// In en, this message translates to:
  /// **'Bee stings'**
  String get allergiesBeeSting;

  /// No description provided for @allergiesWaspSting.
  ///
  /// In en, this message translates to:
  /// **'Wasp stings'**
  String get allergiesWaspSting;

  /// No description provided for @allergiesMosquito.
  ///
  /// In en, this message translates to:
  /// **'Mosquito bites'**
  String get allergiesMosquito;

  /// No description provided for @allergiesFireAnt.
  ///
  /// In en, this message translates to:
  /// **'Fire ant bites'**
  String get allergiesFireAnt;

  /// No description provided for @allergiesChemicalTitle.
  ///
  /// In en, this message translates to:
  /// **'Chemical and Skin Allergies'**
  String get allergiesChemicalTitle;

  /// No description provided for @allergiesPerfume.
  ///
  /// In en, this message translates to:
  /// **'Perfumes or fragrances'**
  String get allergiesPerfume;

  /// No description provided for @allergiesSoap.
  ///
  /// In en, this message translates to:
  /// **'Soaps or detergents'**
  String get allergiesSoap;

  /// No description provided for @allergiesNickel.
  ///
  /// In en, this message translates to:
  /// **'Nickel (in jewelry or clothing)'**
  String get allergiesNickel;

  /// No description provided for @allergiesHairDye.
  ///
  /// In en, this message translates to:
  /// **'Hair dyes or cosmetics'**
  String get allergiesHairDye;

  /// No description provided for @allergiesCleaningProducts.
  ///
  /// In en, this message translates to:
  /// **'Cleaning products'**
  String get allergiesCleaningProducts;

  /// No description provided for @allergiesRareTitle.
  ///
  /// In en, this message translates to:
  /// **'Rare or Less Common Allergies'**
  String get allergiesRareTitle;

  /// No description provided for @allergiesSunlight.
  ///
  /// In en, this message translates to:
  /// **'Sunlight (photosensitivity)'**
  String get allergiesSunlight;

  /// No description provided for @allergiesCold.
  ///
  /// In en, this message translates to:
  /// **'Cold temperatures (cold urticaria)'**
  String get allergiesCold;

  /// No description provided for @allergiesWater.
  ///
  /// In en, this message translates to:
  /// **'Water (aquagenic urticaria)'**
  String get allergiesWater;

  /// No description provided for @allergiesSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get allergiesSave;

  /// No description provided for @allergiesOther.
  ///
  /// In en, this message translates to:
  /// **'Other...'**
  String get allergiesOther;

  /// No description provided for @allergiesSpecifyHere.
  ///
  /// In en, this message translates to:
  /// **'Specify  your allergy here...'**
  String get allergiesSpecifyHere;

  /// No description provided for @authUserInfoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Help us personalize your experience.'**
  String get authUserInfoSubtitle;

  /// No description provided for @chatBotTitle.
  ///
  /// In en, this message translates to:
  /// **'संजीवनी'**
  String get chatBotTitle;

  /// No description provided for @chatBotHint.
  ///
  /// In en, this message translates to:
  /// **'Ask Sanjeevani...'**
  String get chatBotHint;

  /// No description provided for @chatBotName.
  ///
  /// In en, this message translates to:
  /// **'Sanjeevani'**
  String get chatBotName;

  /// No description provided for @customQueryTitle.
  ///
  /// In en, this message translates to:
  /// **'Customize Your Response'**
  String get customQueryTitle;

  /// No description provided for @customQuerySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Define the specific information you want to extract or analyze below.'**
  String get customQuerySubtitle;

  /// No description provided for @customQueryTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get customQueryTitleLabel;

  /// No description provided for @customQueryTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Write Title for your query'**
  String get customQueryTitleHint;

  /// No description provided for @customQueryQueryLabel.
  ///
  /// In en, this message translates to:
  /// **'Query'**
  String get customQueryQueryLabel;

  /// No description provided for @customQueryQueryHint.
  ///
  /// In en, this message translates to:
  /// **'Write your query here'**
  String get customQueryQueryHint;

  /// No description provided for @customQueryOrSelect.
  ///
  /// In en, this message translates to:
  /// **'or select from below'**
  String get customQueryOrSelect;

  /// No description provided for @customQueryGenericAlternatives.
  ///
  /// In en, this message translates to:
  /// **'Suggest Generic Alternatives'**
  String get customQueryGenericAlternatives;

  /// No description provided for @customQueryUrgentActions.
  ///
  /// In en, this message translates to:
  /// **'Check Urguent Actions'**
  String get customQueryUrgentActions;

  /// No description provided for @customQueryLifestyle.
  ///
  /// In en, this message translates to:
  /// **'Suggest Lifestyle Activities'**
  String get customQueryLifestyle;

  /// No description provided for @customQueryPainkillers.
  ///
  /// In en, this message translates to:
  /// **'Check for Painkillers'**
  String get customQueryPainkillers;

  /// No description provided for @customQueryDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get customQueryDone;

  /// No description provided for @dbpageTitle.
  ///
  /// In en, this message translates to:
  /// **'Page Title'**
  String get dbpageTitle;

  /// No description provided for @remindersTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get remindersTitle;

  /// No description provided for @userInfoGender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get userInfoGender;

  /// No description provided for @userInfoGenderSearch.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get userInfoGenderSearch;

  /// No description provided for @userInfoMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get userInfoMale;

  /// No description provided for @userInfoFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get userInfoFemale;

  /// No description provided for @userInfoOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get userInfoOther;

  /// No description provided for @userInfoAge.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get userInfoAge;

  /// No description provided for @userInfoHeight.
  ///
  /// In en, this message translates to:
  /// **'Height(cm)'**
  String get userInfoHeight;

  /// No description provided for @userInfoWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight(kg)'**
  String get userInfoWeight;

  /// No description provided for @userInfoAllergies.
  ///
  /// In en, this message translates to:
  /// **'Allergies(If any)'**
  String get userInfoAllergies;

  /// No description provided for @setReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Set Reminder'**
  String get setReminderTitle;

  /// No description provided for @setReminderTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get setReminderTitleLabel;

  /// No description provided for @setReminderTitleHint.
  ///
  /// In en, this message translates to:
  /// **'eg. Medicine or task'**
  String get setReminderTitleHint;

  /// No description provided for @setReminderDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Discription'**
  String get setReminderDescriptionLabel;

  /// No description provided for @setReminderDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'eg. Dosage'**
  String get setReminderDescriptionHint;

  /// No description provided for @setReminderTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get setReminderTime;

  /// No description provided for @aiDisclaimerTitle.
  ///
  /// In en, this message translates to:
  /// **'Medical Disclaimer'**
  String get aiDisclaimerTitle;

  /// No description provided for @aiDisclaimerBody.
  ///
  /// In en, this message translates to:
  /// **'The content generated by AI is for informational purposes only and should not be considered as medical advice. Always consult with qualified healthcare professionals for proper medical diagnosis, treatment, and advice regarding your specific situation.'**
  String get aiDisclaimerBody;

  /// No description provided for @miscVoiceChat.
  ///
  /// In en, this message translates to:
  /// **'For voice chat'**
  String get miscVoiceChat;

  /// No description provided for @miscNotify.
  ///
  /// In en, this message translates to:
  /// **'notify'**
  String get miscNotify;

  /// No description provided for @miscScheduleNotifications.
  ///
  /// In en, this message translates to:
  /// **'Schedule Notifications'**
  String get miscScheduleNotifications;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi', 'mr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'mr':
      return AppLocalizationsMr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
