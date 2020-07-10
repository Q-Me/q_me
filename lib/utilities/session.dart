import 'package:qme/model/user.dart';
import 'package:qme/repository/user.dart';

void setSession() async {
  final Map<String, dynamic> signInResponse = await UserRepository().signIn({
    "phone": "+919673582517",
    "password": "P1yush.123",
  });
  print('SignIn session: ${signInResponse.toString()}');
  await storeUserData(UserData.fromJson(signInResponse));
}

void test() async {
  setSession();
  UserData userData = await getUserDataFromStorage();
  print(userData.toJson());
}
