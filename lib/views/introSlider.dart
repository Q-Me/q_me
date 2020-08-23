import 'package:flutter/material.dart';
import 'package:intro_slider/dot_animation_enum.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:intro_slider/slide_object.dart';
import 'package:qme/views/signin.dart';

class IntroScreen extends StatefulWidget {
  static const String id = "/introScreen";

  IntroScreen({Key key}) : super(key: key);

  @override
  IntroScreenState createState() => new IntroScreenState();
}

class IntroScreenState extends State<IntroScreen> {
  List<Slide> slides = new List();

  Function goToTab;

  @override
  void initState() {
    super.initState();

    slides.add(
      new Slide(
        title: "Convenience", marginTitle: EdgeInsets.only(top: 400.0), styleTitle: TextStyle(color: Colors.brown[900] ,fontWeight: FontWeight.bold, fontSize: 25.0,),
        description: "Book in the comfort of your home or in your office by choosing your own time for your required service seamlessly.", marginDescription: EdgeInsets.all( 16.0),styleDescription: TextStyle(color: Colors.brown[900] ,fontWeight: FontWeight.bold ,height: 1.5, fontSize: 16.0),
        backgroundImage: "assets/temp/introSlider1.png",backgroundOpacity: 0.0
      ),
    );
    slides.add(
      new Slide(
        title: "Precation & Time Saving!",marginTitle: EdgeInsets.only(top: 400.0), styleTitle: TextStyle(color: Colors.brown[900] ,fontWeight: FontWeight.bold, fontSize: 25.0,),
        description: "Avoid the risk of getting infected and safe your precious time by never having to bear the hassle of a queue in this all-in-one App.",marginDescription: EdgeInsets.all( 16.0),styleDescription: TextStyle(color: Colors.brown[900] ,fontWeight: FontWeight.bold ,height: 1.5, fontSize: 16.0),
        backgroundImage: "assets/temp/introSlider2.png",backgroundOpacity: 0.0
      ),
    );
    slides.add(
      new Slide(
        title: "Best User Experince",marginTitle: EdgeInsets.only(top: 400.0), styleTitle: TextStyle(color: Colors.brown[900] ,fontWeight: FontWeight.bold, fontSize: 25.0,),
        description: "User interface enabling great product-user communication and also ensures user's security Simple and easy to use.",marginDescription: EdgeInsets.all( 16.0),styleDescription: TextStyle(color: Colors.brown[900] ,fontWeight: FontWeight.bold ,height: 1.5, fontSize: 16.0),
        backgroundImage: "assets/temp/introSlider3.png",backgroundOpacity: 0.0
      ),
    );
  }

  void onDonePress() {
    Navigator.pushNamed(context, SignInScreen.id);
  }

  void onTabChangeCompleted(index) {
  }

  Widget renderNextBtn() {
    return Icon(
      Icons.navigate_next,
      color: Colors.blue[800],
      size: 35.0,
    );
  }

  Widget renderDoneBtn() {
    return Icon(
      Icons.done,
      color: Colors.blue[800],
    );
  }

  Widget renderSkipBtn() {
    return Icon(
      Icons.skip_next,
      color: Colors.blue[800],
    );
  }

  // List<Widget> renderListCustomTabs() {
  //   List<Widget> tabs = new List();
  //   for (int i = 0; i < slides.length; i++) {
  //     Slide currentSlide = slides[i];
  //     tabs.add(Container(
  //       width: double.infinity,
  //       height: double.infinity,
  //       child: Container(
  //         child: ListView(
  //           children: <Widget>[
  //             GestureDetector(
  //                 child: Image.asset(
  //               currentSlide.pathImage,
  //               fit: BoxFit.fill,
  //             )),
  //           ],
  //         ),
  //       ),
  //     ));
  //   }
  //   return tabs;
  // }

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
          onDonePress: this.onDonePress,
          colorDoneBtn: Colors.blue[100],
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