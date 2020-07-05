import 'dart:async';
import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';

import '../api/base_helper.dart';
import '../api/endpoints.dart';
import '../model/user.dart';

class UserRepository {
  ApiBaseHelper _helper = ApiBaseHelper();

  Future<UserData> fetchProfile() async {
    final UserData userData = await getUserDataFromStorage();
    dynamic response = await _helper.post(kProfile,
        headers: {'Authorization': 'Bearer ${userData.accessToken}'});
    return UserData.fromJson(response);
  }

  Future<String> accessTokenFromApi() async {
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

  Future<bool> isSessionReady() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final expiry = prefs.getString('expiry');
    final refreshToken = prefs.getString('refreshToken');
    final accessToken = prefs.getString('accessToken');
//    log('In storage:\nexpiry:$expiry\nrefreshToken:$refreshToken\naccessToken:$accessToken');
    if (expiry != null &&
        DateTime.now().isBefore(DateTime.parse(expiry)) &&
        accessToken != null) {
      // accessToken is valid
//      log('Token is valid');
      return true;
    } else {
      // invalid accessToken
      if (refreshToken != null) {
        // Get new accessToken from refreshToken
        final result = await accessTokenFromApi();
        log('new accessToken:$result');
        return result != '-1' ? true : false;
      } else {
        return false;
      }
    }
  }
}
