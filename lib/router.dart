import 'package:flutter/material.dart';
import 'package:qme/model/subscriber.dart';
import 'package:qme/views/appointment.dart';
import 'package:qme/views/home.dart';
import 'package:qme/views/introSlider.dart';
import 'package:qme/views/nearby.dart';
import 'package:qme/views/otpPage.dart';
import 'package:qme/views/profile.dart';
import 'package:qme/views/review.dart';
import 'package:qme/views/signin.dart';
import 'package:qme/views/signup.dart';
import 'package:qme/views/subscriber.dart';
import 'package:qme/views/success.dart';
import 'package:qme/views/token.dart';
import 'package:qme/views/unknown.dart';

import 'views/nearby.dart';
import 'views/profile.dart';
import 'views/signin.dart';
import 'views/signup.dart';
import 'views/subscriber.dart';
import 'views/token.dart';
import 'views/unknown.dart';

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

    case AppointmentScreen.id:
      Map<String, dynamic> arguments = settings.arguments;
      return MaterialPageRoute(
        builder: (context) => AppointmentScreen(
          subscriber: arguments["subscriber"],
          reception: arguments["reception"],
          slot: arguments["slot"],
        ),
        settings: RouteSettings(name: AppointmentScreen.id),
      );

    case ProfileScreen.id:
      return MaterialPageRoute(
        builder: (context) => ProfileScreen(),
        settings: RouteSettings(name: ProfileScreen.id),
      );
    case IntroScreen.id:
      return MaterialPageRoute(
        builder: (context) => IntroScreen(),
        settings: RouteSettings(name: IntroScreen.id),
      );
    case ReviewScreen.id:
      Map<String, dynamic> arguments = settings.arguments;
      return MaterialPageRoute(
          builder: (context) => ReviewScreen(
                subscriberId: arguments['subscriberId'],
                receptionId: arguments['receptionId'],
                name: arguments['name'],
                subscriberName: arguments['subscriberName'],
              ),
          settings: RouteSettings(name: ReviewScreen.id));

    case BookingSuccess.id:
      final SuccessScreenArguments arguments =
          settings.arguments ?? SuccessScreenArguments(otp: settings.arguments);
      return MaterialPageRoute(
          builder: (context) => BookingSuccess(arguments),
          settings: RouteSettings(name: BookingSuccess.id));

    default:
      return MaterialPageRoute(
        builder: (context) => UndefinedView(name: settings.name),
        settings: RouteSettings(name: '/undefined'),
      );
  }
}
