import 'dart:async';
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:hive/hive.dart';
import 'package:qme/api/app_exceptions.dart';
import 'package:qme/model/api_params/login.dart';
import 'package:qme/model/api_params/signup.dart';
import 'package:qme/model/appointment.dart';
import 'package:qme/model/location.dart';
import 'package:qme/utilities/logger.dart';
import 'package:qme/utilities/session.dart';

import '../api/base_helper.dart';
import '../api/endpoints.dart';
import '../model/user.dart';

Future<void> setGuestSession(Map<String, dynamic> response) async {
  Box login = await Hive.openBox("firstLogin");
  UserData userData = getUserDataFromStorage();
  userData.id = response['id'].toString();
  userData.name = response['name'];
  userData.isGuest = true;
  userData.accessToken = response['accessToken'];
  userData.expiry = DateTime.now().add(Duration(days: 1));
  updateUserData(userData);
  await login.put('firstLogin', false);
}

void clearGuestSession() {
  UserData user = getUserDataFromStorage();
  user.delete();
}

class UserRepository {
  ApiBaseHelper _helper = ApiBaseHelper();

  Future<Map<String, dynamic>> guestLogin() async {
    Map<String, dynamic> response = await _helper.post('/user/guestlogin');
    await setGuestSession(response);
    return response;
  }

  Future<UserData> fetchProfile() async {
    final String accessToken = getAccessTokenFromStorage();
    final response = await _helper.post(kProfile,
        headers: {HttpHeaders.authorizationHeader: bearerToken(accessToken)});
    final userData = UserData(
      name: response["name"],
      phone: response["phone"],
      email: response["email"],
    );
    updateUserData(userData);
    return userData;
  }

  Future<String> accessTokenFromApi() async {
    final UserData userData = getUserDataFromStorage();
    final response = await _helper.post(
      kAccessToken,
      req: {"refreshToken": userData.refreshToken},
    );
    updateUserData(UserData.fromJson(response));
    return response['accessToken'];
  }

  Future<String> signUp(SignUpParams params) async {
    final Map<String, dynamic> response =
        await _helper.post(kSignUp, req: params.json);
    return response["msg"];
  }

  Future<String> signOut() async {
    final String token = getAccessTokenFromStorage();
    final response = await _helper.post(
      kSignOut,
      headers: {HttpHeaders.authorizationHeader: bearerToken(token)},
    );
    await clearSession();
    return response["msg"];
  }

  Future<UserData> signIn(LoginWithPasswordParams params) async {
    final response = await _helper.post(
      kSignIn,
      req: params.json,
    );
    UserData user = UserData.fromJson(response);
    user.isGuest = false;
    updateUserData(user);
    return user;
  }

  Future<UserData> signInWithPassword(
      String phoneNumber, String password) async {
    final response = await _helper.post(
      signInPasswordUrl,
      req: {
        'phone': phoneNumber,
        'password': password,
      },
    );
    UserData user = UserData.fromJson(response);
    user.isGuest = false;
    updateUserData(user);
    return user;
  }

  Future<UserData> signInWithOtp(String idToken) async {
    final response = await _helper.post(signInOtpUrl, req: {'token': idToken});
    UserData user = UserData.fromJson(response);
    user.isGuest = false;
    updateUserData(user);
    return user;
  }

  Future<String> fcmTokenSubmit(String fcmToken) async {
    final String accessToken = getAccessTokenFromStorage();
    // Box box = await hive.openbox("user");
    final response = await _helper.post(
      fcmUrl,
      req: {"token": fcmToken},
      authToken: accessToken,
    );

    final msg = response["msg"];
    final user = getUserDataFromStorage();
    user.fcmToken = msg;
    updateUserData(user);

    return msg;
  }

  Future<List<Appointment>> fetchAppointments(List<String> status) async {
    final String accessToken = getAccessTokenFromStorage();
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
    // Box box = await hive.openbox("user");
    try {
      if (!await isUserDataInStorage()) {
        return false;
      }
      UserData user = getUserDataFromStorage();
      final expiry = user.expiry; // final expiry = await box.get('expiry');
      final refreshToken = user
          .refreshToken; // final refreshToken = await box.get('refreshToken');
      final accessToken =
          user.accessToken; // final accessToken = await box.get('accessToken');
      if (expiry != null &&
          DateTime.now().isBefore(expiry) &&
          accessToken != null) {
        // accessToken is valid
        return true;
      } else {
        // invalid accessToken
        if (refreshToken != null) {
          if (user.isGuest) {
            return await sessionGuestLoginAttempt();
          }
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
            logger
                .e('Getting new accessToken from API failed\n' + e.toString());
            return false;
          }
        } else {
          return false;
        }
      }
    } catch (e) {
      logger.e(e.toString());
      return false;
    }
  }

  Future<bool> sessionGuestLoginAttempt() async {
    try {
      final response = await guestLogin();
      logger.d(response);
      return true;
    } catch (e) {
      logger.e(e.toString());
      // box.clear();
      return false;
    }
  }

  Future<bool> updateUserLocation(LocationData location) async {
    try {
      final String _accessToken = getAccessTokenFromStorage();
      await _helper.post(
        "/user/location",
        req: {
          "longitude": "${location.longitude}",
          "latitude": "${location.latitude}"
        },
        authToken: _accessToken,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Duration> getDelayFromApi() async {
    try {
      final String accessToken = getAccessTokenFromStorage();
      Map<String, String> response = await _helper.post(
        "/user/slot/cooldown",
        authToken: accessToken,
      );
      return Duration(minutes: int.parse(response["time"]));
    } catch (e) {
      logger.e(e.toString());
      return Duration(hours: 6);
    }
  }
}
