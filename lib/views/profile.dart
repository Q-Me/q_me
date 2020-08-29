import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qme/bloc/subscriber_bloc/subscriber_bloc.dart';

import '../api/base_helper.dart';
import '../bloc/profile.dart';
import '../model/token.dart';
import '../widgets/Tiles.dart';
import '../widgets/error.dart';
import '../widgets/loader.dart';
import '../widgets/text.dart';

final String myJson = '''
{
    "token": [
        {
            "subscriber": "S1",
            "longitude": 25.594095,
            "latitude": 85.137566,
            "phone": "9898009900",
            "address": "Patna Estate",
            "category": "Saloon",
            "verified": 1,
            "profileImage": "NULL",
            "start_date_time": "2021-05-01T18:36:00.000Z",
            "end_date_time": "2021-05-02T23:30:00.000Z",
            "current_token": 0,
            "queue_status": "UPCOMING",
            "queue_id": "JAja9QUbS",
            "subscriber_id": "17dY6K8Hb",
            "token_no": 1,
            "token_status": "WAITING",
            "note": "sdadsad"
        }
    ]
}
''';

class ProfileScreen extends StatefulWidget {
  static const String id = '/profile';

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final scaffoldBackground = Colors.white;

  final List<QueueToken> tokens = tokensFromJson(myJson).tokenList;

  ProfileBloc profileBloc;

  void initState() {
    profileBloc = ProfileBloc();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
          ),
        ),
        backgroundColor: scaffoldBackground,
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
                  child: StreamBuilder<ApiResponse<List<QueueToken>>>(
                      stream: profileBloc.tokenListStream,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          switch (snapshot.data.status) {
                            case Status.COMPLETED:
                              return ListView.builder(
                                itemCount: tokens.length,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return CustomListTile(
                                    title: tokens[index].subscriber,
                                    subtitle: tokens[index]
                                        .startDateTime
                                        .toLocal()
                                        .toString(),
                                    isOpened: false,
                                    onTap: () {},
                                    w: double.infinity,
                                  );
                                },
                              );
                              break;
                            case Status.ERROR:
                              return Error(
                                errorMessage: snapshot.data.message,
                                onRetryPressed: () => profileBloc.fetchTokens(
                                  status: 'ALL',
                                ),
                              );
                              break;
                            case Status.LOADING:
                              return Loading(
                                loadingMessage: snapshot.data.message,
                              );
                              break;
                          }
                          return Text('df');
                        } else {
                          return Text('No snapshot data.');
                        }
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
