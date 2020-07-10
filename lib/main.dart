import 'dart:developer';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:qme/api/kAPI.dart';
import 'package:qme/repository/user.dart';
import 'package:qme/router.dart' as router;
import 'package:qme/services/analytics.dart';
import 'package:qme/views/home.dart';
import 'package:qme/views/signin.dart';

String initialHome = SignInScreen.id;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
//  setSession();
  if (await UserRepository().isSessionReady()) {
    initialHome = HomeScreen.id;
  }
  runApp(FutureBuilder<RemoteConfig>(
    future: setupRemoteConfig(),
    builder: (BuildContext context, AsyncSnapshot<RemoteConfig> snapshot) {
      return snapshot.hasData ? SettingValue(snapshot.data) : MyApp();
    },
  ));
}

class MyApp extends StatelessWidget {
  static FirebaseAnalytics analytics = FirebaseAnalytics();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light().copyWith(primaryColor: Colors.green),
      debugShowCheckedModeBanner: false,
      onGenerateRoute: router.generateRoute,
      initialRoute: SignInScreen.id,
      navigatorObservers: <NavigatorObserver>[
        AnalyticsService().getAnalyticsObserver(),
      ],
    );
  }
}

Future<RemoteConfig> setupRemoteConfig() async {
  final RemoteConfig remoteConfig = await RemoteConfig.instance;
  final defaults = <String, dynamic>{'apiBaseUrl': 'default welcome'};
  await remoteConfig.setDefaults(defaults);
  await remoteConfig.fetch(expiration: const Duration(hours: 5));
  await remoteConfig.activateFetched();
  remoteConfig.setConfigSettings(RemoteConfigSettings(debugMode: true));
  return remoteConfig;
}

Widget SettingValue(RemoteConfig remoteConfig) {
  log("value of firebase config: ${remoteConfig.getString('apiBaseUrl')}");
  log("before: $baseURL");
  baseURL = remoteConfig.getString('apiBaseUrl');
  log("after: $baseURL");
  return MyApp();
}
