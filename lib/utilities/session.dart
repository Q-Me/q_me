import 'package:hive/hive.dart';
import 'package:qme/model/user.dart';
import 'package:qme/repository/user.dart';
import 'package:qme/utilities/logger.dart';

Future<void> setSession() async {
  final Map<String, dynamic> signInResponse = await UserRepository().signIn({
    "phone": "+919673582517",
    "password": "P1yush.123",
  });
  await storeUserData(UserData.fromJson(signInResponse));
  logger.i('SignIn session: ${signInResponse.toString()}');
}

Future<void> clearSession() async {
  Box box = await Hive.openBox("user");
  await box.clear();
  Box indexBox = await Hive.openBox("index");
  await indexBox.clear();
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
