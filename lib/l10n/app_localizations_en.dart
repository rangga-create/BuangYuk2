// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'BuangYuk';

  @override
  String get loginTitle => 'Log In to Your Account';

  @override
  String get loginSubtitle => 'Welcome back to BuangYuk!';

  @override
  String get emailLabel => 'Email Address';

  @override
  String get passwordLabel => 'Password';

  @override
  String get loginButton => 'Log In';

  @override
  String get registerPrompt => 'Don\'t have an account?';

  @override
  String get registerLink => 'Register Now';
}
