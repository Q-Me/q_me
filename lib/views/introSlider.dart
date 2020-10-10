import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intro_slider/dot_animation_enum.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:intro_slider/slide_object.dart';
import 'package:qme/services/analytics.dart';
import 'package:qme/repository/user.dart';
import 'package:qme/utilities/logger.dart';
import 'package:qme/views/home.dart';
import 'package:qme/views/signin.dart';
import 'package:qme/views/signup.dart';

class IntroScreen extends StatefulWidget {
  static const String id = "/introScreen";

  IntroScreen({Key key}) : super(key: key);

  @override
  IntroScreenState createState() => new IntroScreenState();
}

class IntroScreenState extends State<IntroScreen> {
  List<Slide> slides = new List();
  FirebaseAnalyticsObserver _observer;
  Function goToTab;

  @override
  void initState() {
    super.initState();
    _observer = AnalyticsService().getAnalyticsObserver();
    slides.add(
      new Slide(
          title: "Convenience",
          marginTitle: EdgeInsets.only(top: 400.0),
          styleTitle: TextStyle(
            color: Colors.brown[900],
            fontWeight: FontWeight.bold,
            fontSize: 25.0,
          ),
          description:
              "Book in the comfort of your home or in your office by choosing your own time for your required service seamlessly.",
          marginDescription: EdgeInsets.all(16.0),
          styleDescription: TextStyle(
              color: Colors.brown[900],
              fontWeight: FontWeight.bold,
              height: 1.5,
              fontSize: 16.0),
          backgroundImage: "assets/temp/introSlider1.png",
          backgroundOpacity: 0.0),
    );
    slides.add(
      new Slide(
          title: "Precaution & Time Saving!",
          marginTitle: EdgeInsets.only(top: 400.0),
          styleTitle: TextStyle(
            color: Colors.brown[900],
            fontWeight: FontWeight.bold,
            fontSize: 25.0,
          ),
          description:
              "Avoid the risk of getting infected and save your precious time by never having to bear the hassle of a queue in this all-in-one App.",
          marginDescription: EdgeInsets.all(16.0),
          styleDescription: TextStyle(
              color: Colors.brown[900],
              fontWeight: FontWeight.bold,
              height: 1.5,
              fontSize: 16.0),
          backgroundImage: "assets/temp/introSlider2.png",
          backgroundOpacity: 0.0),
    );
    slides.add(
      new Slide(
          widgetDescription: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Center(
                child: Text(
                  "User interface enabling great product-user communication and also ensures user's security Simple and easy to use.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.brown[900],
                      fontWeight: FontWeight.bold,
                      height: 1.5,
                      fontSize: 16.0),
                ),
              ),
              // Padding(padding: EdgeInsets.only(top: 30.0)),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("New to Q Me?",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.brown[900],
                        decoration: TextDecoration.underline,
                        fontSize: 16.0,
                      )),
                  RaisedButton(
                    onPressed: () {
                      _observer.analytics
                          .logEvent(name: "signUp_button_click");
                      Navigator.pushNamed(context, SignUpScreen.id);
                    },
                    child: Text("Sign Up",
                        style: TextStyle(
                          fontSize: 15.0,
                        )),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      side: BorderSide(color: Colors.blue[900]),
                    ),
                    color: Colors.blue[800],
                    textColor: Colors.white,
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Already have an account?",
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Colors.brown[900],
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      )),
                  RaisedButton(
                    onPressed: () {
                      _observer.analytics
                          .logEvent(name: "login_button_click");
                      Navigator.pushNamedAndRemoveUntil(
                          context, SignInScreen.id, (route) => false);
                    },
                    child: Text("Log In",
                        style: TextStyle(
                          fontSize: 15.0,
                        )),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      side: BorderSide(color: Colors.blue[900]),
                    ),
                    color: Colors.blue[800],
                    textColor: Colors.white,
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Want to skip ahead?",
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Colors.brown[900],
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      )),
                  RaisedButton(
                    onPressed: () async {
                      logger.i('Skip for now');
                      await UserRepository().guestLogin();
                      _observer.analytics.logEvent(name: "guest_login_click");
                      Navigator.pushNamedAndRemoveUntil(
                          context, HomeScreen.id, (route) => false);
                    },
                    child: Text("Skip",
                        style: TextStyle(
                          fontSize: 15.0,
                        )),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      side: BorderSide(color: Colors.blue[900]),
                    ),
                    color: Colors.blue[800],
                    textColor: Colors.white,
                  ),
                ],
              ),
            ],
          ),
          title: "Best User Experience",
          marginTitle: EdgeInsets.only(top: 350.0),
          styleTitle: TextStyle(
            color: Colors.brown[900],
            fontWeight: FontWeight.bold,
            fontSize: 25.0,
          ),
          // description:
          //     "",
          marginDescription: EdgeInsets.all(16.0),
          backgroundImage: "assets/temp/introSlider3.png",
          backgroundOpacity: 0.0),
    );
  }

  void onDonePress() async {
    Navigator.pushNamed(context, SignInScreen.id);
    Box box = await Hive.openBox("user");
    await box.put('firstLogin', false);
  }

  void onTabChangeCompleted(index) {}

  Widget renderNextBtn() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Text(
        'Next',
      ),
    );
  }

  Widget renderDoneBtn() {
    return Padding(
      padding: const EdgeInsets.all(0.0),
    );
  }

  Widget renderSkipBtn() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Text('Skip'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IntroSlider(
        // List slides
        slides: this.slides,

        // Skip button
        renderSkipBtn: this.renderSkipBtn(),
        colorSkipBtn: Colors.blue[100],
        highlightColorSkipBtn: Colors.blue[800],

        // Next button
        renderNextBtn: this.renderNextBtn(),

        // Done button
        renderDoneBtn: this.renderDoneBtn(),
        // onDonePress: this.onDonePress,
        //colorDoneBtn: Colors.blue[100],
        highlightColorDoneBtn: Colors.blue[800],

        // Dot indicator
        colorDot: Colors.blue[800],
        sizeDot: 13.0,
        typeDotAnimation: dotSliderAnimation.SIZE_TRANSITION,

        // Tabs
        // listCustomTabs: this.renderListCustomTabs(),
        backgroundColorAllSlides: Colors.black12,
        refFuncGoToTab: (refFunc) {
          this.goToTab = refFunc;
        },

        // On tab change completed
        onTabChangeCompleted: this.onTabChangeCompleted,
      ),
    );
  }
}
