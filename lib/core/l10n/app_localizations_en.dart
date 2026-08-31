// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'PlateRoute Merchant';

  @override
  String get acceptNow => 'Accept order now';

  @override
  String get rejectNeedReason => 'Tell us why to inform the customer';

  @override
  String get startPrep => 'Start preparing';

  @override
  String get markReady => 'Food is ready';

  @override
  String autoCancelWarn(int seconds) {
    return 'Auto-cancels in ${seconds}s';
  }

  @override
  String get payoutLine => 'Your cut after platform fee';

  @override
  String get tabOrders => 'Orders';

  @override
  String get tabMenu => 'Menu';

  @override
  String get tabMoney => 'Money';

  @override
  String get tabMore => 'More';

  @override
  String get orderBoardActNow => 'ACT NOW';

  @override
  String get orderBoardInKitchen => 'IN KITCHEN';

  @override
  String get orderBoardScheduled => 'SCHEDULED';

  @override
  String get orderBoardHistory => 'HISTORY';

  @override
  String get statNewOrders => 'New';

  @override
  String get statActiveOrders => 'Active';

  @override
  String get statLateToday => 'Late';

  @override
  String get rejectOutOfStock => 'Out of stock';

  @override
  String get rejectTooBusy => 'Too busy';

  @override
  String get rejectClosingSoon => 'Closing soon';

  @override
  String get rejectCannotDeliver => 'Cannot deliver to area';

  @override
  String get rejectOther => 'Other';

  @override
  String get confirmReject => 'Confirm reject';

  @override
  String get connectingSocket => 'Reconnecting…';

  @override
  String get noOrdersActNow => 'No pending orders';

  @override
  String get noOrdersKitchen => 'Kitchen is clear';

  @override
  String get menuAvailable => 'Available';

  @override
  String get menuUnavailable => 'Unavailable';

  @override
  String get syncPending => 'Syncing…';

  @override
  String get loginTitle => 'Sign in to your restaurant';

  @override
  String get loginEmail => 'Email address';

  @override
  String get loginPassword => 'Password';

  @override
  String get loginButton => 'Sign in';

  @override
  String get loginForgotPassword => 'Forgot password?';

  @override
  String get onboardingTitle => 'Account status';

  @override
  String get onboardingPending => 'Pending review';

  @override
  String get onboardingApproved => 'Active';

  @override
  String get onboardingPaused => 'Paused';

  @override
  String get onboardingPendingBody =>
      'Our team is reviewing your application. We\'ll notify you when approved.';

  @override
  String get onboardingPausedBody =>
      'Your account has been paused. Please contact support.';

  @override
  String get moneyTitle => 'Payouts';

  @override
  String get moneyCurrentPeriod => 'Current period';

  @override
  String get moneyGross => 'Gross sales';

  @override
  String moneyCommission(String pct) {
    return 'Platform fee $pct%';
  }

  @override
  String get moneyNet => 'Your net';

  @override
  String get moneyHistory => 'Past periods';

  @override
  String get moneyViewInvoice => 'View invoice';

  @override
  String get reviewsTitle => 'Reviews';

  @override
  String get reviewsReply => 'Reply to customer';

  @override
  String get reviewsSend => 'Send reply';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsDarkMode => 'Dark mode';

  @override
  String get settingsSoundFamily => 'Alert sound';

  @override
  String get settingsShiftOnline => 'Shift online';

  @override
  String get staffTitle => 'Staff';

  @override
  String get hoursTitle => 'Opening hours';

  @override
  String get closuresTitle => 'Closures';

  @override
  String get itemEditorTitle => 'Edit item';

  @override
  String get priceEditTitle => 'Update price';

  @override
  String get priceOld => 'Current';

  @override
  String get priceNew => 'New price';

  @override
  String get priceConfirm => 'Confirm';

  @override
  String get uploadPhoto => 'Add photo';

  @override
  String get saveChanges => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get loading => 'Loading…';

  @override
  String get error => 'Something went wrong';

  @override
  String get retry => 'Try again';

  @override
  String get passwordResetTitle => 'Reset password';

  @override
  String get passwordResetSend => 'Send reset email';

  @override
  String get passwordResetOtpLabel => 'Enter the code from your email';

  @override
  String get passwordResetNewPassword => 'New password';

  @override
  String get passwordResetConfirm => 'Set new password';

  @override
  String get healthCardTitle => 'Store health';

  @override
  String get healthCardCta => 'Fix now';

  @override
  String get alarmNewOrder => 'New order!';

  @override
  String orderItems(int count) {
    return '$count items';
  }

  @override
  String orderTotal(String amount) {
    return '৳$amount';
  }
}
