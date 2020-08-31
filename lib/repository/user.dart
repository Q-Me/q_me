import 'dart:async';
import 'dart:io';

import 'package:hive/hive.dart';
import 'package:qme/api/app_exceptions.dart';
import 'package:qme/model/appointment.dart';
import 'package:qme/utilities/logger.dart';

import '../api/base_helper.dart';
import '../api/endpoints.dart';
import '../model/user.dart';

class UserRepository {
  ApiBaseHelper _helper = ApiBaseHelper();

  Future<UserData> fetchProfile() async {
    final String accessToken = await getAccessTokenFromStorage();
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

  Future<Map> signInWithPassword(String phoneNumber, String password) async {
    final response = await _helper.post(
      signInPasswordUrl,
      req: {
        'phone': phoneNumber,
        'password': password,
      },
    );
    await storeUserData(UserData.fromJson(response));
    return response;
  }

  Future<Map> signInWithOtp(String idToken) async {
    final response = await _helper.post(signInOtpUrl, req: {'token': idToken});
    await storeUserData(UserData.fromJson(response));
    return response;
  }

  Future<String> fcmTokenSubmit(String fcmToken) async {
    final String accessToken = await getAccessTokenFromStorage();

    final response = await _helper.post(
      fcmUrl,
      req: {"token": fcmToken},
      authToken: accessToken,
    );

    final msg = response["msg"];
    Box box = await Hive.openBox("user");
    await box.put('fcmToken', msg);

    return msg;
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
    Box box = await Hive.openBox("user");
    final expiry = await box.get('expiry');
    final refreshToken = await box.get('refreshToken');
    final accessToken = await box.get('accessToken');
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
        try {
          // Get new accessToken from refreshToken
          final result = await accessTokenFromApi();
          logger.i('new accessToken set to:$result');
          return result != '-1' ? true : false;
        } on BadRequestException catch (e) {
          if (e.toMap()["error"] == "Invalid refresh token") {
            logger.e(e.toMap()["error"]);
          }
          return false;
        } catch (e) {
          logger.e('Getting new accessToken from API failed\n' + e.toString());
          return false;
        }
      } else {
        return false;
      }
    }
  }
}
