import 'package:flutter/material.dart';
import '../widgets/text.dart';
import '../widgets/Tiles.dart';
import '../widgets/appDrawer.dart';import '../widgets/error.dart';
import '../widgets/loader.dart';
import '../api/base_helper.dart';
import 'package:qme/api/base_helper.dart';
import '../model/token.dart';


class ProfileScreen extends StatelessWidget {
  static const String id = '/profile';
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
        drawer: AppDrawer(),
        backgroundColor: scaffoldBackground,
        /*appBar: AppBar(
          elevation: 0,
          backgroundColor: scaffoldBackground,
        ),*/
        body: SingleChildScrollView(
          physics: ScrollPhysics(),
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
                          '• Your Bookings',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
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
                  child: ListView.builder(
                      itemCount: 10,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return CustomListTile(
                          title: 'Someones\'s Store',
                          subtitle: '26th April`20 17:00',
                          isOpened: false,
                          onTap: () {},
                          w: double.infinity,
                        );
                      }),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
