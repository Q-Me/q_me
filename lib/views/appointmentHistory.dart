import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qme/api/base_helper.dart';
import 'package:qme/api/endpoints.dart';
import 'package:qme/model/user.dart';

class AppointmentsHistoryScreen extends StatefulWidget {
  @override
  _AppointmentsHistoryScreenState createState() =>
      _AppointmentsHistoryScreenState();
}

class _AppointmentsHistoryScreenState extends State<AppointmentsHistoryScreen> {
  var data;
  var arr = ["ALL"];
  var histotyType = [
    "ALL",
    "DONE",
    "UPCOMING",
    "CANCELLED BY SUBSCRIBER",
  ];
  String currentSelectedValue;

  ApiBaseHelper _helper = ApiBaseHelper();

  Future appointHistory() async {
    final UserData userData = await getUserDataFromStorage();
    final response = await _helper.post(
      appHistory,
      headers: {'Authorization': 'Bearer ${userData.accessToken}'},
      req: {'status': arr},
    );
    print("arr: $arr");
    print("slots : ${response['slots']}");
    return response['slots'];
  }

  Future<void> getData() async {
    data = await appointHistory();
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Center(child: Text("My Appointments")),
        ),
        body: FutureBuilder(
          future: getData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError)
                return Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Center(
                        child: Text("Network Error"),
                      )
                    ],
                  ),
                );
              else
                return _transBuildList(
                  context,
                  data,
                );
            } else
              return Center(
                child: CircularProgressIndicator(),
              );
          },
        ),
      ),
    );
  }

  Widget _transBuildList(
    BuildContext context,
    dynamic data,
  ) {
    var len = data == null ? 0 : data.length + 1;

    return Scrollbar(
      child: ListView.builder(
        itemCount: len,
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            bool karma = false;
            if (len == 1) karma = true;
            return dateView(karma);
          } else
            return listElement(
              context,
              len - index - 1,
              data,
            );
        },
      ),
    );
  }

  Widget dateView(
    bool karma,
  ) {
    var cHeight = MediaQuery.of(context).size.height;
    var cWidth = MediaQuery.of(context).size.width;
    EdgeInsets _pad = EdgeInsets.symmetric(
      vertical: cHeight * 0.018,
      horizontal: cWidth * 0.04,
      // bottom: cHeight * 0.015,
    );
    return Container(
      padding: _pad,
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Card(
                  elevation: 3.0,
                  child: FormField<String>(
                    builder: (FormFieldState<String> state) {
                      return InputDecorator(
                        decoration: InputDecoration(
                            //labelStyle: textStyle,
                            errorStyle: TextStyle(
                                color: Colors.redAccent, fontSize: 16.0),
                            hintText: 'History Type',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0))),
                        isEmpty: currentSelectedValue == '',
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            hint: Center(child: Text("History Type")),
                            value: currentSelectedValue,
                            isDense: true,
                            onChanged: (String newValue) {
                              setState(() {
                                currentSelectedValue = newValue;
                                arr[0] = currentSelectedValue;
                                state.didChange(newValue);
                              });
                            },
                            items: histotyType.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          !karma
              ? Container()
              : Padding(
                  padding: EdgeInsets.only(
                    top: cHeight * 0.2,
                  ),
                  child: Center(
                    child: Text(
                      "There are no Appoinments",
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                )
        ],
      ),
    );
  }
}

Widget listElement(
  BuildContext context,
  int index,
  dynamic data,
) {
  var cHeight = MediaQuery.of(context).size.height;
  var cWidth = MediaQuery.of(context).size.width;
String startDate =
      DateFormat.yMMMd().format(DateTime.parse(data[index]['slot_starttime'])) +
          " " +
          DateFormat.jm().format(DateTime.parse(data[index]['slot_starttime']));
  String endTime =
      DateFormat.jm().format(DateTime.parse(data[index]['slot_endtime']));

  return Padding(
    padding: EdgeInsets.symmetric(
      horizontal: cWidth * 0.04,
      vertical: cHeight * 0.005,
    ),
    child: InkWell(
      onTap: null,
      child: Card(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: cHeight * 0.005,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Expanded(
                child: ListTile(
                  leading: Container(
                    child: CircleAvatar(
                        child: CircleAvatar(
                      child: Text(
                        "${data[index]['subscriber']}"
                            .substring(0, 1)
                            .toUpperCase(),
                      ),
                    )
                        ),
                    width: 40.0,
                    height: 40.0,
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                  ),
                 isThreeLine: true,
                    title: Text(
                      "${data[index]['subscriber']}",
                    ),
                    subtitle: Text(
                     "$startDate - $endTime\nStatus: ${data[index]['slot_status']}\nPhone: ${data[index]['phone']}\nNote: ${data[index]['note']}",
                    ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(3),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
