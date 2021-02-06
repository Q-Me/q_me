import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qme/services/analytics.dart';
import 'package:qme/views/appointment.dart';
import 'package:qme/views/home.dart';
import 'package:qme/views/initialScreen.dart';
import 'package:qme/views/introSlider.dart';
import 'package:qme/views/noInternet.dart';
import 'package:qme/views/otpPage.dart';
import 'package:qme/views/review.dart';
import 'package:qme/views/signin.dart';
import 'package:qme/views/signup.dart';
import 'package:qme/views/slot_view.dart';
import 'package:qme/views/subscriber.dart';
import 'package:qme/views/booking_success.dart';

import 'views/signin.dart';
import 'views/signup.dart';

Route<dynamic> generateRoute(RouteSettings settings, BuildContext context) {
  context.read<AnalyticsService>().setScreen(settings.name);
  // logger.d(settings.name);
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
        builder: (context) => OtpPage(
          args: settings.arguments,
        ),
        settings: RouteSettings(name: OtpPage.id),
      );

    case HomeScreen.id:
      return MaterialPageRoute(
        builder: (context) => HomeScreen(),
        settings: RouteSettings(
          name: HomeScreen.id,
        ),
      );

    /* 
    case TokenScreen.id:
      String queueId = settings.arguments;
      return MaterialPageRoute(
        builder: (context) => TokenScreen(queueId: queueId),
        settings: RouteSettings(name: TokenScreen.id),
      );*/

    case SubscriberScreen.id:
      return MaterialPageRoute(
        builder: (context) => SubscriberScreen(subscriber: settings.arguments),
        settings: RouteSettings(name: SubscriberScreen.id),
      );

    case SlotView.id:
      final SlotViewArguments arg = settings.arguments;
      return MaterialPageRoute(builder: (context) => SlotView(arg));

    case AppointmentScreen.id:
      final ApppointmentScreenArguments arguments = settings.arguments;
      return MaterialPageRoute(
        builder: (context) => AppointmentScreen(arguments),
        settings: RouteSettings(name: AppointmentScreen.id),
      );

    case IntroScreen.id:
      return MaterialPageRoute(
        builder: (context) => IntroScreen(),
        settings: RouteSettings(name: IntroScreen.id),
      );
    case InitialScreen.id:
      return MaterialPageRoute(
        builder: (context) => InitialScreen(),
        settings: RouteSettings(name: InitialScreen.id),
      );
    case ReviewScreen.id:
      final ReviewScreenArguments arguments = settings.arguments;
      return MaterialPageRoute(
          builder: (context) => ReviewScreen(arguments),
          settings: RouteSettings(name: ReviewScreen.id));

    case BookingSuccess.id:
      final SuccessScreenArguments arguments =
          SuccessScreenArguments(otp: settings.arguments.toString());
      return MaterialPageRoute(
          builder: (context) => BookingSuccess(arguments),
          settings: RouteSettings(name: BookingSuccess.id));

    case NoInternetView.id:
      return MaterialPageRoute(
        builder: (context) => NoInternetView(),
        settings: RouteSettings(name: NoInternetView.id),
      );

/*    default:
      return MaterialPageRoute(
        builder: (context) => HomeScreen(),
        settings: RouteSettings(name: HomeScreen.id),
      );
      */
  }
}

class LocationRoute extends PageRouteBuilder {
  final Widget nextView;

  LocationRoute({@required this.nextView})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => nextView,
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              SlideTransition(
            position:
                Tween<Offset>(begin: Offset(0, -1), end: Offset(0, 0)).animate(
              animation,
            ),
            child: child,
          ),
        );
}
