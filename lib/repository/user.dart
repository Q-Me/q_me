import '../model/user.dart';
import '../api/base_helper.dart';
import '../api/endpoints.dart';

class UserRepository {
  ApiBaseHelper _helper = ApiBaseHelper();

  Future<UserData> fetchProfile() async {
    final UserData userData = await getUserDataFromStorage();
    dynamic response = await _helper.post(kProfile,
        headers: {'Authorization': 'Bearer ${userData.accessToken}'});
    return UserData.fromJson(response);
  }

  void fetchAccessToken() async {
    final UserData userData = await getUserDataFromStorage();
    final response = await _helper.post(kAccessToken,
        headers: {'Authorization': 'Bearer ${userData.refreshToken}'});
    storeUserData(UserData.fromJson(response));
    return response['accessToken'];
  }

  Future<Map<String, dynamic>> signUp(Map<String, String> formData) async {
    final response = await _helper.post(kSignUp, req: formData);
    return response;
  }

  Future<Map<String, dynamic>> signIn(Map<String, String> formData) async {
    final response = await _helper.post(kSignIn, req: formData);
    await storeUserData(UserData.fromJson(response));

    return response;
  }
}
