import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController extends GetxController {
  final language = 'en'.obs;
  final weightUnit = 'kg'.obs;
  final onboardingDone = false.obs;
  final restDefault = 60.obs;

  late SharedPreferences _prefs;

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    language.value = _prefs.getString('language') ?? 'en';
    weightUnit.value = _prefs.getString('unit') ?? 'kg';
    onboardingDone.value = _prefs.getBool('onboarding') ?? false;
    restDefault.value = _prefs.getInt('rest') ?? 60;
  }

  Future<void> setLanguage(String code) async {
    language.value = code;
    await _prefs.setString('language', code);
  }

  Future<void> setUnit(String unit) async {
    weightUnit.value = unit;
    await _prefs.setString('unit', unit);
  }

  Future<void> setRest(int seconds) async {
    restDefault.value = seconds;
    await _prefs.setInt('rest', seconds);
  }

  Future<void> completeOnboarding() async {
    onboardingDone.value = true;
    await _prefs.setBool('onboarding', true);
  }
}
