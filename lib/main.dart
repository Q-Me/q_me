import 'package:flutter/material.dart';
import 'views/nearby.dart';
import 'views/signup.dart';
import 'views/signin.dart';
import 'views/profile.dart';
import 'views/token.dart';
import 'views/booking.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      theme: ThemeData.light()
          .copyWith(primaryColor: Colors.green), //TODO Apply theme

      debugShowCheckedModeBanner: false,
      routes: <String, WidgetBuilder>{
        SignUpPage.id: (BuildContext context) => SignUpPage(),
        SignInPage.id: (BuildContext context) => SignInPage(),
        NearbyScreen.id: (BuildContext context) => NearbyScreen(),
        ProfilePage.id: (BuildContext context) => ProfilePage(),
        BookingScreen.id: (BuildContext context) => BookingScreen(),
        TokenPage.id: (BuildContext context) => TokenPage(),
      },
      initialRoute: NearbyScreen
          .id, // Check for valid access token if not then refresh it
    );
  }
}
