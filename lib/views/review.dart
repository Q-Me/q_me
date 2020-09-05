import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:qme/bloc/review_bloc/review_bloc.dart';

class ReviewScreenArguments {
  final String receptionId;
  final String subscriberId;
  final String name;
  final String subscriberName;
  final DateTime slot;

  ReviewScreenArguments(this.receptionId, this.subscriberId, this.name,
      this.subscriberName, this.slot);
}

class ReviewScreen extends StatefulWidget {
  static const String id = "/reviewScreen";
  const ReviewScreen(
    this.args, {
    Key key,
  }) : super(key: key);
  final ReviewScreenArguments args;
  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  String get receptionId => widget.args.receptionId;
  String get subscriberId => widget.args.subscriberId;
  String get subscriberName => widget.args.subscriberName;
  String get name => widget.args.name;
  DateTime get slot => widget.args.slot;
  double stars = 0;
  String review = '';
  final TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    // double height = MediaQuery.of(context).size.height;
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
        body: BlocProvider(
          create: (context) => ReviewBloc(),
          child: BlocListener<ReviewBloc, ReviewState>(
            listener: (context, state) {
              if (state is ReviewLoading) {
                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Booking your review"),
                  ),
                );
              } else if (state is ReviewFailure) {
                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    content: Text("An unexpected error occured"),
                  ),
                );
              } else if (state is ReviewSuccessful) {
                Navigator.pop(context);
              }
            },
            child: ScrollConfiguration(
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
                            "$name",
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
                    listItem(FontAwesomeIcons.solidCalendarAlt,
                        "${DateFormat.yMMMMEEEEd().format(slot)}"),
                    listItem(FontAwesomeIcons.clock,
                        "${DateFormat.jm().format(slot)}"),
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
                          hintText:
                              "Write your review here. It will help others.",
                          border: new OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor),
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        onChanged: (value) {
                          print(value);
                        },
                      ),
                    ),
                    BlocBuilder<ReviewBloc, ReviewState>(
                      builder: (context, state) {
                        return RaisedButton(
                          onPressed: () {
                            BlocProvider.of<ReviewBloc>(context)
                                .add(ReviewPostRequested(
                              subscriberId: subscriberId,
                              counterId: receptionId,
                              rating: stars.toString(),
                              review: controller.text,
                            ));
                          },
                          color: Theme.of(context).primaryColor,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 35, vertical: 20),
                            child: Text(
                              "Submit",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                        );
                      },
                    )
                  ],
                ),
              ),
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
