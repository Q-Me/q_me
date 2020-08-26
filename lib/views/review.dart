import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ReviewScreen extends StatefulWidget {
  static const String id = "/reviewScreen";
  const ReviewScreen(
      {Key key,
      this.slotTiming,
      this.receptionId,
      this.subscriberId,
      this.subscriberName,
      this.name})
      : super(key: key);
  final String slotTiming;
  final String receptionId;
  final String subscriberId;
  final String name;
  final String subscriberName;
  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  String get slotTiming => widget.slotTiming;
  String get receptionId => widget.receptionId;
  String get subscriberId => widget.subscriberId;
  String get subscriberName => widget.subscriberName;
  String get name => widget.name;
  double stars = 0;
  String review = '';
  final TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: FaIcon(
                FontAwesomeIcons.angleLeft,
                color: Colors.black,
                size: 40,
              ),
            ),
          ),
        ),
        body: ScrollConfiguration(
          behavior: ScrollingEffectsDisabled(),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: width,
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Text(
                        "$subscriberName",
                        style: TextStyle(
                            fontFamily: "Avenir",
                            fontSize: 40,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Patna, Bihar",
                        style: TextStyle(
                            fontFamily: "Avenir",
                            fontSize: 16,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                listItem(FontAwesomeIcons.solidCalendarAlt, "24 July 2020"),
                listItem(FontAwesomeIcons.clock, "11:30 AM"),
                SizedBox(
                  height: 30,
                ),
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      "Would you like to rate them?",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                RatingBar(
                  onRatingUpdate: (rating) {
                    print(rating);
                    stars = rating;
                  },
                  ratingWidget: RatingWidget(
                      full: FaIcon(
                        FontAwesomeIcons.solidStar,
                        color: Theme.of(context).primaryColor,
                      ),
                      half: FaIcon(
                        FontAwesomeIcons.solidStarHalf,
                        color: Theme.of(context).primaryColor,
                      ),
                      empty: FaIcon(
                        FontAwesomeIcons.star,
                      )),
                ),
                SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: TextField(
                    controller: controller,
                    minLines: 5,
                    maxLines: 6,
                    decoration: InputDecoration(
                      hintText: "Write your review here. It will help others.",
                      border: new OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Theme.of(context).primaryColor),
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                RaisedButton(
                  onPressed: () {},
                  color: Theme.of(context).primaryColor,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 35, vertical: 20),
                    child: Text(
                      "Submit",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget listItem(IconData icon, String description) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.fromLTRB(60, 20, 20, 0),
      child: Row(
        children: [
          FaIcon(
            icon,
            size: 40,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
            child: Text(description, style: TextStyle(fontSize: 16)),
          )
        ],
      ),
    );
  }
}

class ScrollingEffectsDisabled extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
