import 'package:shared_preferences/shared_preferences.dart';

class SimplePreferences {
  static SharedPreferences preferences;

static const _menu = 'trainingMenu';

  static Future init() async =>
      preferences = await SharedPreferences.getInstance();

  static Future setMenu(List<String> trainingMenu) async =>
      await preferences.setStringList(_menu, trainingMenu);

  static List<String> getMenu() => preferences.getStringList(_menu);


}