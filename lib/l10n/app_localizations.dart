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
