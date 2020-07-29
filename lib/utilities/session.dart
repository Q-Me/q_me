import 'package:qme/model/user.dart';
import 'package:qme/repository/user.dart';
import 'package:qme/utilities/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

void setSession() async {
  final Map<String, dynamic> signInResponse = await UserRepository().signIn({
    "phone": "+919673582517",
    "password": "P1yush.123",
  });
  await storeUserData(UserData.fromJson(signInResponse));
  logger.i('SignIn session: ${signInResponse.toString()}');
}

void clearSession() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.clear();
}

void setSessionFromRefreshToken() async {
  final signInResponse = await UserRepository().accessTokenFromApi();
  logger.i('SignIn session: ${signInResponse.toString()}');
}

void test() async {
  setSession();
  UserData userData = await getUserDataFromStorage();
  print(userData.toJson());
}
