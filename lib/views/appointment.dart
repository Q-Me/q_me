import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:qme/api/base_helper.dart';
import 'package:qme/bloc/appointment.dart';
import 'package:qme/bloc/booking_bloc.dart';
import 'package:qme/bloc/note_bloc.dart';
import 'package:qme/model/reception.dart';
import 'package:qme/model/slot.dart';
import 'package:qme/model/subscriber.dart';
import 'package:qme/model/user.dart';
import 'package:qme/repository/appointment.dart';
import 'package:qme/utilities/logger.dart';
import 'package:qme/widgets/button.dart';
import 'package:qme/widgets/error.dart';
import 'package:qme/widgets/loader.dart';

String notes;

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
  int otp;
  AppointmentBloc _appointmentBloc;
  AppointmentRepository appointmentRepository;
  bool cancel = false;

  @override
  void initState() {
    _appointmentBloc = AppointmentBloc(
      slot: slot,
      subscriber: subscriber,
      reception: reception,
    );
    appointmentRepository = AppointmentRepository();
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
      child: MultiBlocProvider(
        providers: [
          BlocProvider<BookingBloc>(
              create: (context) =>
                  BookingBloc(appointmentRepository: appointmentRepository))
        ],
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
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 24),
                      ),
                      subtitle: Text(
                        '${slot.endTime.difference(slot.startTime).inMinutes} min, ends at ${DateFormat.jm().format(slot.endTime)}',
                      ),
                    ),
                    Divider(),
                    ListTile(
                      title: Text(
                        subscriber.name,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 24),
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
                    BlocConsumer<BookingBloc, BookingState>(
                        listener: (context, state) {
                      if (state is BookingLoadFailure) {
                        Scaffold.of(context).showSnackBar(SnackBar(
                          content: Text("An unexpected error occured"),
                          action: SnackBarAction(
                              label: "Retry",
                              onPressed: () async {
                                BlocProvider.of<BookingBloc>(context).add(
                                    BookingRequested(
                                        subscriber.id,
                                        note,
                                        reception.id,
                                        slot.startTime,
                                        slot.endTime,
                                        await getAccessTokenFromStorage()));
                              }),
                        ));
                      } else if (state is BookingInitial) {
                        if (state.error == false) {
                          Scaffold.of(context).showSnackBar(SnackBar(
                            content: Text("Booking Successfully Cancelled"),
                          ));
                        } else if (state.error == true) {
                          Scaffold.of(context).showSnackBar(SnackBar(
                            content: Text(
                                "An unexpected error occurred while cancelling.\nTry booking the appointment and cancelling again"),
                          ));
                        }
                      }
                    }, builder: (context, state) {
                      final bloccontext = context;
                      if (state is BookingInitial) {
                        {
                          logger.i("Reception: " + reception.id,
                              "Subscriber: " + subscriber.id);
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              SizedBox(height: 50),
                              SizedBox(width: 10),
                              Expanded(
                                child: ThemedSolidButton(
                                    text: 'Book Appointment',
                                    buttonFunction: () async {
                                      logger.i('Button clicked');
                                      // box.put("appointment", "true");
                                      BlocProvider.of<BookingBloc>(context).add(
                                          BookingRequested(
                                              subscriber.id,
                                              notes,
                                              reception.id,
                                              slot.startTime,
                                              slot.endTime,
                                              await getAccessTokenFromStorage()));
                                    }),
                              ),
                              SizedBox(width: 10),
                              // TODO button to add slot to wish list
//                    WishListButton(added: false),
                            ],
                          );
                        }
                      } else if (state is BookingLoadInProgress) {
                        return Center(
                          child: CircularProgressIndicator(
                            backgroundColor: Colors.blue[800],
                          ),
                        );
                      } else if (state is BookingLoadFailure) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            SizedBox(height: 50),
                            SizedBox(width: 10),
                            Expanded(
                              child: ThemedSolidButton(
                                  text: 'Retry Appointment',
                                  buttonFunction: () async {
                                    logger.i('Button clicked');
                                    BlocProvider.of<BookingBloc>(context).add(
                                        BookingRequested(
                                            subscriber.id,
                                            notes,
                                            reception.id,
                                            slot.startTime,
                                            slot.endTime,
                                            await getAccessTokenFromStorage()));
                                  }),
                            ),
                            SizedBox(width: 10),
                            // TODO button to add slot to wish list
//                    WishListButton(added: false),
                          ],
                        );
                      } else if (state is BookingLoadSuccess) {
                        int otp = state.details.otp;
                        return Column(
                          children: <Widget>[
                            SizedBox(height: 20),
                            Column(
                              children: <Widget>[
                                Text(
                                  'You OTP for the appointment is',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1
                                      .copyWith(
                                        fontSize: 20,
                                      ),
                                ),
                                Text(
                                  '$otp',
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
                                      text: 'Cancel Appointment',
                                      buttonFunction: () async {
                                        logger.i('Button clicked');
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text("Whoa, Hold On..."),
                                                content: Text(
                                                    "Do you really want to cancel your appointment?"),
                                                actions: <Widget>[
                                                  new RaisedButton(
                                                    onPressed: () async {
                                                      cancel = true;
                                                      BlocProvider.of<
                                                                  BookingBloc>(
                                                              bloccontext)
                                                          .add(CancelRequested(
                                                              reception.id,
                                                              await getAccessTokenFromStorage()));
                                                      Navigator.pop(context);
                                                    },
                                                    child:
                                                        Text("Yep, I'm sure"),
                                                    color: Colors.red[600],
                                                  ),
                                                  new RaisedButton(
                                                    onPressed: () {
                                                      cancel = false;
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text(
                                                        "No, I want my appointment"),
                                                    color: Colors.green[600],
                                                  )
                                                ],
                                              );
                                            });
                                      }),
                                ),
                                SizedBox(width: 10),
                                // TODO button to add slot to wish list
//                    WishListButton(added: false),
                              ],
                            ),
                            SizedBox(height: 20),
                          ],
                        );
                      } else if (state is BookingDone) {
                        int otp = state.detail.otp;
                        return Column(
                          children: <Widget>[
                            SizedBox(height: 20),
                            Column(
                              children: <Widget>[
                                Text(
                                  'You OTP for the appointment is',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1
                                      .copyWith(
                                        fontSize: 20,
                                      ),
                                ),
                                Text(
                                  '$otp',
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
                                      text: 'Cancel Appointment',
                                      buttonFunction: () async {
                                        logger.i('Button clicked');
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text("Whoa, Hold On..."),
                                                content: Text(
                                                    "Do you really want to cancel your appointment?"),
                                                actions: <Widget>[
                                                  new RaisedButton(
                                                    onPressed: () async {
                                                      cancel = true;
                                                      BlocProvider.of<
                                                                  BookingBloc>(
                                                              bloccontext)
                                                          .add(CancelRequested(
                                                              reception.id,
                                                              await getAccessTokenFromStorage()));
                                                      Navigator.pop(context);
                                                    },
                                                    child:
                                                        Text("Yep, I'm sure"),
                                                    color: Colors.red[600],
                                                  ),
                                                  new RaisedButton(
                                                    onPressed: () {
                                                      cancel = false;
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text(
                                                        "No, I want my appointment"),
                                                    color: Colors.green[600],
                                                  )
                                                ],
                                              );
                                            });
                                      }),
                                ),
                                SizedBox(width: 10),
                                // TODO button to add slot to wish list
//                    WishListButton(added: false),
                              ],
                            ),
                            SizedBox(height: 20),
                          ],
                        );
                      }
                    })
                  ],
                ),
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

class CustomerDetails extends StatefulWidget {
  const CustomerDetails({
    Key key,
    @required this.name,
    @required this.phone,
    this.note = '',
  });
  final String name, phone, note;

  @override
  _CustomerDetailsState createState() => _CustomerDetailsState();
}

class _CustomerDetailsState extends State<CustomerDetails> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<NoteBloc>(
      create: (context) => NoteBloc(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ListTile(
            subtitle: Text('Customer Name'),
            title: Text(widget.name),
          ),
          ListTile(
            subtitle: Text('Customer Phone'),
            title: Text(widget.phone),
          ),
          Divider(),
          BlocBuilder<NoteBloc, NoteState>(builder: (context, state) {
            if (state is NoteAbsent) {
              return ListTile(
                onTap: () async {
                  print("printing booking note before");
                  final bookingNote = await Navigator.push(context,
                      MaterialPageRoute(builder: (context) => BookingNotes()));
                  notes = bookingNote;
                  if (bookingNote != '') {
                    BlocProvider.of<NoteBloc>(context).add(NoteAdded(notes));
                  }
                },
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
                  widget.note,
                  textAlign: TextAlign.left,
                ),
                trailing: Icon(Icons.arrow_forward_ios),
              );
            } else if (state is NotePresent) {
              return ListTile(
                onTap: () async {
                  print("printing booking note before");

                  final bookingNote = await Navigator.push(context,
                      MaterialPageRoute(builder: (context) => BookingNotes()));
                  notes = bookingNote;
                  if (bookingNote != '') {
                    BlocProvider.of<NoteBloc>(context).add(NoteAdded(notes));
                  }
                },
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
                  state.notes,
                  textAlign: TextAlign.left,
                ),
                trailing: Icon(Icons.arrow_forward_ios),
              );
            }
          })
        ],
      ),
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

class BookingNotes extends StatelessWidget {
  const BookingNotes({
    Key key,
    this.note,
  }) : super(key: key);
  final String note;
  @override
  Widget build(BuildContext context) {
    var cHeight = MediaQuery.of(context).size.height;
    var cWidth = MediaQuery.of(context).size.width;
    TextEditingController noteController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.black),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            // // color: _c,

            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    " Add Booking Note",
                    style: TextStyle(
                        // fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: cHeight * 0.05,
                  ),
                  Text(
                    "It includes requests and comments about your booking",
                  ),
                  SizedBox(
                    height: cHeight * 0.04,
                  ),
                  TextFormField(
                    controller: noteController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    validator: (value) {
                      if (value.length == 0) {
                        return ('Enter information');
                      } else {
                        return null;
                      }
                    },
                  ),
                  SizedBox(
                    height: cHeight * 0.1,
                  ),
                  Container(
                    width: cWidth * 0.8,
                    child: RaisedButton(
                        onPressed: () {
                          Navigator.pop(context, noteController.text);
                        },
                        textColor: Colors.white,
                        padding: const EdgeInsets.all(0.0),
                        child: Container(
                          child: Text(
                            "Done",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        )),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
