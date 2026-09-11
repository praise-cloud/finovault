import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('fr'),
  ];

  /// Brand name; usually not translated
  ///
  /// In en, this message translates to:
  /// **'Finovault'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Vault Your Future. Grow Your Wealth.'**
  String get appTagline;

  /// No description provided for @securedEncrypted.
  ///
  /// In en, this message translates to:
  /// **'Secured & encrypted'**
  String get securedEncrypted;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get login;

  /// No description provided for @loginCta.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get loginCta;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Log in to keep growing your wealth.'**
  String get loginSubtitle;

  /// No description provided for @demoAccount.
  ///
  /// In en, this message translates to:
  /// **'Demo account — demo@finovault.app / Vault123!'**
  String get demoAccount;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get emailHint;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @signUpPrompt.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get signUpPrompt;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @continueCta.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueCta;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Log out?'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'You will need to sign in again to access your vault.'**
  String get logoutConfirmBody;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @linkedAccounts.
  ///
  /// In en, this message translates to:
  /// **'Linked accounts'**
  String get linkedAccounts;

  /// No description provided for @settingsAndPlan.
  ///
  /// In en, this message translates to:
  /// **'Settings & plan'**
  String get settingsAndPlan;

  /// No description provided for @soon.
  ///
  /// In en, this message translates to:
  /// **'Soon'**
  String get soon;

  /// No description provided for @biometricUnlock.
  ///
  /// In en, this message translates to:
  /// **'Biometric unlock'**
  String get biometricUnlock;

  /// No description provided for @biometricPrompt.
  ///
  /// In en, this message translates to:
  /// **'Use your fingerprint or face to open Finovault'**
  String get biometricPrompt;

  /// No description provided for @biometricUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Biometrics unavailable — please try again'**
  String get biometricUnavailable;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @billReminders.
  ///
  /// In en, this message translates to:
  /// **'Bill due reminders'**
  String get billReminders;

  /// No description provided for @lowBalanceAlert.
  ///
  /// In en, this message translates to:
  /// **'Low-balance alerts'**
  String get lowBalanceAlert;

  /// No description provided for @whatWorkingTowards.
  ///
  /// In en, this message translates to:
  /// **'What are you working towards?'**
  String get whatWorkingTowards;

  /// No description provided for @goalsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a few goals so your vault can be shaped around them.'**
  String get goalsSubtitle;

  /// No description provided for @riskHeading.
  ///
  /// In en, this message translates to:
  /// **'How do you feel about risk?'**
  String get riskHeading;

  /// No description provided for @riskLow.
  ///
  /// In en, this message translates to:
  /// **'Low — protect what I have'**
  String get riskLow;

  /// No description provided for @riskModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate — steady growth'**
  String get riskModerate;

  /// No description provided for @riskHigh.
  ///
  /// In en, this message translates to:
  /// **'High — grow aggressively'**
  String get riskHigh;

  /// No description provided for @goalEmergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency fund'**
  String get goalEmergency;

  /// No description provided for @goalRetirement.
  ///
  /// In en, this message translates to:
  /// **'Retirement'**
  String get goalRetirement;

  /// No description provided for @goalDebt.
  ///
  /// In en, this message translates to:
  /// **'Pay down debt'**
  String get goalDebt;

  /// No description provided for @goalHome.
  ///
  /// In en, this message translates to:
  /// **'Buy a home'**
  String get goalHome;

  /// No description provided for @goalEducation.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get goalEducation;

  /// No description provided for @goalTaxShield.
  ///
  /// In en, this message translates to:
  /// **'Tax shield'**
  String get goalTaxShield;

  /// No description provided for @goalEquipment.
  ///
  /// In en, this message translates to:
  /// **'New equipment'**
  String get goalEquipment;

  /// No description provided for @goalBusiness.
  ///
  /// In en, this message translates to:
  /// **'Business growth'**
  String get goalBusiness;

  /// No description provided for @goalCashBuffer.
  ///
  /// In en, this message translates to:
  /// **'Cash buffer'**
  String get goalCashBuffer;

  /// No description provided for @linkSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Connect an account to see your full picture in one place. You can skip this and add accounts later.'**
  String get linkSubtitle;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @skipForNow.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get skipForNow;

  /// No description provided for @linked.
  ///
  /// In en, this message translates to:
  /// **'Linked'**
  String get linked;

  /// No description provided for @linkAccount.
  ///
  /// In en, this message translates to:
  /// **'Link'**
  String get linkAccount;

  /// No description provided for @bankAccount.
  ///
  /// In en, this message translates to:
  /// **'Bank account'**
  String get bankAccount;

  /// No description provided for @mobileMoney.
  ///
  /// In en, this message translates to:
  /// **'Mobile money'**
  String get mobileMoney;

  /// Onboarding heading
  ///
  /// In en, this message translates to:
  /// **'How will you use Finovault?'**
  String get howWillYouUse;

  /// No description provided for @pickManageMoney.
  ///
  /// In en, this message translates to:
  /// **'Pick the way you want to manage your money. You can add more later.'**
  String get pickManageMoney;

  /// Female founder opt-in label
  ///
  /// In en, this message translates to:
  /// **'Women-led / Female founder path'**
  String get femaleFounderPath;

  /// No description provided for @roleIndividual.
  ///
  /// In en, this message translates to:
  /// **'Individual'**
  String get roleIndividual;

  /// No description provided for @roleIndividualDesc.
  ///
  /// In en, this message translates to:
  /// **'Personal budgeting, goals and insights.'**
  String get roleIndividualDesc;

  /// No description provided for @roleFreelancer.
  ///
  /// In en, this message translates to:
  /// **'Freelancer'**
  String get roleFreelancer;

  /// No description provided for @roleFreelancerDesc.
  ///
  /// In en, this message translates to:
  /// **'Invoice clients and track what you\'re owed.'**
  String get roleFreelancerDesc;

  /// No description provided for @roleEntrepreneur.
  ///
  /// In en, this message translates to:
  /// **'Entrepreneur'**
  String get roleEntrepreneur;

  /// No description provided for @roleEntrepreneurDesc.
  ///
  /// In en, this message translates to:
  /// **'Run payroll, VAT and business cashflow.'**
  String get roleEntrepreneurDesc;

  /// No description provided for @roleSme.
  ///
  /// In en, this message translates to:
  /// **'SME'**
  String get roleSme;

  /// No description provided for @roleSmeDesc.
  ///
  /// In en, this message translates to:
  /// **'Treasury, payments and team spend.'**
  String get roleSmeDesc;

  /// No description provided for @yourGoals.
  ///
  /// In en, this message translates to:
  /// **'Your Goals'**
  String get yourGoals;

  /// No description provided for @addGoal.
  ///
  /// In en, this message translates to:
  /// **'Add Goal'**
  String get addGoal;

  /// No description provided for @newGoal.
  ///
  /// In en, this message translates to:
  /// **'New Goal'**
  String get newGoal;

  /// No description provided for @linkAccounts.
  ///
  /// In en, this message translates to:
  /// **'Link Accounts'**
  String get linkAccounts;

  /// No description provided for @linkAccountsDesc.
  ///
  /// In en, this message translates to:
  /// **'Connect a bank or wallet to start tracking.'**
  String get linkAccountsDesc;

  /// No description provided for @addAccount.
  ///
  /// In en, this message translates to:
  /// **'Add Account'**
  String get addAccount;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navInsights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get navInsights;

  /// No description provided for @navVault.
  ///
  /// In en, this message translates to:
  /// **'Vault'**
  String get navVault;

  /// No description provided for @navPay.
  ///
  /// In en, this message translates to:
  /// **'Pay'**
  String get navPay;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @accounts.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get accounts;

  /// No description provided for @transactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// No description provided for @budgets.
  ///
  /// In en, this message translates to:
  /// **'Budgets'**
  String get budgets;

  /// No description provided for @goals.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get goals;

  /// No description provided for @invoices.
  ///
  /// In en, this message translates to:
  /// **'Invoices'**
  String get invoices;

  /// No description provided for @vendors.
  ///
  /// In en, this message translates to:
  /// **'Vendors'**
  String get vendors;

  /// No description provided for @transfers.
  ///
  /// In en, this message translates to:
  /// **'Transfers'**
  String get transfers;

  /// No description provided for @bills.
  ///
  /// In en, this message translates to:
  /// **'Bills'**
  String get bills;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @pension.
  ///
  /// In en, this message translates to:
  /// **'Pension'**
  String get pension;

  /// No description provided for @pensionSetup.
  ///
  /// In en, this message translates to:
  /// **'Pension setup'**
  String get pensionSetup;

  /// No description provided for @insights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get insights;

  /// No description provided for @totalBalance.
  ///
  /// In en, this message translates to:
  /// **'Total balance'**
  String get totalBalance;

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// No description provided for @expenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// No description provided for @netWorth.
  ///
  /// In en, this message translates to:
  /// **'Net worth'**
  String get netWorth;

  /// No description provided for @runway.
  ///
  /// In en, this message translates to:
  /// **'Runway'**
  String get runway;

  /// No description provided for @taxEstimate.
  ///
  /// In en, this message translates to:
  /// **'Tax estimate'**
  String get taxEstimate;

  /// No description provided for @topCategory.
  ///
  /// In en, this message translates to:
  /// **'Top category'**
  String get topCategory;

  /// No description provided for @unpaidInvoices.
  ///
  /// In en, this message translates to:
  /// **'Unpaid invoices'**
  String get unpaidInvoices;

  /// No description provided for @overdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdue;

  /// No description provided for @contribute.
  ///
  /// In en, this message translates to:
  /// **'Contribute'**
  String get contribute;

  /// No description provided for @payBill.
  ///
  /// In en, this message translates to:
  /// **'Pay bill'**
  String get payBill;

  /// No description provided for @sendMoney.
  ///
  /// In en, this message translates to:
  /// **'Send money'**
  String get sendMoney;

  /// No description provided for @shortTermPot.
  ///
  /// In en, this message translates to:
  /// **'Short-term pot'**
  String get shortTermPot;

  /// No description provided for @longTermPot.
  ///
  /// In en, this message translates to:
  /// **'Long-term pot'**
  String get longTermPot;

  /// No description provided for @totalNetWorth.
  ///
  /// In en, this message translates to:
  /// **'Total net worth'**
  String get totalNetWorth;

  /// No description provided for @incomeThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Income this month'**
  String get incomeThisMonth;

  /// No description provided for @combinedWealth.
  ///
  /// In en, this message translates to:
  /// **'Combined wealth'**
  String get combinedWealth;

  /// No description provided for @cashPosition.
  ///
  /// In en, this message translates to:
  /// **'Cash position'**
  String get cashPosition;

  /// No description provided for @securityScore.
  ///
  /// In en, this message translates to:
  /// **'Security score'**
  String get securityScore;

  /// No description provided for @spendingVsBudget.
  ///
  /// In en, this message translates to:
  /// **'Spending vs budget'**
  String get spendingVsBudget;

  /// No description provided for @monthlySpending.
  ///
  /// In en, this message translates to:
  /// **'Monthly spending'**
  String get monthlySpending;

  /// No description provided for @vsMonthlyBudget.
  ///
  /// In en, this message translates to:
  /// **'vs your monthly budget'**
  String get vsMonthlyBudget;

  /// No description provided for @savingsSection.
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get savingsSection;

  /// No description provided for @rainyDayFund.
  ///
  /// In en, this message translates to:
  /// **'Rainy-day fund'**
  String get rainyDayFund;

  /// No description provided for @startEmergencyGoal.
  ///
  /// In en, this message translates to:
  /// **'Start an emergency goal'**
  String get startEmergencyGoal;

  /// Goal progress, amount is money
  ///
  /// In en, this message translates to:
  /// **'of {amount} goal'**
  String goalAmountTarget(Object amount);

  /// No description provided for @pensionStart.
  ///
  /// In en, this message translates to:
  /// **'Start a flexible micro-pension'**
  String get pensionStart;

  /// Pension projection, amount is money
  ///
  /// In en, this message translates to:
  /// **'Projected {amount} at retirement'**
  String pensionProjected(Object amount);

  /// No description provided for @allSettled.
  ///
  /// In en, this message translates to:
  /// **'all settled'**
  String get allSettled;

  /// No description provided for @approxTax.
  ///
  /// In en, this message translates to:
  /// **'≈ 15% of income'**
  String get approxTax;

  /// No description provided for @runwayLabel.
  ///
  /// In en, this message translates to:
  /// **'Runway'**
  String get runwayLabel;

  /// No description provided for @monthsOfCover.
  ///
  /// In en, this message translates to:
  /// **'months of cover'**
  String get monthsOfCover;

  /// No description provided for @activeProjects.
  ///
  /// In en, this message translates to:
  /// **'Active projects'**
  String get activeProjects;

  /// No description provided for @acrossYourVault.
  ///
  /// In en, this message translates to:
  /// **'across your vault'**
  String get acrossYourVault;

  /// No description provided for @recentProjects.
  ///
  /// In en, this message translates to:
  /// **'Recent projects'**
  String get recentProjects;

  /// No description provided for @activeGoalsLabel.
  ///
  /// In en, this message translates to:
  /// **'Active goals'**
  String get activeGoalsLabel;

  /// No description provided for @addProjectHint.
  ///
  /// In en, this message translates to:
  /// **'Add a project or goal to track it here'**
  String get addProjectHint;

  /// No description provided for @revenueMrr.
  ///
  /// In en, this message translates to:
  /// **'Revenue / MRR'**
  String get revenueMrr;

  /// No description provided for @burnRate.
  ///
  /// In en, this message translates to:
  /// **'Burn rate'**
  String get burnRate;

  /// No description provided for @perMonth.
  ///
  /// In en, this message translates to:
  /// **'per month'**
  String get perMonth;

  /// No description provided for @savedInGoalsLabel.
  ///
  /// In en, this message translates to:
  /// **'Saved in goals'**
  String get savedInGoalsLabel;

  /// No description provided for @opportunitiesLabel.
  ///
  /// In en, this message translates to:
  /// **'Opportunities'**
  String get opportunitiesLabel;

  /// No description provided for @femaleSeedFund.
  ///
  /// In en, this message translates to:
  /// **'Female Innovators Seed Fund'**
  String get femaleSeedFund;

  /// No description provided for @femaleSeedBlurb.
  ///
  /// In en, this message translates to:
  /// **'Curated for women-led ventures'**
  String get femaleSeedBlurb;

  /// No description provided for @needsAttention.
  ///
  /// In en, this message translates to:
  /// **'Needs attention'**
  String get needsAttention;

  /// No description provided for @allClear.
  ///
  /// In en, this message translates to:
  /// **'All clear — nothing needs your attention.'**
  String get allClear;

  /// No description provided for @seeEverything.
  ///
  /// In en, this message translates to:
  /// **'See everything in one place'**
  String get seeEverything;

  /// No description provided for @qaSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get qaSend;

  /// No description provided for @qaSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get qaSave;

  /// No description provided for @qaAddInvoice.
  ///
  /// In en, this message translates to:
  /// **'Add invoice'**
  String get qaAddInvoice;

  /// No description provided for @qaSetAsideTax.
  ///
  /// In en, this message translates to:
  /// **'Set aside tax'**
  String get qaSetAsideTax;

  /// No description provided for @qaTransfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get qaTransfer;

  /// No description provided for @qaCoach.
  ///
  /// In en, this message translates to:
  /// **'Coach'**
  String get qaCoach;

  /// No description provided for @qaCashFlow.
  ///
  /// In en, this message translates to:
  /// **'Cash flow'**
  String get qaCashFlow;

  /// No description provided for @qaGrants.
  ///
  /// In en, this message translates to:
  /// **'Grants'**
  String get qaGrants;

  /// No description provided for @qaPayVendor.
  ///
  /// In en, this message translates to:
  /// **'Pay vendor'**
  String get qaPayVendor;

  /// No description provided for @qaRecordInvoice.
  ///
  /// In en, this message translates to:
  /// **'Record invoice'**
  String get qaRecordInvoice;

  /// No description provided for @qaAdvisor.
  ///
  /// In en, this message translates to:
  /// **'Advisor'**
  String get qaAdvisor;

  /// No description provided for @revenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get revenue;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @totalSaved.
  ///
  /// In en, this message translates to:
  /// **'Total saved'**
  String get totalSaved;

  /// No description provided for @createGoal.
  ///
  /// In en, this message translates to:
  /// **'Create Goal'**
  String get createGoal;

  /// No description provided for @startPension.
  ///
  /// In en, this message translates to:
  /// **'Start Pension'**
  String get startPension;

  /// No description provided for @couldNotLoadGoals.
  ///
  /// In en, this message translates to:
  /// **'Could not load goals'**
  String get couldNotLoadGoals;

  /// No description provided for @pleaseRetry.
  ///
  /// In en, this message translates to:
  /// **'Please try again in a moment.'**
  String get pleaseRetry;

  /// No description provided for @noGoalsYet.
  ///
  /// In en, this message translates to:
  /// **'No goals yet'**
  String get noGoalsYet;

  /// No description provided for @goalsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Create a goal to start building your rainy-day fund or retirement pot.'**
  String get goalsEmptyBody;

  /// No description provided for @createAGoal.
  ///
  /// In en, this message translates to:
  /// **'Create a goal'**
  String get createAGoal;

  /// No description provided for @allGoals.
  ///
  /// In en, this message translates to:
  /// **'All goals'**
  String get allGoals;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @transferLabel.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get transferLabel;

  /// No description provided for @sendToPayee.
  ///
  /// In en, this message translates to:
  /// **'Send to a payee or account'**
  String get sendToPayee;

  /// No description provided for @payABill.
  ///
  /// In en, this message translates to:
  /// **'Pay a bill'**
  String get payABill;

  /// No description provided for @billBlurb.
  ///
  /// In en, this message translates to:
  /// **'Electricity, water, airtime and more'**
  String get billBlurb;

  /// No description provided for @recentPayments.
  ///
  /// In en, this message translates to:
  /// **'Recent payments'**
  String get recentPayments;

  /// No description provided for @noPaymentsYet.
  ///
  /// In en, this message translates to:
  /// **'No payments yet'**
  String get noPaymentsYet;

  /// No description provided for @paymentsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Transfers and bill payments will show up here.'**
  String get paymentsEmptyBody;

  /// No description provided for @moneyCoach.
  ///
  /// In en, this message translates to:
  /// **'Your money coach'**
  String get moneyCoach;

  /// No description provided for @coachBlurb.
  ///
  /// In en, this message translates to:
  /// **'Guidance tailored to your vault'**
  String get coachBlurb;

  /// No description provided for @exportCsv.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get exportCsv;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get thisMonth;

  /// No description provided for @incomeLabel.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get incomeLabel;

  /// No description provided for @expensesLabel.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expensesLabel;

  /// No description provided for @netLabel.
  ///
  /// In en, this message translates to:
  /// **'Net'**
  String get netLabel;

  /// No description provided for @spendingByCategory.
  ///
  /// In en, this message translates to:
  /// **'Spending by category'**
  String get spendingByCategory;

  /// No description provided for @notEnoughData.
  ///
  /// In en, this message translates to:
  /// **'Not enough data yet.'**
  String get notEnoughData;

  /// No description provided for @dailyBriefing.
  ///
  /// In en, this message translates to:
  /// **'Daily briefing'**
  String get dailyBriefing;

  /// No description provided for @topCategoryThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Top category this month'**
  String get topCategoryThisMonth;

  /// No description provided for @noSpendingYet.
  ///
  /// In en, this message translates to:
  /// **'No spending yet'**
  String get noSpendingYet;

  /// amount is money
  ///
  /// In en, this message translates to:
  /// **'You spent {amount} so far this month.'**
  String spentSoFar(Object amount);

  /// No description provided for @csvCopied.
  ///
  /// In en, this message translates to:
  /// **'CSV copied to clipboard'**
  String get csvCopied;

  /// No description provided for @csvDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get csvDate;

  /// No description provided for @csvType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get csvType;

  /// No description provided for @csvAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get csvAmount;

  /// No description provided for @csvCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get csvCategory;

  /// No description provided for @csvMerchant.
  ///
  /// In en, this message translates to:
  /// **'Merchant'**
  String get csvMerchant;

  /// No description provided for @smeNoVendors.
  ///
  /// In en, this message translates to:
  /// **'No vendors linked yet'**
  String get smeNoVendors;

  /// No description provided for @smeRunwayLow.
  ///
  /// In en, this message translates to:
  /// **'Runway is low — {months} months left'**
  String smeRunwayLow(Object months);

  /// No description provided for @smeOverdue.
  ///
  /// In en, this message translates to:
  /// **'{count} overdue invoice needs attention'**
  String smeOverdue(Object count);

  /// No description provided for @backendUrl.
  ///
  /// In en, this message translates to:
  /// **'Backend URL'**
  String get backendUrl;

  /// No description provided for @backendUrlHint.
  ///
  /// In en, this message translates to:
  /// **'https://your-bff.example.com'**
  String get backendUrlHint;

  /// No description provided for @testConnection.
  ///
  /// In en, this message translates to:
  /// **'Test connection'**
  String get testConnection;

  /// No description provided for @connectionOk.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connectionOk;

  /// No description provided for @connectionFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not connect'**
  String get connectionFailed;

  /// No description provided for @connectBankTitle.
  ///
  /// In en, this message translates to:
  /// **'Connect a bank'**
  String get connectBankTitle;

  /// No description provided for @connectBankBody.
  ///
  /// In en, this message translates to:
  /// **'Pick a provider to securely import your history.'**
  String get connectBankBody;

  /// No description provided for @totalCash.
  ///
  /// In en, this message translates to:
  /// **'Total cash'**
  String get totalCash;

  /// No description provided for @balanceTrend.
  ///
  /// In en, this message translates to:
  /// **'Balance trend'**
  String get balanceTrend;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchHint;

  /// No description provided for @notEnoughHistory.
  ///
  /// In en, this message translates to:
  /// **'Not enough history yet.'**
  String get notEnoughHistory;

  /// No description provided for @noTransactionsTitle.
  ///
  /// In en, this message translates to:
  /// **'No transactions'**
  String get noTransactionsTitle;

  /// No description provided for @noTransactionsBody.
  ///
  /// In en, this message translates to:
  /// **'They will appear here once imported.'**
  String get noTransactionsBody;

  /// No description provided for @accountNotFound.
  ///
  /// In en, this message translates to:
  /// **'Account not found'**
  String get accountNotFound;

  /// count is a number, name is the institution
  ///
  /// In en, this message translates to:
  /// **'Imported {count} transactions from {name}'**
  String importedTransactions(Object count, Object name);

  /// No description provided for @coachTitle.
  ///
  /// In en, this message translates to:
  /// **'Money Coach'**
  String get coachTitle;

  /// No description provided for @snapshot.
  ///
  /// In en, this message translates to:
  /// **'Snapshot'**
  String get snapshot;

  /// No description provided for @askCoachHint.
  ///
  /// In en, this message translates to:
  /// **'Ask your coach...'**
  String get askCoachHint;

  /// No description provided for @clientIncome.
  ///
  /// In en, this message translates to:
  /// **'Client income'**
  String get clientIncome;

  /// No description provided for @businessCosts.
  ///
  /// In en, this message translates to:
  /// **'Business costs'**
  String get businessCosts;

  /// No description provided for @sales.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get sales;

  /// No description provided for @cogs.
  ///
  /// In en, this message translates to:
  /// **'COGS'**
  String get cogs;

  /// No description provided for @overheads.
  ///
  /// In en, this message translates to:
  /// **'Overheads'**
  String get overheads;

  /// No description provided for @clientPipeline.
  ///
  /// In en, this message translates to:
  /// **'Client pipeline'**
  String get clientPipeline;

  /// No description provided for @cashBufferLabel.
  ///
  /// In en, this message translates to:
  /// **'Cash buffer'**
  String get cashBufferLabel;

  /// No description provided for @andWord.
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get andWord;

  /// No description provided for @yourTopGoal.
  ///
  /// In en, this message translates to:
  /// **'your goal'**
  String get yourTopGoal;

  /// No description provided for @cashFlowHealthy.
  ///
  /// In en, this message translates to:
  /// **'a healthy'**
  String get cashFlowHealthy;

  /// No description provided for @cashFlowTight.
  ///
  /// In en, this message translates to:
  /// **'a tight'**
  String get cashFlowTight;

  /// No description provided for @demoRoleHint.
  ///
  /// In en, this message translates to:
  /// **'Or jump in with a demo role'**
  String get demoRoleHint;

  /// name is first name, balance/flow are money phrases
  ///
  /// In en, this message translates to:
  /// **'Hey {name}, I\'m your Money Coach. You have {balance} on hand and {flow} cash flow this month. Ask me anything about your money.'**
  String coachGreeting(Object balance, Object flow, Object name);

  /// No description provided for @coachSave.
  ///
  /// In en, this message translates to:
  /// **'Based on your last month you brought in {income} and spent {expense}. That leaves a surplus of {surplus}. Your biggest categories were {cats}. Park the surplus into {goal} automatically each payday to stay consistent.'**
  String coachSave(
    Object cats,
    Object expense,
    Object goal,
    Object income,
    Object surplus,
  );

  /// No description provided for @coachInvest.
  ///
  /// In en, this message translates to:
  /// **'You have {balance} across accounts. For a {role}, keep 3 months of expenses as cash, then split the rest between a pension pot and a diversified fund. Start small and increase contributions by 1% each quarter.'**
  String coachInvest(Object balance, Object role);

  /// No description provided for @coachTax.
  ///
  /// In en, this message translates to:
  /// **'Set aside ~20% of each incoming payment for tax so deadlines never surprise you. Tag client payments clearly and reconcile invoices weekly — your future self will thank you.'**
  String get coachTax;

  /// No description provided for @coachDefault.
  ///
  /// In en, this message translates to:
  /// **'Hey {name}, here\'s your snapshot: {balance} on hand, {flow} cash flow this month. As a {role}, I\'d focus on {goal} next. Ask me to review spending, plan savings, or grow your money.'**
  String coachDefault(
    Object balance,
    Object flow,
    Object goal,
    Object name,
    Object role,
  );

  /// No description provided for @coachPromptSpending.
  ///
  /// In en, this message translates to:
  /// **'Review my spending'**
  String get coachPromptSpending;

  /// No description provided for @coachPromptSave.
  ///
  /// In en, this message translates to:
  /// **'Help me save'**
  String get coachPromptSave;

  /// No description provided for @coachPromptGrow.
  ///
  /// In en, this message translates to:
  /// **'How do I grow?'**
  String get coachPromptGrow;

  /// No description provided for @businessDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us about your business'**
  String get businessDetailsTitle;

  /// No description provided for @businessDetailsSubtitleEntrepreneur.
  ///
  /// In en, this message translates to:
  /// **'A few details help us tailor insights for your venture.'**
  String get businessDetailsSubtitleEntrepreneur;

  /// No description provided for @businessDetailsSubtitleSme.
  ///
  /// In en, this message translates to:
  /// **'We need a bit more to set up treasury, payroll and vendor tracking.'**
  String get businessDetailsSubtitleSme;

  /// No description provided for @employeeCountLabel.
  ///
  /// In en, this message translates to:
  /// **'How many employees?'**
  String get employeeCountLabel;

  /// No description provided for @employeeCountHint.
  ///
  /// In en, this message translates to:
  /// **'Select employee count'**
  String get employeeCountHint;

  /// No description provided for @employeeCountZero.
  ///
  /// In en, this message translates to:
  /// **'Just me (founder only)'**
  String get employeeCountZero;

  /// No description provided for @employeeCountRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select employee count'**
  String get employeeCountRequired;

  /// No description provided for @annualRevenueLabel.
  ///
  /// In en, this message translates to:
  /// **'Annual revenue range'**
  String get annualRevenueLabel;

  /// No description provided for @annualRevenueHint.
  ///
  /// In en, this message translates to:
  /// **'Select revenue range'**
  String get annualRevenueHint;

  /// No description provided for @annualRevenueRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select revenue range'**
  String get annualRevenueRequired;

  /// No description provided for @revenuePreRevenue.
  ///
  /// In en, this message translates to:
  /// **'Pre-revenue'**
  String get revenuePreRevenue;

  /// No description provided for @revenueUnder1m.
  ///
  /// In en, this message translates to:
  /// **'Under 1M MUR'**
  String get revenueUnder1m;

  /// No description provided for @revenue1m5m.
  ///
  /// In en, this message translates to:
  /// **'1M – 5M MUR'**
  String get revenue1m5m;

  /// No description provided for @revenue5m20m.
  ///
  /// In en, this message translates to:
  /// **'5M – 20M MUR'**
  String get revenue5m20m;

  /// No description provided for @revenue20m100m.
  ///
  /// In en, this message translates to:
  /// **'20M – 100M MUR'**
  String get revenue20m100m;

  /// No description provided for @revenue100mPlus.
  ///
  /// In en, this message translates to:
  /// **'100M+ MUR'**
  String get revenue100mPlus;

  /// No description provided for @industryLabel.
  ///
  /// In en, this message translates to:
  /// **'Industry'**
  String get industryLabel;

  /// No description provided for @industryHint.
  ///
  /// In en, this message translates to:
  /// **'Select your industry'**
  String get industryHint;

  /// No description provided for @industryRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select industry'**
  String get industryRequired;

  /// No description provided for @industryTechnology.
  ///
  /// In en, this message translates to:
  /// **'Technology / Software'**
  String get industryTechnology;

  /// No description provided for @industryRetail.
  ///
  /// In en, this message translates to:
  /// **'Retail / E-commerce'**
  String get industryRetail;

  /// No description provided for @industryManufacturing.
  ///
  /// In en, this message translates to:
  /// **'Manufacturing'**
  String get industryManufacturing;

  /// No description provided for @industryServices.
  ///
  /// In en, this message translates to:
  /// **'Professional Services'**
  String get industryServices;

  /// No description provided for @industryAgriculture.
  ///
  /// In en, this message translates to:
  /// **'Agriculture / Agri-tech'**
  String get industryAgriculture;

  /// No description provided for @industryHospitality.
  ///
  /// In en, this message translates to:
  /// **'Hospitality / Tourism'**
  String get industryHospitality;

  /// No description provided for @industryConstruction.
  ///
  /// In en, this message translates to:
  /// **'Construction / Real Estate'**
  String get industryConstruction;

  /// No description provided for @industryHealthcare.
  ///
  /// In en, this message translates to:
  /// **'Healthcare / Med-tech'**
  String get industryHealthcare;

  /// No description provided for @industryEducation.
  ///
  /// In en, this message translates to:
  /// **'Education / Ed-tech'**
  String get industryEducation;

  /// No description provided for @industryFinance.
  ///
  /// In en, this message translates to:
  /// **'Financial Services / Fintech'**
  String get industryFinance;

  /// No description provided for @industryTransportLogistics.
  ///
  /// In en, this message translates to:
  /// **'Transport / Logistics'**
  String get industryTransportLogistics;

  /// No description provided for @industryCreativeMedia.
  ///
  /// In en, this message translates to:
  /// **'Creative / Media'**
  String get industryCreativeMedia;

  /// No description provided for @industryRealEstate.
  ///
  /// In en, this message translates to:
  /// **'Real Estate'**
  String get industryRealEstate;

  /// No description provided for @industryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get industryOther;

  /// No description provided for @businessStageLabel.
  ///
  /// In en, this message translates to:
  /// **'Business stage'**
  String get businessStageLabel;

  /// No description provided for @businessStageHint.
  ///
  /// In en, this message translates to:
  /// **'Select stage'**
  String get businessStageHint;

  /// No description provided for @businessStageRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select business stage'**
  String get businessStageRequired;

  /// No description provided for @monthlyPayrollLabel.
  ///
  /// In en, this message translates to:
  /// **'Monthly payroll (MUR)'**
  String get monthlyPayrollLabel;

  /// No description provided for @monthlyPayrollHint.
  ///
  /// In en, this message translates to:
  /// **'Estimated monthly payroll cost'**
  String get monthlyPayrollHint;

  /// No description provided for @smeDetailsSection.
  ///
  /// In en, this message translates to:
  /// **'SME Details (required)'**
  String get smeDetailsSection;

  /// No description provided for @smeRequiredFieldsNote.
  ///
  /// In en, this message translates to:
  /// **'Tax ID, Registration Number and Payroll are required for SMEs'**
  String get smeRequiredFieldsNote;

  /// No description provided for @taxIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Tax ID (MRA TIN)'**
  String get taxIdLabel;

  /// No description provided for @taxIdHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 12345678'**
  String get taxIdHint;

  /// No description provided for @registrationNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Registration Number'**
  String get registrationNumberLabel;

  /// No description provided for @registrationNumberHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. C12345'**
  String get registrationNumberHint;

  /// No description provided for @avgInvoiceValueLabel.
  ///
  /// In en, this message translates to:
  /// **'Average invoice value (MUR)'**
  String get avgInvoiceValueLabel;

  /// No description provided for @avgInvoiceValueHint.
  ///
  /// In en, this message translates to:
  /// **'Typical invoice amount'**
  String get avgInvoiceValueHint;

  /// No description provided for @paymentTermsLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment terms (days)'**
  String get paymentTermsLabel;

  /// No description provided for @paymentTermsHint.
  ///
  /// In en, this message translates to:
  /// **'Standard payment terms'**
  String get paymentTermsHint;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @keySuppliersLabel.
  ///
  /// In en, this message translates to:
  /// **'Key suppliers (comma-separated)'**
  String get keySuppliersLabel;

  /// No description provided for @keySuppliersHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Print Hub, CloudCo'**
  String get keySuppliersHint;

  /// No description provided for @keyClientsLabel.
  ///
  /// In en, this message translates to:
  /// **'Key clients (comma-separated)'**
  String get keyClientsLabel;

  /// No description provided for @keyClientsHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Acme Corp, Nova Studio'**
  String get keyClientsHint;

  /// No description provided for @businessDetailsSmeRequired.
  ///
  /// In en, this message translates to:
  /// **'SME requires Tax ID, Registration Number and Payroll to continue'**
  String get businessDetailsSmeRequired;

  /// No description provided for @coachSmeCashFlow.
  ///
  /// In en, this message translates to:
  /// **'Your cash position is {balance}. At your current burn of {payroll} per month, you have {runway} months of runway. Consider tightening payables or negotiating better terms with vendors.'**
  String coachSmeCashFlow(Object balance, Object payroll, Object runway);

  /// No description provided for @coachSmeVendors.
  ///
  /// In en, this message translates to:
  /// **'Your top vendor is {vendor} ({spend}). Total monthly outflows are {expense}. Review payment terms — extending from 30 to 45 days could free up significant cash.'**
  String coachSmeVendors(Object expense, Object spend, Object vendor);

  /// No description provided for @coachSmeCompliance.
  ///
  /// In en, this message translates to:
  /// **'Upcoming deadlines: {upcoming}. Set calendar reminders now to avoid penalties. The MRA portal accepts filings up to the due date.'**
  String coachSmeCompliance(Object upcoming);

  /// No description provided for @coachSmePayroll.
  ///
  /// In en, this message translates to:
  /// **'Payroll is {payroll} per month for {count} people ({pct} of expenses). Benchmark: aim for payroll < 30% of revenue. Consider contractor vs employee mix for flexibility.'**
  String coachSmePayroll(Object count, Object payroll, Object pct);

  /// No description provided for @coachEntrepreneurFundraising.
  ///
  /// In en, this message translates to:
  /// **'You have {balance} cash and burn {burn} per month — {runway} months runway. To raise, you will need 18-24 months runway post-close. Start investor conversations 6 months before you need the money.'**
  String coachEntrepreneurFundraising(
    Object balance,
    Object burn,
    Object runway,
  );

  /// No description provided for @coachEntrepreneurBurn.
  ///
  /// In en, this message translates to:
  /// **'Monthly burn is {burn} (burn multiple: {multiple}x revenue). Target burn multiple < 2x for efficient growth. Every hire should have a clear ROI path.'**
  String coachEntrepreneurBurn(Object burn, Object multiple);

  /// No description provided for @coachEntrepreneurHiring.
  ///
  /// In en, this message translates to:
  /// **'Team is {count} people with {payroll} monthly payroll vs {revenue} revenue. Revenue per employee: {revPerEmp}. Before hiring, define the 90-day outcome for each role.'**
  String coachEntrepreneurHiring(
    Object count,
    Object payroll,
    Object revPerEmp,
    Object revenue,
  );

  /// No description provided for @coachEntrepreneurRevenue.
  ///
  /// In en, this message translates to:
  /// **'MRR is {mrr}, burn is {burn}. Annual revenue range: {range}. Focus on net revenue retention > 100% and CAC payback < 12 months.'**
  String coachEntrepreneurRevenue(Object burn, Object mrr, Object range);

  /// No description provided for @coachFemaleFounderGrants.
  ///
  /// In en, this message translates to:
  /// **'Check the Female Innovators Seed Fund (applications quarterly), SheWins Africa, and local MRA women entrepreneur incentives. Deadlines are in your Insights tab.'**
  String get coachFemaleFounderGrants;

  /// No description provided for @coachFreelancerInvoices.
  ///
  /// In en, this message translates to:
  /// **'Monthly income {income} with DSO of {dso} days. Target DSO < 30. Send reminders at day 7, 14, 21. Consider 2/10 net 30 terms to accelerate collection.'**
  String coachFreelancerInvoices(Object dso, Object income);

  /// No description provided for @coachFreelancerTax.
  ///
  /// In en, this message translates to:
  /// **'Set aside {taxReserve} (20% of {income}) for tax each month. Use a separate \'Tax Shield\' goal with auto-contribute on every invoice payment.'**
  String coachFreelancerTax(Object income, Object taxReserve);

  /// No description provided for @noVendorsYet.
  ///
  /// In en, this message translates to:
  /// **'no vendors yet'**
  String get noVendorsYet;

  /// No description provided for @noUpcomingCompliance.
  ///
  /// In en, this message translates to:
  /// **'no upcoming compliance deadlines'**
  String get noUpcomingCompliance;

  /// No description provided for @revPerEmp.
  ///
  /// In en, this message translates to:
  /// **'Revenue per employee'**
  String get revPerEmp;

  /// No description provided for @businessMetrics.
  ///
  /// In en, this message translates to:
  /// **'Business Metrics'**
  String get businessMetrics;

  /// No description provided for @arr.
  ///
  /// In en, this message translates to:
  /// **'ARR'**
  String get arr;

  /// No description provided for @growth.
  ///
  /// In en, this message translates to:
  /// **'Growth'**
  String get growth;

  /// No description provided for @burnMultiple.
  ///
  /// In en, this message translates to:
  /// **'Burn Multiple'**
  String get burnMultiple;

  /// No description provided for @efficient.
  ///
  /// In en, this message translates to:
  /// **'Efficient'**
  String get efficient;

  /// No description provided for @high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get high;

  /// No description provided for @healthy.
  ///
  /// In en, this message translates to:
  /// **'Healthy'**
  String get healthy;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @critical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get critical;

  /// No description provided for @fundraisingTracker.
  ///
  /// In en, this message translates to:
  /// **'Fundraising Tracker'**
  String get fundraisingTracker;

  /// No description provided for @preSeed.
  ///
  /// In en, this message translates to:
  /// **'Pre-Seed'**
  String get preSeed;

  /// No description provided for @cashOnHand.
  ///
  /// In en, this message translates to:
  /// **'Cash on Hand'**
  String get cashOnHand;

  /// No description provided for @monthlyBurn.
  ///
  /// In en, this message translates to:
  /// **'Monthly Burn'**
  String get monthlyBurn;

  /// No description provided for @runwayMonths.
  ///
  /// In en, this message translates to:
  /// **'Runway'**
  String get runwayMonths;

  /// No description provided for @months.
  ///
  /// In en, this message translates to:
  /// **'months'**
  String get months;

  /// No description provided for @fundraisingTip.
  ///
  /// In en, this message translates to:
  /// **'Start investor conversations 6 months before you need the money. Target 18-24 months runway post-close.'**
  String get fundraisingTip;

  /// No description provided for @grantDeadlines.
  ///
  /// In en, this message translates to:
  /// **'Grant Deadlines'**
  String get grantDeadlines;

  /// No description provided for @cashFlowForecast.
  ///
  /// In en, this message translates to:
  /// **'Cash Flow Forecast'**
  String get cashFlowForecast;

  /// No description provided for @currentCash.
  ///
  /// In en, this message translates to:
  /// **'Current Cash'**
  String get currentCash;

  /// No description provided for @payrollCost.
  ///
  /// In en, this message translates to:
  /// **'Payroll Cost'**
  String get payrollCost;

  /// No description provided for @netFlow.
  ///
  /// In en, this message translates to:
  /// **'Net Flow'**
  String get netFlow;

  /// No description provided for @annualRevenueRange.
  ///
  /// In en, this message translates to:
  /// **'Annual Revenue'**
  String get annualRevenueRange;

  /// No description provided for @vendorConcentration.
  ///
  /// In en, this message translates to:
  /// **'Vendor Concentration'**
  String get vendorConcentration;

  /// No description provided for @topVendors.
  ///
  /// In en, this message translates to:
  /// **'Top {count} Vendors'**
  String topVendors(Object count);

  /// No description provided for @ofTotalSpend.
  ///
  /// In en, this message translates to:
  /// **'of Total Spend'**
  String get ofTotalSpend;

  /// No description provided for @totalVendorSpend.
  ///
  /// In en, this message translates to:
  /// **'Total Vendor Spend'**
  String get totalVendorSpend;

  /// No description provided for @acrossVendors.
  ///
  /// In en, this message translates to:
  /// **'across {count} vendors'**
  String acrossVendors(Object count);

  /// No description provided for @vendorConcentrationHigh.
  ///
  /// In en, this message translates to:
  /// **'High concentration — consider diversifying suppliers'**
  String get vendorConcentrationHigh;

  /// No description provided for @vendorConcentrationHealthy.
  ///
  /// In en, this message translates to:
  /// **'Healthy vendor diversification'**
  String get vendorConcentrationHealthy;

  /// No description provided for @topVendorsList.
  ///
  /// In en, this message translates to:
  /// **'Top Vendors'**
  String get topVendorsList;

  /// No description provided for @complianceCalendar.
  ///
  /// In en, this message translates to:
  /// **'Compliance Calendar'**
  String get complianceCalendar;

  /// No description provided for @vatFiling.
  ///
  /// In en, this message translates to:
  /// **'VAT Filing'**
  String get vatFiling;

  /// No description provided for @annualReturns.
  ///
  /// In en, this message translates to:
  /// **'Annual Returns'**
  String get annualReturns;

  /// No description provided for @payrollFiling.
  ///
  /// In en, this message translates to:
  /// **'Payroll Filing'**
  String get payrollFiling;

  /// No description provided for @taxClearance.
  ///
  /// In en, this message translates to:
  /// **'Tax Clearance'**
  String get taxClearance;

  /// No description provided for @payrollEfficiency.
  ///
  /// In en, this message translates to:
  /// **'Payroll Efficiency'**
  String get payrollEfficiency;

  /// No description provided for @payrollPctOfRevenue.
  ///
  /// In en, this message translates to:
  /// **'Payroll % of Revenue'**
  String get payrollPctOfRevenue;

  /// No description provided for @revenuePerEmployee.
  ///
  /// In en, this message translates to:
  /// **'Revenue / Employee'**
  String get revenuePerEmployee;

  /// No description provided for @benchmark.
  ///
  /// In en, this message translates to:
  /// **'Benchmark'**
  String get benchmark;

  /// No description provided for @watch.
  ///
  /// In en, this message translates to:
  /// **'Watch'**
  String get watch;

  /// No description provided for @low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get low;

  /// No description provided for @strong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get strong;

  /// No description provided for @businessProfile.
  ///
  /// In en, this message translates to:
  /// **'Business Profile'**
  String get businessProfile;

  /// No description provided for @editBusinessProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Business Profile'**
  String get editBusinessProfile;

  /// No description provided for @employeeCount.
  ///
  /// In en, this message translates to:
  /// **'Employee Count'**
  String get employeeCount;

  /// No description provided for @annualRevenue.
  ///
  /// In en, this message translates to:
  /// **'Annual Revenue'**
  String get annualRevenue;

  /// No description provided for @industry.
  ///
  /// In en, this message translates to:
  /// **'Industry'**
  String get industry;

  /// No description provided for @businessStage.
  ///
  /// In en, this message translates to:
  /// **'Business Stage'**
  String get businessStage;

  /// No description provided for @monthlyPayroll.
  ///
  /// In en, this message translates to:
  /// **'Monthly Payroll'**
  String get monthlyPayroll;

  /// No description provided for @taxId.
  ///
  /// In en, this message translates to:
  /// **'Tax ID'**
  String get taxId;

  /// No description provided for @registrationNumber.
  ///
  /// In en, this message translates to:
  /// **'Registration Number'**
  String get registrationNumber;

  /// No description provided for @avgInvoiceValue.
  ///
  /// In en, this message translates to:
  /// **'Avg Invoice Value'**
  String get avgInvoiceValue;

  /// No description provided for @paymentTerms.
  ///
  /// In en, this message translates to:
  /// **'Payment Terms'**
  String get paymentTerms;

  /// No description provided for @keySuppliers.
  ///
  /// In en, this message translates to:
  /// **'Key Suppliers'**
  String get keySuppliers;

  /// No description provided for @keyClients.
  ///
  /// In en, this message translates to:
  /// **'Key Clients'**
  String get keyClients;

  /// No description provided for @dso.
  ///
  /// In en, this message translates to:
  /// **'Days Sales Outstanding'**
  String get dso;

  /// No description provided for @cashConversionCycle.
  ///
  /// In en, this message translates to:
  /// **'Cash Conversion Cycle'**
  String get cashConversionCycle;

  /// No description provided for @mrrArr.
  ///
  /// In en, this message translates to:
  /// **'MRR / ARR'**
  String get mrrArr;

  /// No description provided for @fundraisingStatus.
  ///
  /// In en, this message translates to:
  /// **'Fundraising Status'**
  String get fundraisingStatus;

  /// No description provided for @complianceStatus.
  ///
  /// In en, this message translates to:
  /// **'Compliance Status'**
  String get complianceStatus;

  /// No description provided for @vendorHealth.
  ///
  /// In en, this message translates to:
  /// **'Vendor Health'**
  String get vendorHealth;

  /// No description provided for @taxEfficiency.
  ///
  /// In en, this message translates to:
  /// **'Tax Efficiency'**
  String get taxEfficiency;

  /// No description provided for @clientConcentration.
  ///
  /// In en, this message translates to:
  /// **'Client Concentration'**
  String get clientConcentration;

  /// No description provided for @grantOpportunities.
  ///
  /// In en, this message translates to:
  /// **'Grant Opportunities'**
  String get grantOpportunities;

  /// No description provided for @profileSaved.
  ///
  /// In en, this message translates to:
  /// **'Business profile saved'**
  String get profileSaved;

  /// No description provided for @businessProfileEmpty.
  ///
  /// In en, this message translates to:
  /// **'No business profile yet — tap to add one'**
  String get businessProfileEmpty;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get changePhoto;

  /// No description provided for @removePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get removePhoto;

  /// No description provided for @uploadPhoto.
  ///
  /// In en, this message translates to:
  /// **'Upload photo'**
  String get uploadPhoto;

  /// No description provided for @photoTooLarge.
  ///
  /// In en, this message translates to:
  /// **'That image is too large. Please pick a smaller one.'**
  String get photoTooLarge;

  /// No description provided for @photoPickedError.
  ///
  /// In en, this message translates to:
  /// **'Could not read that image.'**
  String get photoPickedError;

  /// No description provided for @fullNameError.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get fullNameError;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get profileUpdated;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePassword;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get confirmNewPassword;

  /// No description provided for @passwordsDontMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDontMatch;

  /// No description provided for @passwordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password changed'**
  String get passwordChanged;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordTooShort;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @forgotPasswordBody.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we will send you a link to reset your password.'**
  String get forgotPasswordBody;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get sendResetLink;

  /// No description provided for @resetLinkSent.
  ///
  /// In en, this message translates to:
  /// **'Reset link sent'**
  String get resetLinkSent;

  /// email is the address the user entered
  ///
  /// In en, this message translates to:
  /// **'If an account exists for {email}, a reset link is on its way. Check your inbox.'**
  String resetLinkSentBody(Object email);

  /// No description provided for @demoResetHint.
  ///
  /// In en, this message translates to:
  /// **'Demo build — your reset link is below:'**
  String get demoResetHint;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPasswordTitle;

  /// No description provided for @resetPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Your email tells us the reset link points at your account.'**
  String get resetPasswordHint;

  /// No description provided for @resetPasswordCta.
  ///
  /// In en, this message translates to:
  /// **'Set new password'**
  String get resetPasswordCta;

  /// No description provided for @resetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password reset. Log in with your new password.'**
  String get resetSuccess;

  /// No description provided for @resetFailed.
  ///
  /// In en, this message translates to:
  /// **'This reset link is invalid or has expired.'**
  String get resetFailed;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get emailRequired;

  /// No description provided for @profileSectionAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get profileSectionAccount;

  /// No description provided for @profileSectionSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get profileSectionSecurity;

  /// No description provided for @profileSectionPlan.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get profileSectionPlan;

  /// No description provided for @profileSectionPreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get profileSectionPreferences;

  /// No description provided for @memberSince.
  ///
  /// In en, this message translates to:
  /// **'Member since June 2026'**
  String get memberSince;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal information'**
  String get personalInfo;

  /// No description provided for @twoFactorSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Set up 2FA'**
  String get twoFactorSetupTitle;

  /// No description provided for @twoFactorScanInstruction.
  ///
  /// In en, this message translates to:
  /// **'Scan this QR code with your authenticator app (Google Authenticator, Authy, etc.)'**
  String get twoFactorScanInstruction;

  /// No description provided for @twoFactorManualKey.
  ///
  /// In en, this message translates to:
  /// **'Or enter this key manually:'**
  String get twoFactorManualKey;

  /// No description provided for @twoFactorSecretCopied.
  ///
  /// In en, this message translates to:
  /// **'Secret copied to clipboard'**
  String get twoFactorSecretCopied;

  /// No description provided for @twoFactorEnterCode.
  ///
  /// In en, this message translates to:
  /// **'Enter 6-digit code'**
  String get twoFactorEnterCode;

  /// No description provided for @twoFactorVerifyEnable.
  ///
  /// In en, this message translates to:
  /// **'Verify & enable'**
  String get twoFactorVerifyEnable;

  /// No description provided for @twoFactorViewBackup.
  ///
  /// In en, this message translates to:
  /// **'View backup codes instead'**
  String get twoFactorViewBackup;

  /// No description provided for @twoFactorVerifyTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify identity'**
  String get twoFactorVerifyTitle;

  /// No description provided for @twoFactorEnter6Digit.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code from your authenticator app.'**
  String get twoFactorEnter6Digit;

  /// No description provided for @twoFactorAuthenticator.
  ///
  /// In en, this message translates to:
  /// **'Authenticator'**
  String get twoFactorAuthenticator;

  /// No description provided for @twoFactorEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get twoFactorEmail;

  /// No description provided for @twoFactorCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'6-digit code'**
  String get twoFactorCodeLabel;

  /// No description provided for @twoFactorVerify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get twoFactorVerify;

  /// Countdown before a code can be resent
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds} s'**
  String twoFactorResendIn(int seconds);

  /// No description provided for @twoFactorResend.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get twoFactorResend;

  /// No description provided for @twoFactorCodeRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code'**
  String get twoFactorCodeRequired;

  /// No description provided for @twoFactorBackupTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup codes'**
  String get twoFactorBackupTitle;

  /// No description provided for @twoFactorBackupInstruction.
  ///
  /// In en, this message translates to:
  /// **'Save these codes somewhere safe. Each code can be used once if you lose access to your authenticator.'**
  String get twoFactorBackupInstruction;

  /// No description provided for @twoFactorSavedCodes.
  ///
  /// In en, this message translates to:
  /// **'I\'ve saved these codes'**
  String get twoFactorSavedCodes;

  /// No description provided for @twoFactorCancelSetup.
  ///
  /// In en, this message translates to:
  /// **'Cancel setup'**
  String get twoFactorCancelSetup;

  /// No description provided for @twoFactorEnabledTitle.
  ///
  /// In en, this message translates to:
  /// **'2FA enabled!'**
  String get twoFactorEnabledTitle;

  /// No description provided for @twoFactorEnabledBody.
  ///
  /// In en, this message translates to:
  /// **'Your account is now protected with two-factor authentication.'**
  String get twoFactorEnabledBody;

  /// No description provided for @twoFactorDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get twoFactorDone;

  /// No description provided for @twoFactorStatusEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled — your account is protected'**
  String get twoFactorStatusEnabled;

  /// No description provided for @twoFactorStatusDisabled.
  ///
  /// In en, this message translates to:
  /// **'Not enabled — add an extra layer of security'**
  String get twoFactorStatusDisabled;

  /// No description provided for @twoFactorManage.
  ///
  /// In en, this message translates to:
  /// **'Manage 2FA'**
  String get twoFactorManage;

  /// No description provided for @twoFactorSetUp.
  ///
  /// In en, this message translates to:
  /// **'Set up 2FA'**
  String get twoFactorSetUp;

  /// No description provided for @twoFactorDisableTitle.
  ///
  /// In en, this message translates to:
  /// **'Disable 2FA'**
  String get twoFactorDisableTitle;

  /// No description provided for @twoFactorDisableBody.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code from your authenticator app to disable two-factor authentication.'**
  String get twoFactorDisableBody;

  /// No description provided for @twoFactorDisabled.
  ///
  /// In en, this message translates to:
  /// **'Two-factor authentication disabled'**
  String get twoFactorDisabled;

  /// No description provided for @disable.
  ///
  /// In en, this message translates to:
  /// **'Disable'**
  String get disable;

  /// Security score display
  ///
  /// In en, this message translates to:
  /// **'{score} / 99'**
  String securityScoreOutOf(int score);

  /// No description provided for @vaultWealthTitle.
  ///
  /// In en, this message translates to:
  /// **'Total wealth'**
  String get vaultWealthTitle;

  /// No description provided for @vaultInGoals.
  ///
  /// In en, this message translates to:
  /// **'in savings goals'**
  String get vaultInGoals;

  /// No description provided for @vaultInPension.
  ///
  /// In en, this message translates to:
  /// **'in pension'**
  String get vaultInPension;

  /// No description provided for @vaultSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Savings goals'**
  String get vaultSectionTitle;

  /// No description provided for @vaultNoPensionBody.
  ///
  /// In en, this message translates to:
  /// **'Start a flexible micro-pension to split savings between a short-term and long-term pot.'**
  String get vaultNoPensionBody;

  /// No description provided for @vaultManagePension.
  ///
  /// In en, this message translates to:
  /// **'Manage pension'**
  String get vaultManagePension;

  /// Pension projection headline
  ///
  /// In en, this message translates to:
  /// **'Projected {amount} at {age}'**
  String vaultPensionProjectedAt(String amount, int age);

  /// No description provided for @payRecentPayees.
  ///
  /// In en, this message translates to:
  /// **'Recent payees'**
  String get payRecentPayees;

  /// No description provided for @payNoPayeesBody.
  ///
  /// In en, this message translates to:
  /// **'Saved payees will appear here for fast transfers.'**
  String get payNoPayeesBody;

  /// No description provided for @payScheduledBills.
  ///
  /// In en, this message translates to:
  /// **'Scheduled bills'**
  String get payScheduledBills;

  /// No description provided for @payNoScheduledBody.
  ///
  /// In en, this message translates to:
  /// **'No scheduled or auto-pay bills yet.'**
  String get payNoScheduledBody;

  /// No description provided for @payHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment history'**
  String get payHistoryTitle;

  /// No description provided for @payViewHistory.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get payViewHistory;

  /// No description provided for @scheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get scheduled;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get markAllRead;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up!'**
  String get noNotifications;

  /// No description provided for @noNotificationsBody.
  ///
  /// In en, this message translates to:
  /// **'New notifications will appear here.'**
  String get noNotificationsBody;

  /// Relative time for notifications
  ///
  /// In en, this message translates to:
  /// **'{time} ago'**
  String notificationAgo(String time);

  /// Minutes ago
  ///
  /// In en, this message translates to:
  /// **'{n}m'**
  String timeMinutes(int n);

  /// Hours ago
  ///
  /// In en, this message translates to:
  /// **'{n}h'**
  String timeHours(int n);

  /// Days ago
  ///
  /// In en, this message translates to:
  /// **'{n}d'**
  String timeDays(int n);

  /// No description provided for @timeJustNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get timeJustNow;

  /// No description provided for @linkPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get linkPrivacyTitle;

  /// No description provided for @linkPrivacyBody.
  ///
  /// In en, this message translates to:
  /// **'Finovault collects your name, email, phone number, business details and financial transaction data to provide account aggregation, budgeting and invoicing services. Data is stored encrypted in secure facilities and shared only with your connected financial institutions for transaction syncing. We do not sell your data. Analytics cookies help us improve the app. You may request data export or deletion at any time via support@finovault.app. For privacy concerns contact our Data Protection Officer at dpo@finovault.app or write to Finovault Ltd, 12 Cyber City, Ebène, Mauritius.'**
  String get linkPrivacyBody;

  /// No description provided for @linkPrivacyAccept.
  ///
  /// In en, this message translates to:
  /// **'I accept the Privacy Policy'**
  String get linkPrivacyAccept;

  /// No description provided for @linkPrivacyButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get linkPrivacyButton;

  /// No description provided for @linkAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your account number'**
  String get linkAccountTitle;

  /// No description provided for @linkAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ll use this to connect your bank or mobile money account.'**
  String get linkAccountSubtitle;

  /// No description provided for @linkAccountHint.
  ///
  /// In en, this message translates to:
  /// **'Account or phone number'**
  String get linkAccountHint;

  /// No description provided for @linkAccountValidationEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter an account number.'**
  String get linkAccountValidationEmpty;

  /// No description provided for @linkAccountValidationBank.
  ///
  /// In en, this message translates to:
  /// **'Bank account number must be 8–16 digits.'**
  String get linkAccountValidationBank;

  /// No description provided for @linkAccountValidationMobile.
  ///
  /// In en, this message translates to:
  /// **'Mobile money number must be 5–8 digits starting with 5–7.'**
  String get linkAccountValidationMobile;

  /// No description provided for @linkAccountTypeBank.
  ///
  /// In en, this message translates to:
  /// **'Bank account'**
  String get linkAccountTypeBank;

  /// No description provided for @linkAccountTypeMobile.
  ///
  /// In en, this message translates to:
  /// **'Mobile money'**
  String get linkAccountTypeMobile;

  /// No description provided for @linkHolderName.
  ///
  /// In en, this message translates to:
  /// **'Account holder name'**
  String get linkHolderName;

  /// No description provided for @linkHolderHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the name registered on this account'**
  String get linkHolderHint;

  /// No description provided for @linkHolderEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter the account holder name.'**
  String get linkHolderEmpty;

  /// No description provided for @verifyMismatch.
  ///
  /// In en, this message translates to:
  /// **'The holder name does not match the registered name.'**
  String get verifyMismatch;

  /// No description provided for @verifyNotFound.
  ///
  /// In en, this message translates to:
  /// **'Account not found.'**
  String get verifyNotFound;

  /// Verified recipient name shown at transfer confirmation
  ///
  /// In en, this message translates to:
  /// **'Verified holder: {name}'**
  String verifyVerifiedAs(String name);

  /// No description provided for @linkingLoading.
  ///
  /// In en, this message translates to:
  /// **'Linking account…'**
  String get linkingLoading;

  /// No description provided for @linkSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Account linked!'**
  String get linkSuccessTitle;

  /// Success message after linking an account
  ///
  /// In en, this message translates to:
  /// **'{count} transactions imported.'**
  String linkSuccessBody(int count);

  /// No description provided for @linkSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get linkSkip;
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
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
