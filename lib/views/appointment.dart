import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:qme/api/base_helper.dart';
import 'package:qme/bloc/appointment.dart';
import 'package:qme/model/reception.dart';
import 'package:qme/model/slot.dart';
import 'package:qme/model/subscriber.dart';
import 'package:qme/model/user.dart';
import 'package:qme/utilities/logger.dart';
import 'package:qme/widgets/button.dart';
import 'package:qme/widgets/error.dart';
import 'package:qme/widgets/loader.dart';

class AppointmentScreen extends StatefulWidget {
  static const String id = '/appointment';
  final Subscriber subscriber;
  final Reception reception;
  final Slot slot;

  AppointmentScreen({this.subscriber, this.reception, this.slot});

  @override
  _AppointmentScreenState createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  Subscriber get subscriber => widget.subscriber;
  Reception get reception => widget.reception;
  Slot get slot => widget.slot;
  double get h => MediaQuery.of(context).size.height;
  double get w => MediaQuery.of(context).size.width;
  String note = 'Add notes like requirements';

  AppointmentBloc _appointmentBloc;

  @override
  void initState() {
    _appointmentBloc = AppointmentBloc(
      slot: slot,
      subscriber: subscriber,
      reception: reception,
    );
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_appointmentBloc == null) {
      _appointmentBloc = AppointmentBloc(
        slot: slot,
        subscriber: subscriber,
        reception: reception,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: GestureDetector(
            child: Icon(Icons.arrow_back),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48.0),
            child: Text(
              'Review and Confirm',
              textAlign: TextAlign.left,
              style: Theme.of(context)
                  .textTheme
                  .headline4
                  .copyWith(color: Colors.white),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ChangeNotifierProvider.value(
              value: _appointmentBloc,
              child: Column(
                children: <Widget>[
                  ListTile(
                    title: Text(
                      '${DateFormat('d MMMM y').format(slot.startTime)} at ${DateFormat.jm().format(slot.startTime)}',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                    ),
                    subtitle: Text(
                      '${slot.endTime.difference(slot.startTime).inMinutes} min, ends at ${DateFormat.jm().format(slot.endTime)}',
                    ),
                  ),
                  Divider(),
                  ListTile(
                    title: Text(
                      subscriber.name,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                    ),
                    subtitle: Text(subscriber.address),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      child: CachedNetworkImage(
                        imageUrl: 'https://picsum.photos/200',
                      ),
                    ),
                  ),
                  Divider(height: 20),
                  StreamBuilder<ApiResponse<UserData>>(
                    stream: _appointmentBloc.userStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData && !snapshot.hasError) {
                        switch (snapshot.data.status) {
                          case Status.ERROR:
                            return Error(
                              errorMessage: snapshot.data.message,
                              onRetryPressed:
                                  _appointmentBloc.fetchUserProfile(),
                            );
                            break;
                          case Status.LOADING:
                            return Loading(
                              loadingMessage: snapshot.data.message,
                            );
                            break;
                          case Status.COMPLETED:
                            return CustomerDetails(
                              name: snapshot.data.data.name,
                              phone: snapshot.data.data.phone,
                              note: note,
                            );
                            break;
                        }
                      } else {
                        return Text('No data error');
                      }
                      return Text('No appointment data');
                    },
                  ),
                  SizedBox(height: 20),
                  Column(
                    children: <Widget>[
                      Text(
                        'You OTP for the appointment is',
                        style: Theme.of(context).textTheme.bodyText1.copyWith(
                              fontSize: 20,
                            ),
                      ),
                      Text(
                        '1234',
                        style: TextStyle(
                          fontSize: 42,
                          letterSpacing: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      SizedBox(width: 10),
                      Expanded(
                        child: ThemedSolidButton(
                            text: 'Confirm Appointment',
                            buttonFunction: () {
                              logger.i('Button clicked');
                            }),
                      ),
                      SizedBox(width: 10),
                      // TODO button to add slot to wish list
//                    WishListButton(added: false),
                    ],
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BookedAppointmentDetails extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class CustomerDetails extends StatelessWidget {
  const CustomerDetails({
    Key key,
    @required this.name,
    @required this.phone,
    this.note = '',
  });
  final String name, phone, note;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ListTile(
          subtitle: Text('Customer Name'),
          title: Text(name),
        ),
        ListTile(
          subtitle: Text('Customer Phone'),
          title: Text(phone),
        ),
        Divider(),
        note != '' || note != null
            ? ListTile(
                leading: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  child: Icon(
                    Icons.turned_in_not,
                    color: Colors.blue[800],
                    size: 35,
                  ),
                ),
                title: Text(
                  'Booking notes',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                subtitle: Text(
                  note,
                  textAlign: TextAlign.left,
                ),
                trailing: Icon(Icons.arrow_forward_ios),
              )
            : ListTile(
                leading: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  child: Icon(
                    Icons.turned_in,
                    color: Colors.blue[800],
                    size: 35,
                  ),
                ),
                title: Text(
                  'Booking notes',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                subtitle: Text(
                  'Add requirements',
                  textAlign: TextAlign.left,
                ),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
      ],
    );
  }
}

class WishListButton extends StatelessWidget {
  const WishListButton({
    Key key,
    this.added,
  }) : super(key: key);
  final bool added;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.red, blurRadius: 5.0, spreadRadius: 1.0),
        ],
      ),
      child: CircleAvatar(
        backgroundColor: Colors.grey[100],
        radius: 20,
        child: GestureDetector(
          onTap: () {
            logger.i('Add to wish list button clicked');
          },
          child: added
              ? Icon(
                  Icons.favorite,
                  color: Colors.red,
                )
              : Icon(
                  Icons.favorite_border,
                ),
        ),
      ),
    );
  }
}
