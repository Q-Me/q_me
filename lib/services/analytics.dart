import 'package:amplitude_flutter/amplitude.dart';
import 'package:amplitude_flutter/identify.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:qme/model/user.dart';
import 'package:qme/repository/user.dart';

class AnalyticsService {
  final Amplitude analytics =
      Amplitude.getInstance(instanceName: "user_analytics");
  final Identify identity = Identify();

  Future<void> initAnalytics() async {
    final RemoteConfig remoteConfig = await RemoteConfig.instance;
    await remoteConfig.fetch();
    await remoteConfig.activateFetched();
    analytics.init(remoteConfig.getString("amplitudeApiKey"));
    // final UserData userId = await UserRepository().fetchProfile();
    // if (userId.id == "IZ4lfmK5z") {
    //   analytics.setUserId("test_user");
    // } else {
    //   analytics.setUserId(userId.id);
    // }

    analytics.trackingSessionEvents(true);
    analytics.identify(identity);
  }

  void logEvent(String name, Map<String, dynamic> description) {
    updateUserProp();
    analytics.logEvent(name, eventProperties: description);
  }

  void updateUserProp({Map<String, dynamic> props}) {
    if (props == null) {
      props = getUserDataFromStorage().toCompleteJson();
    }
    props.forEach(
      (key, value) => identity.set(
        key,
        value.toString(),
      ),
    );
    analytics.identify(identity);
  }

  void removeUserProp({@required String key}) {
    identity.unset(key);
    analytics.identify(identity);
  }

  void setScreen(String screenId) {
    String route;
    UserData user = getUserDataFromStorage();
    if (user.isGuest == true) {
      route = "guest";
    } else if (user.isUser == true || user.isGuest == false) {
       route = "user";
    }
    analytics.logEvent("View Screen",eventProperties: {
      "Screen Id": screenId,
      "Source": "in_app",
      "Route": route,
    });
  }
}
