import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qme/api/kAPI.dart';
import 'package:qme/repository/user.dart';
import 'package:qme/router.dart' as router;
import 'package:qme/services/analytics.dart';
import 'package:qme/utilities/logger.dart';
import 'package:qme/views/home.dart';
import 'package:qme/views/introSlider.dart';
import 'package:qme/views/signin.dart';
import 'package:qme/widgets/theme.dart';

String initialHome = SignInScreen.id;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Logger.level = Level.warning;
  // TODO show splash screen
  // TODO setConfigs();
  // TODO fetch user related information
//  setSession();
//  clearSession();
  if (await UserRepository().isSessionReady()) {
    initialHome = IntroScreen.id;
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static FirebaseAnalytics analytics = FirebaseAnalytics();
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return MaterialApp(
      theme: myTheme,
      debugShowCheckedModeBanner: false,
      onGenerateRoute: router.generateRoute,
      initialRoute: initialHome,
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
  logger.d("value of firebase config: ${remoteConfig.getString('apiBaseUrl')}");
  logger.i("before: $baseURL");
  baseURL = remoteConfig.getString('apiBaseUrl');
  logger.e("after: $baseURL");
  return MyApp();
}
