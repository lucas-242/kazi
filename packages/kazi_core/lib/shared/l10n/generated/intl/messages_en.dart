// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(property) => "${property} already exists";

  static String m1(url) => "Could not launch ${url}";

  static String m2(start, end) => "Filtering from ${start} to ${end}";

  static String m3(count) => "${count} clients";

  static String m4(count) => "${count} services / month";

  static String m5(count) => "${count} service types";

  static String m6(start, end) => "From ${start} to ${end}";

  static String m7(person) => "Hi, ${person}!";

  static String m8(property) => "${property} is being used";

  static String m9(property) => "${property} is invalid";

  static String m10(property) => "${property} is Empty";

  static String m11(price) => "${price}/month";

  static String m12(price) => "7 days free, then ${price}/month.";

  static String m13(property) => "${property} is required";

  static String m14(item) => "Would you like to delete ${item}?";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "actions": MessageLookupByLibrary.simpleMessage("Actions"),
    "add": MessageLookupByLibrary.simpleMessage("Add"),
    "addClient": MessageLookupByLibrary.simpleMessage("Add client"),
    "address": MessageLookupByLibrary.simpleMessage("Address"),
    "all": MessageLookupByLibrary.simpleMessage("All"),
    "alreadyExists": m0,
    "alreadyHasAccont": MessageLookupByLibrary.simpleMessage(
      "Already has an account? ",
    ),
    "appSubtitle": MessageLookupByLibrary.simpleMessage(
      "Organize your services",
    ),
    "applyFilters": MessageLookupByLibrary.simpleMessage("Apply Filters"),
    "back": MessageLookupByLibrary.simpleMessage("Back"),
    "birthDate": MessageLookupByLibrary.simpleMessage("Birth date"),
    "calculator": MessageLookupByLibrary.simpleMessage("Calculator"),
    "calendar": MessageLookupByLibrary.simpleMessage("Calendar"),
    "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "changePassword": MessageLookupByLibrary.simpleMessage("Change Password"),
    "client": MessageLookupByLibrary.simpleMessage("Client"),
    "clients": MessageLookupByLibrary.simpleMessage("Clients"),
    "clipperCut": MessageLookupByLibrary.simpleMessage("Clipper cut"),
    "close": MessageLookupByLibrary.simpleMessage("Close"),
    "confirm": MessageLookupByLibrary.simpleMessage("Confirm"),
    "confirmAction": MessageLookupByLibrary.simpleMessage("Confirm Action"),
    "confirmPassword": MessageLookupByLibrary.simpleMessage("Confirm Password"),
    "contact": MessageLookupByLibrary.simpleMessage("Contact"),
    "contactEmail": MessageLookupByLibrary.simpleMessage(
      "guimaraeslucas242@gmail.com",
    ),
    "continueAction": MessageLookupByLibrary.simpleMessage("Continue"),
    "cpfCnpj": MessageLookupByLibrary.simpleMessage("CPF/CNPJ"),
    "create": MessageLookupByLibrary.simpleMessage("Create"),
    "createAccount": MessageLookupByLibrary.simpleMessage("Create an Account"),
    "currency": MessageLookupByLibrary.simpleMessage("Currency"),
    "currencyBRL": MessageLookupByLibrary.simpleMessage("Brazilian real"),
    "currencyCAD": MessageLookupByLibrary.simpleMessage("Canadian dollar"),
    "currencyINR": MessageLookupByLibrary.simpleMessage("Indian rupee"),
    "currencyKES": MessageLookupByLibrary.simpleMessage("Kenyan shilling"),
    "currencyNGN": MessageLookupByLibrary.simpleMessage("Nigerian naira"),
    "currencyPYG": MessageLookupByLibrary.simpleMessage("Paraguayan guaraní"),
    "currencyUGX": MessageLookupByLibrary.simpleMessage("Ugandan shilling"),
    "currencyUSD": MessageLookupByLibrary.simpleMessage("US dollar"),
    "currentPassword": MessageLookupByLibrary.simpleMessage("Current Password"),
    "darkMode": MessageLookupByLibrary.simpleMessage("Dark Mode"),
    "date": MessageLookupByLibrary.simpleMessage("Date"),
    "defaultCurrency": MessageLookupByLibrary.simpleMessage("Default currency"),
    "defaultValue": MessageLookupByLibrary.simpleMessage("Default Value"),
    "delete": MessageLookupByLibrary.simpleMessage("Delete"),
    "description": MessageLookupByLibrary.simpleMessage("Description"),
    "details": MessageLookupByLibrary.simpleMessage("Details"),
    "didntReceiveAnything": MessageLookupByLibrary.simpleMessage(
      "Didn\'t receive anything? ",
    ),
    "discount": MessageLookupByLibrary.simpleMessage("Discount"),
    "discountPercentage": MessageLookupByLibrary.simpleMessage(
      "Discount percentage",
    ),
    "discounts": MessageLookupByLibrary.simpleMessage("Discounts"),
    "doesntHaveAccount": MessageLookupByLibrary.simpleMessage(
      "Doesn\'t have an account? ",
    ),
    "edit": MessageLookupByLibrary.simpleMessage("Edit"),
    "editService": MessageLookupByLibrary.simpleMessage("Edit Service"),
    "editServiceType": MessageLookupByLibrary.simpleMessage("Edit Type"),
    "email": MessageLookupByLibrary.simpleMessage("Email"),
    "employee": MessageLookupByLibrary.simpleMessage("Employee"),
    "employees": MessageLookupByLibrary.simpleMessage("Employees"),
    "errorAccessDenied": MessageLookupByLibrary.simpleMessage("Access Denied"),
    "errorCantDeleteServiceType": MessageLookupByLibrary.simpleMessage(
      "The service type can\'t be deleted because it is being used",
    ),
    "errorCredentialIsInvalid": MessageLookupByLibrary.simpleMessage(
      "The credential is invalid",
    ),
    "errorEmailIsInvalid": MessageLookupByLibrary.simpleMessage(
      "Email is invalid or badly formatted",
    ),
    "errorEmailWasNotFound": MessageLookupByLibrary.simpleMessage(
      "Email was not found, please create an account",
    ),
    "errorIncorrectEmailOrPassword": MessageLookupByLibrary.simpleMessage(
      "Incorrect email or password",
    ),
    "errorLaunchUrl": m1,
    "errorMethodNotAllowed": MessageLookupByLibrary.simpleMessage(
      "Method not allowed. Please try another account or contact support for help",
    ),
    "errorNotFound": MessageLookupByLibrary.simpleMessage("Url not found."),
    "errorThereIsAnotherAccount": MessageLookupByLibrary.simpleMessage(
      "There is already an account with this credential",
    ),
    "errorTimeout": MessageLookupByLibrary.simpleMessage(
      "The server took a long time to respond. Please try again later or contact us.",
    ),
    "errorToAddClient": MessageLookupByLibrary.simpleMessage(
      "Error to add client.",
    ),
    "errorToAddService": MessageLookupByLibrary.simpleMessage(
      "Error to add service.",
    ),
    "errorToAddServiceType": MessageLookupByLibrary.simpleMessage(
      "Error to add service type.",
    ),
    "errorToCountServices": MessageLookupByLibrary.simpleMessage(
      "Error to count services.",
    ),
    "errorToDeleteClient": MessageLookupByLibrary.simpleMessage(
      "Error to delete client.",
    ),
    "errorToDeleteService": MessageLookupByLibrary.simpleMessage(
      "Error to delete service.",
    ),
    "errorToDeleteServiceType": MessageLookupByLibrary.simpleMessage(
      "Error to delete service type.",
    ),
    "errorToGetClients": MessageLookupByLibrary.simpleMessage(
      "Error to get clients.",
    ),
    "errorToGetServiceTypes": MessageLookupByLibrary.simpleMessage(
      "Error to get service types.",
    ),
    "errorToGetServices": MessageLookupByLibrary.simpleMessage(
      "Error to get service.",
    ),
    "errorToResetPassword": MessageLookupByLibrary.simpleMessage(
      "Error to reset password.",
    ),
    "errorToSendEmail": MessageLookupByLibrary.simpleMessage(
      "Error to send email.",
    ),
    "errorToSignIn": MessageLookupByLibrary.simpleMessage(
      "Error to sign in. Try again later or contact the support.",
    ),
    "errorToSignUp": MessageLookupByLibrary.simpleMessage(
      "Error to sign up. Try again later or contact the support.",
    ),
    "errorToUpdateClient": MessageLookupByLibrary.simpleMessage(
      "Error to update client.",
    ),
    "errorToUpdateService": MessageLookupByLibrary.simpleMessage(
      "Error to update service.",
    ),
    "errorToUpdateServiceType": MessageLookupByLibrary.simpleMessage(
      "Error to update service type.",
    ),
    "errorTokenExpired": MessageLookupByLibrary.simpleMessage(
      "Your login expired. Please, login and try again.",
    ),
    "errorUnknowError": MessageLookupByLibrary.simpleMessage(
      "An unknown exception occurred.",
    ),
    "errorUserHasBeenDisabled": MessageLookupByLibrary.simpleMessage(
      "This user has been disabled. Please contact support for help",
    ),
    "errorVerificationCodeIsInvalid": MessageLookupByLibrary.simpleMessage(
      "The verification code entered is invalid",
    ),
    "errorVerificationIdIsInvalid": MessageLookupByLibrary.simpleMessage(
      "The verification ID entered is invalid",
    ),
    "exit": MessageLookupByLibrary.simpleMessage("Exit"),
    "featureNoAds": MessageLookupByLibrary.simpleMessage("No ads"),
    "featureUnlimitedClients": MessageLookupByLibrary.simpleMessage(
      "Unlimited clients",
    ),
    "featureUnlimitedServices": MessageLookupByLibrary.simpleMessage(
      "Unlimited services",
    ),
    "featureUnlimitedTypes": MessageLookupByLibrary.simpleMessage(
      "Unlimited service types",
    ),
    "field": MessageLookupByLibrary.simpleMessage("Field"),
    "filteringFromTo": m2,
    "filteringLastMonth": MessageLookupByLibrary.simpleMessage(
      "Filtering by last month",
    ),
    "filteringToday": MessageLookupByLibrary.simpleMessage(
      "Filtering by today",
    ),
    "filters": MessageLookupByLibrary.simpleMessage("Filters"),
    "finish": MessageLookupByLibrary.simpleMessage("Finish"),
    "forcedUpdateButton": MessageLookupByLibrary.simpleMessage("Update now"),
    "forcedUpdateMessage": MessageLookupByLibrary.simpleMessage(
      "A new version of Kazi is available. Please update to keep using the app.",
    ),
    "forcedUpdateTitle": MessageLookupByLibrary.simpleMessage(
      "Update required",
    ),
    "forgotPassword": MessageLookupByLibrary.simpleMessage("Forgot Password"),
    "forgotPasswordConfirmation1": MessageLookupByLibrary.simpleMessage(
      "We have sent an email to ",
    ),
    "forgotPasswordConfirmation2": MessageLookupByLibrary.simpleMessage(
      " to recover your password. Once you receive the email, follow the link provided to sign in.",
    ),
    "forgotPasswordInfo": MessageLookupByLibrary.simpleMessage(
      "Please, enter your email address to receive a link to reset your password.",
    ),
    "forgotYourPassword": MessageLookupByLibrary.simpleMessage(
      "Forgot your password?",
    ),
    "fortnight": MessageLookupByLibrary.simpleMessage("Fortnight"),
    "freeLimitAds": MessageLookupByLibrary.simpleMessage("With ads"),
    "freeLimitClients": m3,
    "freeLimitServices": m4,
    "freeLimitTypes": m5,
    "freePlan": MessageLookupByLibrary.simpleMessage("Free"),
    "fromTo": m6,
    "goPremium": MessageLookupByLibrary.simpleMessage("Go Premium"),
    "googleSignIn": MessageLookupByLibrary.simpleMessage("Sign in with Google"),
    "hi": m7,
    "home": MessageLookupByLibrary.simpleMessage("Home"),
    "inUse": m8,
    "invalidIntNumber": MessageLookupByLibrary.simpleMessage(
      "Please, inform a valid integer number",
    ),
    "invalidNumber": MessageLookupByLibrary.simpleMessage(
      "Please, inform a valid number",
    ),
    "invalidProperty": m9,
    "isEmpty": m10,
    "language": MessageLookupByLibrary.simpleMessage("Language"),
    "lastMonth": MessageLookupByLibrary.simpleMessage("Last Month"),
    "lastServices": MessageLookupByLibrary.simpleMessage("Last services"),
    "leaveApp": MessageLookupByLibrary.simpleMessage(
      "Do you really want to leave the app?",
    ),
    "lightMode": MessageLookupByLibrary.simpleMessage("Light Mode"),
    "limitReachedClientsTitle": MessageLookupByLibrary.simpleMessage(
      "You reached the client limit",
    ),
    "limitReachedServicesTitle": MessageLookupByLibrary.simpleMessage(
      "You reached this month\'s service limit",
    ),
    "limitReachedSubtitle": MessageLookupByLibrary.simpleMessage(
      "Go Premium to keep adding without limits.",
    ),
    "limitReachedTypesTitle": MessageLookupByLibrary.simpleMessage(
      "You reached the service type limit",
    ),
    "logout": MessageLookupByLibrary.simpleMessage("Logout"),
    "logoutConfirmation": MessageLookupByLibrary.simpleMessage(
      "Do you really want to logout?",
    ),
    "managePlan": MessageLookupByLibrary.simpleMessage("Manage plan"),
    "month": MessageLookupByLibrary.simpleMessage("Month"),
    "myBalance": MessageLookupByLibrary.simpleMessage("My balance"),
    "name": MessageLookupByLibrary.simpleMessage("Name"),
    "newClient": MessageLookupByLibrary.simpleMessage("New Client"),
    "newPassword": MessageLookupByLibrary.simpleMessage("New Password"),
    "newService": MessageLookupByLibrary.simpleMessage("New service"),
    "newServiceType": MessageLookupByLibrary.simpleMessage("New Service Type"),
    "newType": MessageLookupByLibrary.simpleMessage("New Type"),
    "next": MessageLookupByLibrary.simpleMessage("Next"),
    "noClientsFound": MessageLookupByLibrary.simpleMessage("No clients found"),
    "noResults": MessageLookupByLibrary.simpleMessage("No results"),
    "noServiceTypes": MessageLookupByLibrary.simpleMessage(
      "It seems you don\'t have any service type registered yet, click on the button above to register a new one.",
    ),
    "noServices": MessageLookupByLibrary.simpleMessage(
      "It seems you don\'t have any service registered yet, click on the button above to register a new one.\n\nRemember, by default this screen shows the services you made this month. Try changing the filters above to see different dates.",
    ),
    "noServicesHome": MessageLookupByLibrary.simpleMessage(
      "It seems you don\'t have any service registered today yet, click on the button above to register a new one.\n\nRemember, this screen shows only the services that you made today. Go to the services page to see other dates.",
    ),
    "noServicesYet": MessageLookupByLibrary.simpleMessage("No services yet"),
    "numberBiggerThan100": MessageLookupByLibrary.simpleMessage(
      "Please, inform a number equal or lesser than 100",
    ),
    "numberLesserThanZero": MessageLookupByLibrary.simpleMessage(
      "Please, inform a number equal or greater than 0",
    ),
    "onboardingFeaturesSubtitle": MessageLookupByLibrary.simpleMessage(
      "Track your services, types and clients with ease.",
    ),
    "onboardingFeaturesTitle": MessageLookupByLibrary.simpleMessage(
      "Everything in one place",
    ),
    "onboardingGetStarted": MessageLookupByLibrary.simpleMessage("Get started"),
    "onboardingPlansSubtitle": MessageLookupByLibrary.simpleMessage(
      "Start free. Upgrade anytime to remove limits and ads.",
    ),
    "onboardingPlansTitle": MessageLookupByLibrary.simpleMessage(
      "Free or Premium",
    ),
    "onboardingSubtitle": MessageLookupByLibrary.simpleMessage(
      "This smart tool is designed to help you better manage your services.",
    ),
    "onboardingTitle1": MessageLookupByLibrary.simpleMessage(
      "Calculate the\nearnings from ",
    ),
    "onboardingTitle2": MessageLookupByLibrary.simpleMessage("your\nservices"),
    "optional": MessageLookupByLibrary.simpleMessage("optional"),
    "optionalUpdateMessage": MessageLookupByLibrary.simpleMessage(
      "A new version of Kazi is available with improvements. Would you like to update now?",
    ),
    "optionalUpdateTitle": MessageLookupByLibrary.simpleMessage(
      "Update available",
    ),
    "or": MessageLookupByLibrary.simpleMessage("or"),
    "orderAlphabetical": MessageLookupByLibrary.simpleMessage("Alphabetical"),
    "orderBy": MessageLookupByLibrary.simpleMessage("Order by"),
    "orderDateAsc": MessageLookupByLibrary.simpleMessage(
      "Least current to most current",
    ),
    "orderDateDesc": MessageLookupByLibrary.simpleMessage(
      "Most current to least current",
    ),
    "orderValueAsc": MessageLookupByLibrary.simpleMessage("Lowest to highest"),
    "orderValueDesc": MessageLookupByLibrary.simpleMessage("Highest to lowest"),
    "password": MessageLookupByLibrary.simpleMessage("Password"),
    "paywallPricePerMonth": m11,
    "paywallRenewInfo": MessageLookupByLibrary.simpleMessage(
      "Auto-renews monthly. Cancel anytime.",
    ),
    "paywallRestore": MessageLookupByLibrary.simpleMessage("Restore purchase"),
    "paywallStartTrial": MessageLookupByLibrary.simpleMessage(
      "Start 7-day free trial",
    ),
    "paywallSubscribe": MessageLookupByLibrary.simpleMessage("Subscribe"),
    "paywallSubtitle": MessageLookupByLibrary.simpleMessage(
      "Remove every limit and all ads.",
    ),
    "paywallTitle": MessageLookupByLibrary.simpleMessage("Unlock Kazi Premium"),
    "paywallTrialThenPrice": m12,
    "period": MessageLookupByLibrary.simpleMessage("Period"),
    "phone": MessageLookupByLibrary.simpleMessage("Phone"),
    "planComparisonTitle": MessageLookupByLibrary.simpleMessage(
      "Free vs Premium",
    ),
    "premiumPlan": MessageLookupByLibrary.simpleMessage("Premium"),
    "premiumUnlimited": MessageLookupByLibrary.simpleMessage(
      "Everything unlimited, no ads",
    ),
    "pricayPoliceLinks": MessageLookupByLibrary.simpleMessage(
      "This Service may contain links to other sites. If you click on a third-party link, you will be directed to that site. Note that these external sites are not operated by me. Therefore, I strongly advise you to review the Privacy Policy of these websites. I have no control over and assume no responsibility for the content, privacy policies, or practices of any third-party sites or services.",
    ),
    "pricayPoliceLinksTitle": MessageLookupByLibrary.simpleMessage(
      "Links to Other Sites",
    ),
    "privacyPolice": MessageLookupByLibrary.simpleMessage("Privacy Police"),
    "privacyPoliceChanges": MessageLookupByLibrary.simpleMessage(
      "I may update our Privacy Policy from time to time. Thus, you are advised to review this page periodically for any changes. I will notify you of any changes by posting the new Privacy Policy on this page.\nThis policy is effective as of 2023-05-26.",
    ),
    "privacyPoliceChangesTitle": MessageLookupByLibrary.simpleMessage(
      "Changes to This Privacy Policy",
    ),
    "privacyPoliceChildren": MessageLookupByLibrary.simpleMessage(
      "These Services do not address anyone under the age of 13. I do not knowingly collect personally identifiable information from children under 13 years of age. In the case I discover that a child under 13 has provided me with personal information, I immediately delete this from our servers. If you are a parent or guardian and you are aware that your child has provided us with personal information, please contact me so that I will be able to do the necessary actions.",
    ),
    "privacyPoliceChildrenTitle": MessageLookupByLibrary.simpleMessage(
      "Children’s Privacy",
    ),
    "privacyPoliceContact": MessageLookupByLibrary.simpleMessage(
      "If you have any questions or suggestions about my Privacy Policy, do not hesitate to contact me at ",
    ),
    "privacyPoliceContactTitle": MessageLookupByLibrary.simpleMessage(
      "Contact Us",
    ),
    "privacyPoliceCookies": MessageLookupByLibrary.simpleMessage(
      "Cookies are files with a small amount of data that are commonly used as anonymous unique identifiers. These are sent to your browser from the websites that you visit and are stored on your device\'s internal memory.\nThis Service does not use these “cookies” explicitly. However, the app may use third-party code and libraries that use “cookies” to collect information and improve their services. You have the option to either accept or refuse these cookies and know when a cookie is being sent to your device. If you choose to refuse our cookies, you may not be able to use some portions of this Service.",
    ),
    "privacyPoliceCookiesTitle": MessageLookupByLibrary.simpleMessage(
      "Cookies",
    ),
    "privacyPoliceEnd": MessageLookupByLibrary.simpleMessage(
      "This privacy policy page was created at privacypolicytemplate.net and modified/generated by App Privacy Policy Generator",
    ),
    "privacyPoliceInformation": MessageLookupByLibrary.simpleMessage(
      "For a better experience, while using our Service, I may require you to provide us with certain personally identifiable information, including but not limited to Name, Email Address. The information that I request will be retained on your device and is not collected by me in any way.\nThe app does use third-party services that may collect information used to identify you.\nLink to the privacy policy of third-party service providers used by the app:\n",
    ),
    "privacyPoliceInformation1": MessageLookupByLibrary.simpleMessage(
      "Google Play Services",
    ),
    "privacyPoliceInformation2": MessageLookupByLibrary.simpleMessage("AdMob"),
    "privacyPoliceInformation3": MessageLookupByLibrary.simpleMessage(
      "Google Analytics",
    ),
    "privacyPoliceInformation4": MessageLookupByLibrary.simpleMessage(
      "Firebase Crashlytics",
    ),
    "privacyPoliceInformationTitle": MessageLookupByLibrary.simpleMessage(
      "Information Collection and Use",
    ),
    "privacyPoliceLogData": MessageLookupByLibrary.simpleMessage(
      "I want to inform you that whenever you use my Service, in a case of an error in the app I collect data and information (through third-party products) on your phone called Log Data. This Log Data may include information such as your device Internet Protocol (“IP”) address, device name, operating system version, the configuration of the app when utilizing my Service, the time and date of your use of the Service, and other statistics.",
    ),
    "privacyPoliceLogDataTitle": MessageLookupByLibrary.simpleMessage(
      "Log Data",
    ),
    "privacyPoliceSecurity": MessageLookupByLibrary.simpleMessage(
      "I value your trust in providing us your Personal Information, thus we are striving to use commercially acceptable means of protecting it. But remember that no method of transmission over the internet, or method of electronic storage is 100% secure and reliable, and I cannot guarantee its absolute security.",
    ),
    "privacyPoliceSecurityTitle": MessageLookupByLibrary.simpleMessage(
      "Security",
    ),
    "privacyPoliceServices": MessageLookupByLibrary.simpleMessage(
      "I may employ third-party companies and individuals due to the following reasons:\n\nTo facilitate our Service;\nTo provide the Service on our behalf;\nTo perform Service-related services; or\nTo assist us in analyzing how our Service is used.\nI want to inform users of this Service that these third parties have access to their Personal Information. The reason is to perform the tasks assigned to them on our behalf. However, they are obligated not to disclose or use the information for any other purpose.",
    ),
    "privacyPoliceServicesTitle": MessageLookupByLibrary.simpleMessage(
      "Service Providers",
    ),
    "privacyPoliceStart": MessageLookupByLibrary.simpleMessage(
      "Lucas Guimarães built the Kazi app as an Ad Supported app. This SERVICE is provided by Lucas Guimarães at no cost and is intended for use as is.\nThis page is used to inform visitors regarding my policies with the collection, use, and disclosure of Personal Information if anyone decided to use my Service.\nIf you choose to use my Service, then you agree to the collection and use of information in relation to this policy. The Personal Information that I collect is used for providing and improving the Service. I will not use or share your information with anyone except as described in this Privacy Policy.\nThe terms used in this Privacy Policy have the same meanings as in our Terms and Conditions, which are accessible at Kazi unless otherwise defined in this Privacy Policy.",
    ),
    "profile": MessageLookupByLibrary.simpleMessage("Profile"),
    "quantity": MessageLookupByLibrary.simpleMessage("Quantity"),
    "rateApp": MessageLookupByLibrary.simpleMessage("Rate the app"),
    "removeFilters": MessageLookupByLibrary.simpleMessage("Remove filters"),
    "requiredProperty": m13,
    "resendEmail": MessageLookupByLibrary.simpleMessage("Resend Email"),
    "resetedPassword": MessageLookupByLibrary.simpleMessage(
      "Password reseted successfully",
    ),
    "role": MessageLookupByLibrary.simpleMessage("Role"),
    "save": MessageLookupByLibrary.simpleMessage("Save"),
    "saveService": MessageLookupByLibrary.simpleMessage("Save Service"),
    "saveType": MessageLookupByLibrary.simpleMessage("Save Type"),
    "search": MessageLookupByLibrary.simpleMessage("Search"),
    "searchByName": MessageLookupByLibrary.simpleMessage("Search by name"),
    "selectClient": MessageLookupByLibrary.simpleMessage("Select the client"),
    "selectCurrency": MessageLookupByLibrary.simpleMessage("Select a currency"),
    "selectServiceType": MessageLookupByLibrary.simpleMessage(
      "Select the service type",
    ),
    "sendEmail": MessageLookupByLibrary.simpleMessage("Send Email"),
    "service": MessageLookupByLibrary.simpleMessage("Service"),
    "serviceAdded": MessageLookupByLibrary.simpleMessage(
      "Service added successfully",
    ),
    "serviceDeleted": MessageLookupByLibrary.simpleMessage(
      "Service deleted successfully",
    ),
    "serviceType": MessageLookupByLibrary.simpleMessage("Service Type"),
    "serviceTypes": MessageLookupByLibrary.simpleMessage("Service Types"),
    "serviceUpdated": MessageLookupByLibrary.simpleMessage(
      "Service updated successfully",
    ),
    "serviceValue": MessageLookupByLibrary.simpleMessage("Service Value"),
    "services": MessageLookupByLibrary.simpleMessage("Services"),
    "settings": MessageLookupByLibrary.simpleMessage("Settings"),
    "share": MessageLookupByLibrary.simpleMessage("Share"),
    "signIn": MessageLookupByLibrary.simpleMessage("Sign In"),
    "signUp": MessageLookupByLibrary.simpleMessage("Sign Up"),
    "signUpSuccess": MessageLookupByLibrary.simpleMessage(
      "Account created successfully",
    ),
    "skip": MessageLookupByLibrary.simpleMessage("Skip"),
    "success": MessageLookupByLibrary.simpleMessage("Action done successfully"),
    "thisClient": MessageLookupByLibrary.simpleMessage("this client"),
    "thisService": MessageLookupByLibrary.simpleMessage("this service"),
    "today": MessageLookupByLibrary.simpleMessage("Today"),
    "total": MessageLookupByLibrary.simpleMessage("Total value"),
    "totalReceived": MessageLookupByLibrary.simpleMessage("Total received"),
    "tourAppBarDescription": MessageLookupByLibrary.simpleMessage(
      "Here you can register the types of services you perform and log out of your account.",
    ),
    "tourAppBarTitle": MessageLookupByLibrary.simpleMessage("Perfil Area"),
    "tourBottomNavigationServicesDescription": MessageLookupByLibrary.simpleMessage(
      "In this menu you will find all the services you have performed, and also being able to register a new service.",
    ),
    "tourBottomNavigationServicesTitle": MessageLookupByLibrary.simpleMessage(
      "Services Area",
    ),
    "tourHomeBalanceDescription": MessageLookupByLibrary.simpleMessage(
      "Here your daily earnings are displayed, also the total discount and the total received.",
    ),
    "tourHomeBalanceTitle": MessageLookupByLibrary.simpleMessage("Balance"),
    "tourHomeServicesDescription": MessageLookupByLibrary.simpleMessage(
      "These are the services you performed today.",
    ),
    "tourHomeServicesTitle": MessageLookupByLibrary.simpleMessage(
      "Daily Services",
    ),
    "tourProfileDescription": MessageLookupByLibrary.simpleMessage(
      "Here you will find some actions available, including the one to register a new type of service. The service type allows you to easily identify a service provided.",
    ),
    "tourProfileTitle": MessageLookupByLibrary.simpleMessage("Actions"),
    "tourServiceDetailsDescription": MessageLookupByLibrary.simpleMessage(
      "You can click in the services to see all the information, update or delete it.",
    ),
    "tourServiceDetailsTitle": MessageLookupByLibrary.simpleMessage(
      "Service Details",
    ),
    "tourServiceTypesDescription": MessageLookupByLibrary.simpleMessage(
      "This information will help you to easily register the services you will perform. You can give a name, such as \"Lashes - Brazilian Volume\", fill in the default value, and if applicable, the percentage that is normally deducted from this service.",
    ),
    "tourServiceTypesTitle": MessageLookupByLibrary.simpleMessage(
      "Service Type",
    ),
    "tourServicesForm1Description": MessageLookupByLibrary.simpleMessage(
      "To register a new service provided, first select one of the types of service that you previously registered and the values will be filled in automatically according to the data of that type of service. If you wish, you can change the values for that specific service.",
    ),
    "tourServicesForm1Title": MessageLookupByLibrary.simpleMessage(
      "New Service",
    ),
    "tourServicesForm2Description": MessageLookupByLibrary.simpleMessage(
      "Just select the date and the number of services performed, and fill in a description or note if you wish.",
    ),
    "tourServicesForm2Title": MessageLookupByLibrary.simpleMessage(
      "New Service",
    ),
    "tourServicesInfoDescription": MessageLookupByLibrary.simpleMessage(
      "Here you can filter and sort your services and view the balance for the selected period. You can also register performed services.",
    ),
    "tourServicesInfoTitle": MessageLookupByLibrary.simpleMessage("Services"),
    "tourServicesListDescription": MessageLookupByLibrary.simpleMessage(
      "These are all the jobs you\'ve provided in a given period of time. By default you will see all the services for the current month.",
    ),
    "tourServicesListTitle": MessageLookupByLibrary.simpleMessage("Services"),
    "updateLater": MessageLookupByLibrary.simpleMessage("Later"),
    "updateNow": MessageLookupByLibrary.simpleMessage("Update"),
    "updatePassword": MessageLookupByLibrary.simpleMessage("Update Password"),
    "userTermsAlert1": MessageLookupByLibrary.simpleMessage(
      "By continuing, you agree to the ",
    ),
    "userTermsAlert2": MessageLookupByLibrary.simpleMessage(
      "Terms of Service ",
    ),
    "userTermsAlert3": MessageLookupByLibrary.simpleMessage(
      "and confirm that you have read our ",
    ),
    "userTermsAlert4": MessageLookupByLibrary.simpleMessage("Privacy Policy"),
    "validatorConfirmPassword": MessageLookupByLibrary.simpleMessage(
      "Passwords don\'t match",
    ),
    "validatorEmail": MessageLookupByLibrary.simpleMessage(
      "Email is invalid or badly formatted",
    ),
    "validatorPassword": MessageLookupByLibrary.simpleMessage(
      "Your password must have a minimum of 8 characters and a maximum of 16",
    ),
    "week": MessageLookupByLibrary.simpleMessage("Week"),
    "wouldYouLikeDelete": m14,
    "yesterday": MessageLookupByLibrary.simpleMessage("Yesterday"),
    "yourEarnings": MessageLookupByLibrary.simpleMessage("Your Earnings Today"),
  };
}
