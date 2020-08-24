import 'package:flutter/material.dart';
import 'package:icon_shadow/icon_shadow.dart';

class SubscriberView2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      floatingActionButton: IconButton(
          icon: IconShadowWidget(
            Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
            shadowColor: Colors.white,
          ),
          onPressed: () {}),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          alignment: AlignmentDirectional.bottomEnd,
          children: [
            Positioned(
              top: 0,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.45,
                width: MediaQuery.of(context).size.width,
                color: Colors.blue,
                child: Placeholder(),
              ),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.6,
                padding: EdgeInsets.all(15),
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Text(
                              "Javed Habib",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text("Patna, India"),
                          ],
                        ),
                        Card(
                          child: Container(
                            padding: EdgeInsets.all(5),
                            width: MediaQuery.of(context).size.width / 3.5,
                            height: MediaQuery.of(context).size.width / 13,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [],
                            ),
                          ),
                        )
                      ],
                    ),
                    Column(
                      children: [
                        Container(
                          height: 2,
                          width: MediaQuery.of(context).size.width,
                          color: Colors.grey,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text('Unisex Saloon'),
                                Text('Free Shampoo'),
                              ],
                            ),
                            Text("learn more")
                          ],
                        ),
                      ],
                    ),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Icon(
                            Icons.message,
                            color: Colors.white,
                          ),
                          Text('Check availible slots',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ))
                        ],
                      ),
                      width: MediaQuery.of(context).size.width / 1.4,
                      height: MediaQuery.of(context).size.width / 9,
                      decoration: BoxDecoration(
                          color: Color(0xFF084ff2),
                          borderRadius: BorderRadius.circular(18)),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text('Ratings and Reviews',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        Icon(Icons.arrow_forward)
                      ],
                    ),
                    Placeholder(
                      fallbackWidth: 200,
                      fallbackHeight: 50,
                    )
                  ],
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
