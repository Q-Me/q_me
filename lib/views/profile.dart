import 'package:flutter/material.dart';
import '../widgets/text.dart';
import '../widgets/Tiles.dart';

class ProfilePage extends StatelessWidget {
  static String id = 'profile';
  final scaffoldBackground = Colors.white;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: Icon(
            Icons.menu,
            color: Colors.black,
          ),
        ),
        drawer: Drawer(
          // Add a ListView to the drawer. This ensures the user can scroll
          // through the options in the drawer if there isn't enough vertical
          // space to fit everything.
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                child: Text('Drawer Header'),
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
              ),
              ListTile(
                title: Text('Item 1'),
                onTap: () {
                  // Update the state of the app.
                  // ...
                },
              ),
              ListTile(
                title: Text('Item 2'),
                onTap: () {
                  // Update the state of the app.
                  // ...
                },
              ),
            ],
          ),
        ),
        backgroundColor: scaffoldBackground,
        /*appBar: AppBar(
          elevation: 0,
          backgroundColor: scaffoldBackground,
        ),*/
        body: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(20),
                    ),
                    color: Colors.orangeAccent,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
//                height: 400,
                        width: double.infinity,
                        child: Container(
                          alignment: Alignment(-1, 0),
                          padding: EdgeInsets.all(10),
                          child: ThemedText(
                            words: ['Hey,', 'Piyush'],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0),
                  child: Row(
//                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8)),
                          color: Colors.black12,
                        ),
                        child: Text(
                          '• Future Bookings',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
//                          border: Border.all(),
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8)),
                          color: Colors.black12,
                        ),
                        child: Text(
                          'Past Bookings',
//                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                ),
                Container(
//                  height: 400,
                  margin: EdgeInsets.fromLTRB(8, 0, 8, 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                        bottomLeft: Radius.circular(8)),
                    color: Colors.black12,
                  ),

                  width: double.infinity,
                  child: Column(
                    children: <Widget>[
                      CustomListTile(
                        img: 'assets/images/profile_pic.jpg',
                        title: 'Anna Poorva',
                        subtitle: '26th April`20 17:00',
                        isOpened: false,
                        onTap: () {},
                        w: double.infinity,
                      ),
                      CustomListTile(
                        img: 'assets/images/profile_pic.jpg',
                        title: 'Anna Poorva',
                        subtitle: '26th April`20 17:00',
                        isOpened: false,
                        onTap: () {},
                        w: double.infinity,
                      ),
                      CustomListTile(
                        img: 'assets/images/profile_pic.jpg',
                        title: 'Anna Poorva',
                        subtitle: '26th April`20 17:00',
                        isOpened: false,
                        onTap: () {},
                        w: double.infinity,
                      ),
                      CustomListTile(
                        img: 'assets/images/profile_pic.jpg',
                        title: 'Anna Poorva',
                        subtitle: '26th April`20 17:00',
                        isOpened: false,
                        onTap: () {},
                        w: double.infinity,
                      ),
                      CustomListTile(
                        img: 'assets/images/profile_pic.jpg',
                        title: 'Anna Poorva',
                        subtitle: '26th April`20 17:00',
                        isOpened: false,
                        onTap: () {},
                        w: double.infinity,
                      ),
                      CustomListTile(
                        img: 'assets/images/profile_pic.jpg',
                        title: 'Anna Poorva',
                        subtitle: '26th April`20 17:00',
                        isOpened: false,
                        onTap: () {},
                        w: double.infinity,
                      ),
                      CustomListTile(
                        img: 'assets/images/profile_pic.jpg',
                        title: 'Anna Poorva',
                        subtitle: '26th April`20 17:00',
                        isOpened: false,
                        onTap: () {},
                        w: double.infinity,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
