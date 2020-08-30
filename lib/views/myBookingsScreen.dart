import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qme/bloc/bookings_screen_bloc/bookingslist_bloc.dart';
import 'package:qme/model/appointment.dart';
import 'package:qme/widgets/listItems.dart';

class BookingsScreen extends StatefulWidget {
  BookingsScreen({Key key}) : super(key: key);

  @override
  _BookingsScreenState createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  @override
  Widget build(BuildContext context) {
    var list = List<Appointment>();
    return SafeArea(
      child: Scaffold(
        body: BlocProvider(
          create: (context) => BookingslistBloc(),
          child: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                leading: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Center(
                    child: FaIcon(
                      FontAwesomeIcons.arrowLeft,
                      color: Colors.black,
                    ),
                  ),
                ),
                expandedHeight: 200,
                floating: false,
                pinned: true,
                snap: false,
                backgroundColor: Color.fromRGBO(240, 226, 221, 1),
                flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.parallax,
                    centerTitle: false,
                    title: Text(
                      "My Bookings:",
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontFamily: "Avenir"),
                    ),
                    background: Image.asset(
                      "assets/icons/my-bookings.png",
                      fit: BoxFit.cover,
                    )),
              ),
              BlocBuilder<BookingslistBloc, BookingslistState>(
                builder: (context, state) {
                  if (state is BookingslistInitial) {
                    BlocProvider.of<BookingslistBloc>(context)
                        .add(BookingsListRequested());
                    return SliverToBoxAdapter(
                      child: Center(
                        child: CircularProgressIndicator(
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                      ),
                    );
                  } else if (state is BookingsListLoading) {
                    return SliverToBoxAdapter(
                      child: Center(
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(10),
                              child: CircularProgressIndicator(),
                            ),
                            Padding(
                              padding: EdgeInsets.all(10),
                              child: Text("Hang tight, we're loading"),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else if (state is BookingsListFailure) {
                    return SliverToBoxAdapter(
                      child: Center(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(Icons.cancel),
                                Text(
                                  "Oops, something went wrong.\nTry retrying...",
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            RaisedButton(
                              onPressed: () {
                                BlocProvider.of<BookingslistBloc>(context)
                                    .add(BookingsListRequested());
                              },
                              child: Text(
                                "Retry",
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else if (state is BookingsListSuccess) {
                    list = state.appointmentsList;
                    if (list.length == 0) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: Container(
                          color: Colors.white,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SizedBox(
                                height: 20,
                              ),
                              FaIcon(
                                FontAwesomeIcons.solidCalendarTimes,
                                size: 100,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Seems you haven't booked with us yet!",
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                              Expanded(
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(maxWidth: 300),
                                  child: Image.asset("assets/no-bookings.jpg"),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                      if (list[index].slotStatus == "UPCOMING") {
                        return ListItemBooked(
                          primaryContext: context,
                          name: list[index].subscriberName,
                          location: list[index].address,
                          slot: list[index].slot.startTime,
                          otp: list[index].otp.toString(),
                          counterId: list[index].counterId,
                        );
                      } else if (list[index].slotStatus == "DONE") {
                        return ListItemFinished(
                          name: list[index].subscriberName,
                          location: list[index].address,
                          slot: list[index].slot.startTime,
                          rating: 1.0,
                          counterId: list[index].counterId,
                          subscriberId: list[index].subscriberId,
                          subscriberName: list[index].subscriberName,
                          primaryContext: context,
                        );
                      } else {
                        return ListItemCancelled(
                          name: list[index].subscriberName,
                          location: list[index].address,
                          slot: list[index].slot.startTime,
                        );
                      }
                    }, childCount: list.length));
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
