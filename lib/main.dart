import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
// import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:provider/provider.dart';
import 'package:qme/api/app_exceptions.dart';
import 'package:qme/api/kAPI.dart';
import 'package:qme/bloc/home_bloc/home_bloc.dart';
import 'package:qme/repository/user.dart';
import 'package:qme/router.dart' as router;
import 'package:qme/services/analytics.dart';
import 'package:qme/utilities/logger.dart';
import 'package:qme/views/home.dart';
import 'package:qme/views/initialScreen.dart';
import 'package:qme/views/signin.dart';
import 'package:qme/widgets/theme.dart';
import 'package:qme/utilities/location.dart';
import 'package:qme/views/noInternet.dart';
import 'package:qme/model/user.dart';

String initialHome = InitialScreen.id;
bool firstLogin;
Box indexOfHomeScreen;
Box notificationIndicator;

void main() async {
  // Bloc.observer = SimpleBlocObserver();
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp();
  AnalyticsService analytics;
  await analytics.initAnalytics();
  await initHive();
  if (firstLogin == false) initialHome = SignInScreen.id;

  // Logger.level = Level.warning;
  // TODO show splash screen
  // TODO setConfigs();
  // TODO fetch user related information
  try {
    if (await UserRepository().isSessionReady()) {
      initialHome = HomeScreen.id;
    }
  } on FetchDataException catch (e) {
    logger.e(e.toString());
    initialHome = NoInternetView.id;
  }

  runApp(MyApp(analytics));
}

class MyApp extends StatelessWidget {
  MyApp(this.analyticsService);

  final AnalyticsService analyticsService;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return MultiProvider(
        providers: [
          Provider<UserData>(
            create: (context) {
              if (Hive.box("users").containsKey("this")) {
                return Hive.box("users").get("this");
              }
              UserData user = UserData();
              Hive.box("users").put("this", user);
              return user;
            },
          ),
          Provider<AnalyticsService>.value(
            value: analyticsService,
          )
        ],
        builder:(context, child) => MaterialApp(
          theme: myTheme,
          debugShowCheckedModeBanner: false,
          onGenerateRoute: (RouteSettings settings) => router.generateRoute(settings, context),
          initialRoute: initialHome,
          routes: {
            HomeScreen.id: (context) => HomeScreen(),
          },
          navigatorObservers: <NavigatorObserver>[
            // AnalyticsService().getAnalyticsObserver(),
          ],
        ));
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

// Widget settingValue(RemoteConfig remoteConfig) {
//   logger.d("value of firebase config: ${remoteConfig.getString('apiBaseUrl')}");
//   logger.i("before: $baseURL");
//   baseURL = remoteConfig.getString('apiBaseUrl');
//   logger.e("after: $baseURL");
//   return MyApp();
// }

Future initHive() async {
  registerLocationAdapter();
  Hive.registerAdapter(UserDataAdapter());
  await Hive.initFlutter();
  // HydratedBloc.storage = await HydratedStorage.build();
  Box login = await Hive.openBox("firstlogin");
  await Hive.openBox("users");
  indexOfHomeScreen = await Hive.openBox("index");
  indexOfHomeScreen.put("index", 0);
  notificationIndicator = await Hive.openBox("counter");
  notificationIndicator.put("counter", 0);
  firstLogin = await login.get('firstLogin');
}
