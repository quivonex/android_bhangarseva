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
    Locale('mr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Bhangarwala App'**
  String get appTitle;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select your language'**
  String get selectLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @hindi.
  ///
  /// In en, this message translates to:
  /// **'Hindi'**
  String get hindi;

  /// No description provided for @marathi.
  ///
  /// In en, this message translates to:
  /// **'Marathi'**
  String get marathi;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'selected'**
  String get selected;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @languageChanged.
  ///
  /// In en, this message translates to:
  /// **'Language changed to'**
  String get languageChanged;

  /// No description provided for @schedulePickup.
  ///
  /// In en, this message translates to:
  /// **'Schedule Pickup'**
  String get schedulePickup;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @homeDashboard.
  ///
  /// In en, this message translates to:
  /// **'Home Dashboard'**
  String get homeDashboard;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back!'**
  String get welcomeBack;

  /// No description provided for @readyToRecycle.
  ///
  /// In en, this message translates to:
  /// **'Ready to recycle and earn?'**
  String get readyToRecycle;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @newEnquiry.
  ///
  /// In en, this message translates to:
  /// **'New Enquiry'**
  String get newEnquiry;

  /// No description provided for @checkPriceList.
  ///
  /// In en, this message translates to:
  /// **'Check Price List'**
  String get checkPriceList;

  /// No description provided for @orderHistory.
  ///
  /// In en, this message translates to:
  /// **'Order History'**
  String get orderHistory;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @priceList.
  ///
  /// In en, this message translates to:
  /// **'Price List'**
  String get priceList;

  /// No description provided for @languageChange.
  ///
  /// In en, this message translates to:
  /// **'Language Change'**
  String get languageChange;

  /// No description provided for @shareUs.
  ///
  /// In en, this message translates to:
  /// **'Share Us'**
  String get shareUs;

  /// No description provided for @aboutUs.
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get aboutUs;

  /// No description provided for @chatSupport.
  ///
  /// In en, this message translates to:
  /// **'Chat Support'**
  String get chatSupport;

  /// No description provided for @termsConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsConditions;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @selectProducts.
  ///
  /// In en, this message translates to:
  /// **'Select Products'**
  String get selectProducts;

  /// No description provided for @noProducts.
  ///
  /// In en, this message translates to:
  /// **'No products found'**
  String get noProducts;

  /// No description provided for @searchProducts.
  ///
  /// In en, this message translates to:
  /// **'Search products or items...'**
  String get searchProducts;

  /// No description provided for @itemsSelected.
  ///
  /// In en, this message translates to:
  /// **'Items Selected'**
  String get itemsSelected;

  /// No description provided for @ourPrice.
  ///
  /// In en, this message translates to:
  /// **'Our Price'**
  String get ourPrice;

  /// No description provided for @otherPrice.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get otherPrice;

  /// No description provided for @youEarn.
  ///
  /// In en, this message translates to:
  /// **'You Earn'**
  String get youEarn;

  /// No description provided for @enterWeight.
  ///
  /// In en, this message translates to:
  /// **'Enter weight in {unit}'**
  String enterWeight(Object unit);

  /// No description provided for @recalculate.
  ///
  /// In en, this message translates to:
  /// **'Recalculate'**
  String get recalculate;

  /// No description provided for @calculateActual.
  ///
  /// In en, this message translates to:
  /// **'Calculate Actual'**
  String get calculateActual;

  /// No description provided for @viewDetailedCalculation.
  ///
  /// In en, this message translates to:
  /// **'View Detailed Calculation'**
  String get viewDetailedCalculation;

  /// No description provided for @multipleProducts.
  ///
  /// In en, this message translates to:
  /// **'Multiple Products'**
  String get multipleProducts;

  /// No description provided for @snackSelectOne.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one item with quantity'**
  String get snackSelectOne;

  /// No description provided for @noProductsFound.
  ///
  /// In en, this message translates to:
  /// **'No products found'**
  String get noProductsFound;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search products or items...'**
  String get searchHint;

  /// No description provided for @pleaseSelectItem.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one item with quantity'**
  String get pleaseSelectItem;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'{weight} kg'**
  String weight(Object weight);

  /// No description provided for @calculate.
  ///
  /// In en, this message translates to:
  /// **'Calculate Actual'**
  String get calculate;

  /// No description provided for @bulkOrder.
  ///
  /// In en, this message translates to:
  /// **'Bulk Order'**
  String get bulkOrder;

  /// No description provided for @complaints.
  ///
  /// In en, this message translates to:
  /// **'Complaints'**
  String get complaints;

  /// No description provided for @feedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedback;

  /// No description provided for @selectAtLeastOneItem.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one item with quantity'**
  String get selectAtLeastOneItem;

  /// No description provided for @enterWeightIn.
  ///
  /// In en, this message translates to:
  /// **'Enter weight in'**
  String get enterWeightIn;

  /// No description provided for @priceCalculation.
  ///
  /// In en, this message translates to:
  /// **'Price Calculation'**
  String get priceCalculation;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @noDataReceived.
  ///
  /// In en, this message translates to:
  /// **'No data received'**
  String get noDataReceived;

  /// No description provided for @calculationFor.
  ///
  /// In en, this message translates to:
  /// **'Calculation for'**
  String get calculationFor;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'items'**
  String get items;

  /// No description provided for @qty.
  ///
  /// In en, this message translates to:
  /// **'Qty'**
  String get qty;

  /// No description provided for @ourRate.
  ///
  /// In en, this message translates to:
  /// **'Our Rate'**
  String get ourRate;

  /// No description provided for @otherRate.
  ///
  /// In en, this message translates to:
  /// **'Other Rate'**
  String get otherRate;

  /// No description provided for @totalEarningsSummary.
  ///
  /// In en, this message translates to:
  /// **'Total Earnings Summary'**
  String get totalEarningsSummary;

  /// No description provided for @ourTotal.
  ///
  /// In en, this message translates to:
  /// **'Our Total'**
  String get ourTotal;

  /// No description provided for @otherTotal.
  ///
  /// In en, this message translates to:
  /// **'Other Total'**
  String get otherTotal;

  /// No description provided for @netEarnings.
  ///
  /// In en, this message translates to:
  /// **'Net Earnings'**
  String get netEarnings;

  /// No description provided for @proceedToPickup.
  ///
  /// In en, this message translates to:
  /// **'Proceed to Pickup'**
  String get proceedToPickup;

  /// No description provided for @pickupLocation.
  ///
  /// In en, this message translates to:
  /// **'Pickup Location'**
  String get pickupLocation;

  /// No description provided for @tapOnMap.
  ///
  /// In en, this message translates to:
  /// **'Tap on map to select location'**
  String get tapOnMap;

  /// No description provided for @unableToFetch.
  ///
  /// In en, this message translates to:
  /// **'Unable to fetch address'**
  String get unableToFetch;

  /// No description provided for @selectedLocation.
  ///
  /// In en, this message translates to:
  /// **'Selected Location'**
  String get selectedLocation;

  /// No description provided for @continueBtn.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueBtn;

  /// No description provided for @confirmOrder.
  ///
  /// In en, this message translates to:
  /// **'Confirm Order'**
  String get confirmOrder;

  /// No description provided for @failedTimeSlots.
  ///
  /// In en, this message translates to:
  /// **'Failed to load time slots'**
  String get failedTimeSlots;

  /// No description provided for @imagePickFailed.
  ///
  /// In en, this message translates to:
  /// **'Image pick failed'**
  String get imagePickFailed;

  /// No description provided for @imageCompressFailed.
  ///
  /// In en, this message translates to:
  /// **'Image compression failed'**
  String get imageCompressFailed;

  /// No description provided for @uploadPhoto.
  ///
  /// In en, this message translates to:
  /// **'Please upload at least 1 photo'**
  String get uploadPhoto;

  /// No description provided for @selectTimeSlot.
  ///
  /// In en, this message translates to:
  /// **'Please select a time slot'**
  String get selectTimeSlot;

  /// No description provided for @submissionFailed.
  ///
  /// In en, this message translates to:
  /// **'Submission failed'**
  String get submissionFailed;

  /// No description provided for @orderPlaced.
  ///
  /// In en, this message translates to:
  /// **'Order Placed!'**
  String get orderPlaced;

  /// No description provided for @orderID.
  ///
  /// In en, this message translates to:
  /// **'Order ID'**
  String get orderID;

  /// No description provided for @orderPlacedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your order has been placed successfully'**
  String get orderPlacedSuccess;

  /// No description provided for @goHome.
  ///
  /// In en, this message translates to:
  /// **'Go Home'**
  String get goHome;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @noPhotosAdded.
  ///
  /// In en, this message translates to:
  /// **'No photos added'**
  String get noPhotosAdded;

  /// No description provided for @specialInstructions.
  ///
  /// In en, this message translates to:
  /// **'Special Instructions'**
  String get specialInstructions;

  /// No description provided for @yourName.
  ///
  /// In en, this message translates to:
  /// **'Your Name'**
  String get yourName;

  /// No description provided for @contactNumber.
  ///
  /// In en, this message translates to:
  /// **'Contact Number'**
  String get contactNumber;

  /// No description provided for @alternateContact.
  ///
  /// In en, this message translates to:
  /// **'Alternate Contact'**
  String get alternateContact;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @landmark.
  ///
  /// In en, this message translates to:
  /// **'Landmark'**
  String get landmark;

  /// No description provided for @upiID.
  ///
  /// In en, this message translates to:
  /// **'UPI ID'**
  String get upiID;

  /// No description provided for @selectTimeSlotLabel.
  ///
  /// In en, this message translates to:
  /// **'Select Time Slot'**
  String get selectTimeSlotLabel;

  /// No description provided for @noTimeSlotsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No time slots available'**
  String get noTimeSlotsAvailable;
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
    'that was used.',
  );
}
