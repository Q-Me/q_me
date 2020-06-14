import 'package:flutter/material.dart';
import 'views/booking.dart';
import 'views/nearby.dart';
import 'views/signup.dart';
import 'views/signin.dart';
import 'views/profile.dart';
import 'views/home.dart';
import 'views/unknown.dart';
import 'model/subscriber.dart';

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

    case HomeScreen.id:
      return MaterialPageRoute(
          builder: (context) => HomeScreen(),
          settings: RouteSettings(
            name: HomeScreen.id,
          ));

    case NearbyScreen.id:
      return MaterialPageRoute(
        builder: (context) => NearbyScreen(),
        settings: RouteSettings(name: NearbyScreen.id),
      );

    case BookingScreen.id:
      Subscriber subscriber = settings.arguments;
      return MaterialPageRoute(
        builder: (context) => BookingScreen(
          subscriber: subscriber,
        ),
        settings: RouteSettings(name: BookingScreen.id),
      );

    case TokenScreen.id:
      String queueId = settings.arguments;
      return MaterialPageRoute(
        builder: (context) => TokenScreen(
          queueId: queueId,
        ),
        settings: RouteSettings(name: TokenScreen.id),
      );

    case ProfileScreen.id:
      return MaterialPageRoute(
        builder: (context) => ProfileScreen(),
        settings: RouteSettings(name: ProfileScreen.id),
      );

    default:
      return MaterialPageRoute(
        builder: (context) => UndefinedView(
          name: settings.name,
        ),
        settings: RouteSettings(name: '/undefined'),
      );
  }
}
