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
}
