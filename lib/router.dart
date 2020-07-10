import 'package:flutter/material.dart';
import 'package:qme/model/subscriber.dart';
import 'package:qme/views/home.dart';
import 'package:qme/views/nearby.dart';
import 'package:qme/views/otpPage.dart';
import 'package:qme/views/profile.dart';
import 'package:qme/views/signin.dart';
import 'package:qme/views/signup.dart';
import 'package:qme/views/subscriber.dart';
import 'package:qme/views/token.dart';
import 'package:qme/views/unknown.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case SignUpScreen.id:
      return MaterialPageRoute(
        builder: (context) => SignUpScreen(),
        settings: RouteSettings(name: SignUpScreen.id),
      );

    case SignInScreen.id:
      return MaterialPageRoute(
        builder: (context) => SignInScreen(),
        settings: RouteSettings(name: SignInScreen.id),
      );

    case OtpPage.id:
      return MaterialPageRoute(
        builder: (context) => OtpPage(),
        settings: RouteSettings(name: OtpPage.id),
      );

    case HomeScreen.id:
      return MaterialPageRoute(
        builder: (context) => HomeScreen(),
        settings: RouteSettings(name: HomeScreen.id),
      );

    case NearbyScreen.id:
      return MaterialPageRoute(
        builder: (context) => NearbyScreen(),
        settings: RouteSettings(name: NearbyScreen.id),
      );

    case SubscriberScreen.id:
      Subscriber subscriber = settings.arguments;
      return MaterialPageRoute(
        builder: (context) => SubscriberScreen(subscriber: subscriber),
        settings: RouteSettings(name: SubscriberScreen.id),
      );

    case TokenScreen.id:
      String queueId = settings.arguments;
      return MaterialPageRoute(
        builder: (context) => TokenScreen(queueId: queueId),
        settings: RouteSettings(name: TokenScreen.id),
      );

    case ProfileScreen.id:
      return MaterialPageRoute(
        builder: (context) => ProfileScreen(),
        settings: RouteSettings(name: ProfileScreen.id),
      );

    default:
      return MaterialPageRoute(
        builder: (context) => UndefinedView(name: settings.name),
        settings: RouteSettings(name: '/undefined'),
      );
  }
}
