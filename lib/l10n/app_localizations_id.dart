// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'BuangYuk';

  @override
  String get loginTitle => 'Masuk ke Akun Anda';

  @override
  String get loginSubtitle => 'Selamat datang kembali di BuangYuk!';

  @override
  String get emailLabel => 'Alamat Email';

  @override
  String get passwordLabel => 'Kata Sandi';

  @override
  String get loginButton => 'Masuk';

  @override
  String get registerPrompt => 'Belum punya akun?';

  @override
  String get registerLink => 'Daftar Sekarang';
}
