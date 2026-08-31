import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';

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
    Locale('bn'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'PlateRoute Merchant'**
  String get appName;

  /// Accept button on alarm/order card
  ///
  /// In en, this message translates to:
  /// **'Accept order now'**
  String get acceptNow;

  /// Reject sheet header
  ///
  /// In en, this message translates to:
  /// **'Tell us why to inform the customer'**
  String get rejectNeedReason;

  /// PREPARING stage button
  ///
  /// In en, this message translates to:
  /// **'Start preparing'**
  String get startPrep;

  /// READY stage button
  ///
  /// In en, this message translates to:
  /// **'Food is ready'**
  String get markReady;

  /// Countdown warning on alarm overlay
  ///
  /// In en, this message translates to:
  /// **'Auto-cancels in {seconds}s'**
  String autoCancelWarn(int seconds);

  /// Payout tab subtitle
  ///
  /// In en, this message translates to:
  /// **'Your cut after platform fee'**
  String get payoutLine;

  /// No description provided for @tabOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get tabOrders;

  /// No description provided for @tabMenu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get tabMenu;

  /// No description provided for @tabMoney.
  ///
  /// In en, this message translates to:
  /// **'Money'**
  String get tabMoney;

  /// No description provided for @tabMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get tabMore;

  /// No description provided for @orderBoardActNow.
  ///
  /// In en, this message translates to:
  /// **'ACT NOW'**
  String get orderBoardActNow;

  /// No description provided for @orderBoardInKitchen.
  ///
  /// In en, this message translates to:
  /// **'IN KITCHEN'**
  String get orderBoardInKitchen;

  /// No description provided for @orderBoardScheduled.
  ///
  /// In en, this message translates to:
  /// **'SCHEDULED'**
  String get orderBoardScheduled;

  /// No description provided for @orderBoardHistory.
  ///
  /// In en, this message translates to:
  /// **'HISTORY'**
  String get orderBoardHistory;

  /// No description provided for @statNewOrders.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get statNewOrders;

  /// No description provided for @statActiveOrders.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get statActiveOrders;

  /// No description provided for @statLateToday.
  ///
  /// In en, this message translates to:
  /// **'Late'**
  String get statLateToday;

  /// No description provided for @rejectOutOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of stock'**
  String get rejectOutOfStock;

  /// No description provided for @rejectTooBusy.
  ///
  /// In en, this message translates to:
  /// **'Too busy'**
  String get rejectTooBusy;

  /// No description provided for @rejectClosingSoon.
  ///
  /// In en, this message translates to:
  /// **'Closing soon'**
  String get rejectClosingSoon;

  /// No description provided for @rejectCannotDeliver.
  ///
  /// In en, this message translates to:
  /// **'Cannot deliver to area'**
  String get rejectCannotDeliver;

  /// No description provided for @rejectOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get rejectOther;

  /// No description provided for @confirmReject.
  ///
  /// In en, this message translates to:
  /// **'Confirm reject'**
  String get confirmReject;

  /// No description provided for @connectingSocket.
  ///
  /// In en, this message translates to:
  /// **'Reconnecting…'**
  String get connectingSocket;

  /// No description provided for @noOrdersActNow.
  ///
  /// In en, this message translates to:
  /// **'No pending orders'**
  String get noOrdersActNow;

  /// No description provided for @noOrdersKitchen.
  ///
  /// In en, this message translates to:
  /// **'Kitchen is clear'**
  String get noOrdersKitchen;

  /// No description provided for @menuAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get menuAvailable;

  /// No description provided for @menuUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get menuUnavailable;

  /// No description provided for @syncPending.
  ///
  /// In en, this message translates to:
  /// **'Syncing…'**
  String get syncPending;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your restaurant'**
  String get loginTitle;

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
  /// **'Sign in'**
  String get loginButton;

  /// No description provided for @loginForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get loginForgotPassword;

  /// No description provided for @onboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Account status'**
  String get onboardingTitle;

  /// No description provided for @onboardingPending.
  ///
  /// In en, this message translates to:
  /// **'Pending review'**
  String get onboardingPending;

  /// No description provided for @onboardingApproved.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get onboardingApproved;

  /// No description provided for @onboardingPaused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get onboardingPaused;

  /// No description provided for @onboardingPendingBody.
  ///
  /// In en, this message translates to:
  /// **'Our team is reviewing your application. We\'ll notify you when approved.'**
  String get onboardingPendingBody;

  /// No description provided for @onboardingPausedBody.
  ///
  /// In en, this message translates to:
  /// **'Your account has been paused. Please contact support.'**
  String get onboardingPausedBody;

  /// No description provided for @moneyTitle.
  ///
  /// In en, this message translates to:
  /// **'Payouts'**
  String get moneyTitle;

  /// No description provided for @moneyCurrentPeriod.
  ///
  /// In en, this message translates to:
  /// **'Current period'**
  String get moneyCurrentPeriod;

  /// No description provided for @moneyGross.
  ///
  /// In en, this message translates to:
  /// **'Gross sales'**
  String get moneyGross;

  /// No description provided for @moneyCommission.
  ///
  /// In en, this message translates to:
  /// **'Platform fee {pct}%'**
  String moneyCommission(String pct);

  /// No description provided for @moneyNet.
  ///
  /// In en, this message translates to:
  /// **'Your net'**
  String get moneyNet;

  /// No description provided for @moneyHistory.
  ///
  /// In en, this message translates to:
  /// **'Past periods'**
  String get moneyHistory;

  /// No description provided for @moneyViewInvoice.
  ///
  /// In en, this message translates to:
  /// **'View invoice'**
  String get moneyViewInvoice;

  /// No description provided for @reviewsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviewsTitle;

  /// No description provided for @reviewsReply.
  ///
  /// In en, this message translates to:
  /// **'Reply to customer'**
  String get reviewsReply;

  /// No description provided for @reviewsSend.
  ///
  /// In en, this message translates to:
  /// **'Send reply'**
  String get reviewsSend;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get settingsDarkMode;

  /// No description provided for @settingsSoundFamily.
  ///
  /// In en, this message translates to:
  /// **'Alert sound'**
  String get settingsSoundFamily;

  /// No description provided for @settingsShiftOnline.
  ///
  /// In en, this message translates to:
  /// **'Shift online'**
  String get settingsShiftOnline;

  /// No description provided for @staffTitle.
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get staffTitle;

  /// No description provided for @hoursTitle.
  ///
  /// In en, this message translates to:
  /// **'Opening hours'**
  String get hoursTitle;

  /// No description provided for @closuresTitle.
  ///
  /// In en, this message translates to:
  /// **'Closures'**
  String get closuresTitle;

  /// No description provided for @itemEditorTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit item'**
  String get itemEditorTitle;

  /// No description provided for @priceEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Update price'**
  String get priceEditTitle;

  /// No description provided for @priceOld.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get priceOld;

  /// No description provided for @priceNew.
  ///
  /// In en, this message translates to:
  /// **'New price'**
  String get priceNew;

  /// No description provided for @priceConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get priceConfirm;

  /// No description provided for @uploadPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get uploadPhoto;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveChanges;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get error;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @passwordResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get passwordResetTitle;

  /// No description provided for @passwordResetSend.
  ///
  /// In en, this message translates to:
  /// **'Send reset email'**
  String get passwordResetSend;

  /// No description provided for @passwordResetOtpLabel.
  ///
  /// In en, this message translates to:
  /// **'Enter the code from your email'**
  String get passwordResetOtpLabel;

  /// No description provided for @passwordResetNewPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get passwordResetNewPassword;

  /// No description provided for @passwordResetConfirm.
  ///
  /// In en, this message translates to:
  /// **'Set new password'**
  String get passwordResetConfirm;

  /// No description provided for @healthCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Store health'**
  String get healthCardTitle;

  /// No description provided for @healthCardCta.
  ///
  /// In en, this message translates to:
  /// **'Fix now'**
  String get healthCardCta;

  /// No description provided for @alarmNewOrder.
  ///
  /// In en, this message translates to:
  /// **'New order!'**
  String get alarmNewOrder;

  /// No description provided for @orderItems.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String orderItems(int count);

  /// No description provided for @orderTotal.
  ///
  /// In en, this message translates to:
  /// **'৳{amount}'**
  String orderTotal(String amount);
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
      <String>['bn', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
