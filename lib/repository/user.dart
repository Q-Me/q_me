import 'dart:async';
import 'dart:io';

import 'package:qme/model/appointment.dart';
import 'package:qme/utilities/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/base_helper.dart';
import '../api/endpoints.dart';
import '../model/user.dart';

class UserRepository {
  ApiBaseHelper _helper = ApiBaseHelper();

  Future<UserData> fetchProfile(String accessToken) async {
    final response = await _helper.post(kProfile,
        headers: {HttpHeaders.authorizationHeader: bearerToken(accessToken)});
    return UserData(
      name: response["name"],
      phone: response["phone"],
      email: response["email"],
    );
  }

  Future<String> accessTokenFromApi() async {
    final UserData userData = await getUserDataFromStorage();
    final response = await _helper.post(
      kAccessToken,
      headers: {
        HttpHeaders.authorizationHeader: bearerToken(userData.refreshToken)
      },
    );
    await storeUserData(UserData.fromJson(response));
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

  Future<List<Appointment>> fetchAppointments(List<String> status) async {
    final String accessToken = await getAccessTokenFromStorage();
    final response = await _helper.post(
      '/user/slot/slots',
      req: {"status": status.length != 4 ? status : "ALL"},
      headers: {HttpHeaders.authorizationHeader: bearerToken(accessToken)},
    );
    List<Appointment> appointments = [];
    for (var map in response["slots"]) {
      appointments.add(Appointment.fromMap(Map.from(map)));
    }
    return appointments;
  }

  Future<bool> isSessionReady() async {
    // If the session is not ready then try to set the session and after
    // successful session set return true else return false
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final expiry = prefs.getString('expiry');
    final refreshToken = prefs.getString('refreshToken');
    final accessToken = prefs.getString('accessToken');
    logger.d(
        'In storage:\nexpiry:$expiry\nrefreshToken:$refreshToken\naccessToken:$accessToken');
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
        logger.i('new accessToken set to:$result');
        return result != '-1' ? true : false;
      } else {
        return false;
      }
    }
  }
}
