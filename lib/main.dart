import 'package:flutter/material.dart';
import 'package:qme/api/kAPI.dart';
import 'package:qme/views/home.dart';
import 'views/profile.dart';
import 'views/nearby.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'services/analytics.dart';
import 'router.dart' as router;
import 'package:firebase_remote_config/firebase_remote_config.dart';

String initialHome = NearbyScreen.id;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
//  if (await UserRepository()).isSessionReady()) {
//  initialHome = QueuesScreen.id;
//  }
  runApp(
    FutureBuilder<RemoteConfig>(
        future: setupRemoteConfig(),
        builder: (BuildContext context, AsyncSnapshot<RemoteConfig> snapshot) {
          return snapshot.hasData ? SettingValue(snapshot.data) :  MyApp();
        },
      ) 
     );
}

class MyApp extends StatelessWidget {
  static FirebaseAnalytics analytics = FirebaseAnalytics();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light().copyWith(primaryColor: Colors.green),
      debugShowCheckedModeBanner: false,
      onGenerateRoute: router.generateRoute,
      initialRoute: HomeScreen.id,
      navigatorObservers: <NavigatorObserver>[
        AnalyticsService().getAnalyticsObserver(),
      ],
    );
  }
}

Future<RemoteConfig> setupRemoteConfig() async {
  final RemoteConfig remoteConfig = await RemoteConfig.instance;
  // Enable developer mode to relax fetch throttling
  remoteConfig.setConfigSettings(RemoteConfigSettings(debugMode: true));
  remoteConfig.setDefaults(<String, dynamic>{
    'apiBaseUrl': 'default welcome',
  });
  return remoteConfig;
}

Widget SettingValue(RemoteConfig remoteConfig) {
  print("value of fibrebase config: ${remoteConfig.getString('apiBaseUrl')}");
  print("before: $baseURL");
  baseURL = remoteConfig.getString('apiBaseUrl');
  print("after: $baseURL");
  return  MyApp();
}
