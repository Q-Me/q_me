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
        pathImage: "assets/temp/introSlider1.png",
      ),
    );
    slides.add(
      new Slide(
        pathImage: "assets/temp/introSlider2.png",
      ),
    );
    slides.add(
      new Slide(
        pathImage: "assets/temp/introSlider3.png",
      ),
    );
  }

  void onDonePress() {
    Navigator.pushNamed(context, SignInScreen.id);
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
      padding: const EdgeInsets.all(10.0),
      child: Text('Done'),
    );
  }

  Widget renderSkipBtn() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Text('Skip'),
    );
  }

  List<Widget> _renderListCustomTabs() {
    List<Widget> tabs = new List();
    for (int i = 0; i < slides.length; i++) {
      Slide currentSlide = slides[i];
      tabs.add(Container(
        width: double.infinity,
        height: double.infinity,
        child: Container(
          child: ListView(
            children: <Widget>[
              GestureDetector(
                  child: Image.asset(
                currentSlide.pathImage,
                fit: BoxFit.fill,
              )),
            ],
          ),
        ),
      ));
    }
    return tabs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IntroSlider(
        // List slides
        slides: this.slides,

        // Skip button
        renderSkipBtn: this.renderSkipBtn(),
//          colorSkipBtn: Colors.blue[100],
//          highlightColorSkipBtn: Colors.blue[800],

        // Next button
        renderNextBtn: this.renderNextBtn(),

        // Done button
        renderDoneBtn: this.renderDoneBtn(),
        onDonePress: this.onDonePress,
//        colorDoneBtn: Colors.blue[100],
//        highlightColorDoneBtn: Colors.blue[800],

        // Dot indicator
        colorDot: Colors.blue[800],
        sizeDot: 13.0,
        typeDotAnimation: dotSliderAnimation.SIZE_TRANSITION,

        // Tabs
        listCustomTabs: _renderListCustomTabs(),
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
