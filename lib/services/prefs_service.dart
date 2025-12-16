import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  static const String keyPrivacyReadV1 = 'privacy_read_v1';
  static const String keyTermsReadV1 = 'terms_read_v1';
  static const String keyPoliciesVersionAccepted = 'policies_version_accepted';
  static const String keyAcceptedAt = 'accepted_at';
  static const String keyOnboardingCompleted = 'onboarding_completed';
  static const _darkModeKey = 'dark_mode_enabled';
  static const _loggedInKey = 'logged_in';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Helpers genéricos (novo) — usados pelo AvatarService
  String? getString(String key) => _prefs.getString(key);

  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  // Tema
  bool isDarkMode() => _prefs.getBool(_darkModeKey) ?? false;

  Future<void> setDarkMode(bool value) async {
    await _prefs.setBool(_darkModeKey, value);
  }

  // Login flag (do seu app)
  bool isLoggedIn() => _prefs.getBool(_loggedInKey) ?? false;

  Future<void> setLoggedIn(bool value) async {
    await _prefs.setBool(_loggedInKey, value);
  }

  // Onboarding
  bool get onboardingCompleted =>
      _prefs.getBool(keyOnboardingCompleted) ?? false;

  Future<void> setOnboardingCompleted(bool value) async {
    await _prefs.setBool(keyOnboardingCompleted, value);
  }

  // Políticas
  String? get policiesVersionAccepted =>
      _prefs.getString(keyPoliciesVersionAccepted);

  Future<void> setPoliciesAccepted(String version) async {
    await _prefs.setString(keyPoliciesVersionAccepted, version);
    await _prefs.setString(keyAcceptedAt, DateTime.now().toIso8601String());
  }

  bool get privacyReadV1 => _prefs.getBool(keyPrivacyReadV1) ?? false;
  bool get termsReadV1 => _prefs.getBool(keyTermsReadV1) ?? false;

  Future<void> setPrivacyReadV1(bool value) async {
    await _prefs.setBool(keyPrivacyReadV1, value);
  }

  Future<void> setTermsReadV1(bool value) async {
    await _prefs.setBool(keyTermsReadV1, value);
  }

  Future<void> clearConsent() async {
    await _prefs.remove(keyPrivacyReadV1);
    await _prefs.remove(keyTermsReadV1);
    await _prefs.remove(keyPoliciesVersionAccepted);
    await _prefs.remove(keyAcceptedAt);
    await _prefs.remove(keyOnboardingCompleted);
  }

  Future<void> clearLegalData() async {
    await _prefs.remove('privacy_read_v1');
    await _prefs.remove('terms_read_v1');
    await _prefs.remove('policies_version_accepted');
    await _prefs.remove('accepted_at');
    await _prefs.remove('onboarding_completed');
  }
}
