import 'package:flutter/material.dart';
import 'package:qme/views/home.dart';
import 'views/profile.dart';
import 'views/nearby.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'services/analytics.dart';
import 'router.dart' as router;
import 'views/signin.dart';

String initialHome = NearbyScreen.id;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
//  if (await UserRepository()).isSessionReady()) {
//  initialHome = QueuesScreen.id;
//  }
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  static FirebaseAnalytics analytics = FirebaseAnalytics();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light()
          .copyWith(primaryColor: Colors.green), //TODO Apply theme

      debugShowCheckedModeBanner: false,
      onGenerateRoute: router.generateRoute,
      initialRoute: SignInScreen.id,//ProfileScreen.id,
      navigatorObservers: <NavigatorObserver>[
        AnalyticsService().getAnalyticsObserver(),
      ],
    );
  }
}
