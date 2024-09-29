import 'package:shared_preferences/shared_preferences.dart';

Future<String> getAccessToken() async {
  final prefs = await SharedPreferences.getInstance();
  final accessToken = prefs.getString('access_token');
  if (accessToken != null) {
    return accessToken;
  } else {
    return 'error';
  }
}
