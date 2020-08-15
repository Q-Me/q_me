import 'package:flutter/material.dart';
import 'package:qme/repository/appointment.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

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
    var cHeight = MediaQuery.of(context).size.height;
    var cWidth = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Hi $name, rate your experience with $subscriberName",
                  style: TextStyle(fontSize: ((cHeight + cWidth) / 2) * 0.05),
                ),
              ),
              Container(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SmoothStarRating(
                    size: 40,
                    allowHalfRating: true,
                    color: Colors.blue,
                    borderColor: Colors.blue,
                    onRated: (rating) {
                      setState(() {
                        stars = rating;
                      });
                    },
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(10),
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                      border: new OutlineInputBorder(
                          borderSide: new BorderSide(color: Colors.blue)),
                      hintText:
                          "Enter your review here. Your review will help others..."),
                  keyboardType: TextInputType.multiline,
                  maxLines: 10,
                  minLines: 5,
                ),
              ),
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: SizedBox(
                  height: cHeight * 0.07,
                  width: double.infinity,
                  child: RaisedButton(
                    onPressed: () async {
                      try {
                        var response = await AppointmentRepository().review(
                            counterId: receptionId,
                            subscriberId: subscriberId,
                            rate: stars.toString(),
                            slotStartTime: slotTiming,
                            review: controller.text);
                        Scaffold.of(context).showSnackBar(SnackBar(content: response));
                      } catch (e) {
                        Scaffold.of(context).showSnackBar(SnackBar(content: e));
                      }
                    },
                    child: Text("Submit"),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ),
              Spacer(
                flex: 1,
              ),
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(12),
                child: Text(
                  "Found this app convenient?",
                  style: TextStyle(fontSize: ((cHeight + cWidth) / 2) * 0.03),
                ),
              ),
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: cHeight * 0.07,
                  child: RaisedButton(
                    onPressed: null,
                    child: Text("Refer a friend"),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
