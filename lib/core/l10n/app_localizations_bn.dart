// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get appName => 'প্লেটরুট মার্চেন্ট';

  @override
  String get acceptNow => 'অর্ডার এখন গ্রহণ করুন';

  @override
  String get rejectNeedReason => 'কাস্টমারকে জানাতে কারণ দিন';

  @override
  String get startPrep => 'প্রস্তুতি শুরু';

  @override
  String get markReady => 'খাবার প্রস্তুত';

  @override
  String autoCancelWarn(int seconds) {
    return '$seconds সেকেন্ডে বাতিল হবে';
  }

  @override
  String get payoutLine => 'প্ল্যাটফর্ম ফি-র পরে আপনার অংশ';

  @override
  String get tabOrders => 'অর্ডার';

  @override
  String get tabMenu => 'মেনু';

  @override
  String get tabMoney => 'টাকা';

  @override
  String get tabMore => 'আরো';

  @override
  String get orderBoardActNow => 'এখনই করুন';

  @override
  String get orderBoardInKitchen => 'রান্নায়';

  @override
  String get orderBoardScheduled => 'নির্ধারিত';

  @override
  String get orderBoardHistory => 'ইতিহাস';

  @override
  String get statNewOrders => 'নতুন';

  @override
  String get statActiveOrders => 'সক্রিয়';

  @override
  String get statLateToday => 'দেরি';

  @override
  String get rejectOutOfStock => 'স্টকে নেই';

  @override
  String get rejectTooBusy => 'অনেক ব্যস্ত';

  @override
  String get rejectClosingSoon => 'শীঘ্রই বন্ধ';

  @override
  String get rejectCannotDeliver => 'এলাকায় ডেলিভারি সম্ভব নয়';

  @override
  String get rejectOther => 'অন্য কারণ';

  @override
  String get confirmReject => 'বাতিল নিশ্চিত করুন';

  @override
  String get connectingSocket => 'পুনরায় সংযোগ হচ্ছে…';

  @override
  String get noOrdersActNow => 'কোনো মুলতুবি অর্ডার নেই';

  @override
  String get noOrdersKitchen => 'রান্নাঘর পরিষ্কার';

  @override
  String get menuAvailable => 'পাওয়া যাচ্ছে';

  @override
  String get menuUnavailable => 'পাওয়া যাচ্ছে না';

  @override
  String get syncPending => 'সিঙ্ক হচ্ছে…';

  @override
  String get loginTitle => 'আপনার রেস্তোরাঁয় সাইন ইন করুন';

  @override
  String get loginEmail => 'ইমেইল ঠিকানা';

  @override
  String get loginPassword => 'পাসওয়ার্ড';

  @override
  String get loginButton => 'সাইন ইন';

  @override
  String get loginForgotPassword => 'পাসওয়ার্ড ভুলে গেছেন?';

  @override
  String get onboardingTitle => 'অ্যাকাউন্টের অবস্থা';

  @override
  String get onboardingPending => 'পর্যালোচনাধীন';

  @override
  String get onboardingApproved => 'সক্রিয়';

  @override
  String get onboardingPaused => 'বিরতিতে';

  @override
  String get onboardingPendingBody =>
      'আমাদের টিম আপনার আবেদন পর্যালোচনা করছে। অনুমোদন হলে জানানো হবে।';

  @override
  String get onboardingPausedBody =>
      'আপনার অ্যাকাউন্ট বিরতিতে আছে। সাপোর্টে যোগাযোগ করুন।';

  @override
  String get moneyTitle => 'পেআউট';

  @override
  String get moneyCurrentPeriod => 'চলতি সময়কাল';

  @override
  String get moneyGross => 'মোট বিক্রয়';

  @override
  String moneyCommission(String pct) {
    return 'প্ল্যাটফর্ম ফি $pct%';
  }

  @override
  String get moneyNet => 'আপনার নেট';

  @override
  String get moneyHistory => 'আগের সময়কাল';

  @override
  String get moneyViewInvoice => 'ইনভয়েস দেখুন';

  @override
  String get reviewsTitle => 'রিভিউ';

  @override
  String get reviewsReply => 'কাস্টমারকে উত্তর দিন';

  @override
  String get reviewsSend => 'উত্তর পাঠান';

  @override
  String get settingsTitle => 'সেটিংস';

  @override
  String get settingsDarkMode => 'ডার্ক মোড';

  @override
  String get settingsSoundFamily => 'অ্যালার্ট শব্দ';

  @override
  String get settingsShiftOnline => 'শিফট অনলাইন';

  @override
  String get staffTitle => 'স্টাফ';

  @override
  String get hoursTitle => 'খোলার সময়';

  @override
  String get closuresTitle => 'বন্ধের তারিখ';

  @override
  String get itemEditorTitle => 'আইটেম সম্পাদনা';

  @override
  String get priceEditTitle => 'দাম আপডেট';

  @override
  String get priceOld => 'বর্তমান';

  @override
  String get priceNew => 'নতুন দাম';

  @override
  String get priceConfirm => 'নিশ্চিত';

  @override
  String get uploadPhoto => 'ছবি যোগ করুন';

  @override
  String get saveChanges => 'সংরক্ষণ';

  @override
  String get cancel => 'বাতিল';

  @override
  String get delete => 'মুছুন';

  @override
  String get loading => 'লোড হচ্ছে…';

  @override
  String get error => 'কিছু একটা সমস্যা হয়েছে';

  @override
  String get retry => 'আবার চেষ্টা করুন';

  @override
  String get passwordResetTitle => 'পাসওয়ার্ড রিসেট';

  @override
  String get passwordResetSend => 'রিসেট ইমেইল পাঠান';

  @override
  String get passwordResetOtpLabel => 'ইমেইল থেকে কোড দিন';

  @override
  String get passwordResetNewPassword => 'নতুন পাসওয়ার্ড';

  @override
  String get passwordResetConfirm => 'নতুন পাসওয়ার্ড সেট করুন';

  @override
  String get healthCardTitle => 'স্টোর স্বাস্থ্য';

  @override
  String get healthCardCta => 'এখন ঠিক করুন';

  @override
  String get alarmNewOrder => 'নতুন অর্ডার!';

  @override
  String orderItems(int count) {
    return '$countটি আইটেম';
  }

  @override
  String orderTotal(String amount) {
    return '৳$amount';
  }
}
