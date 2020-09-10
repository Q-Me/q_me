import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qme/bloc/bookings_screen_bloc/bookingslist_bloc.dart';
import 'package:qme/model/appointment.dart';
import 'package:qme/widgets/listItems.dart';

class BookingsScreen extends StatefulWidget {
  BookingsScreen({Key key, this.controller}) : super(key: key);
  final PageController controller;
  @override
  _BookingsScreenState createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  PageController get controller => widget.controller;
  @override
  Widget build(BuildContext context) {
    var list = List<Appointment>();
    List<String> reqList = [];
    return SafeArea(
      child: Scaffold(
        body: BlocProvider(
          create: (context) => BookingslistBloc(),
          child: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                leading: Center(
                  child: GestureDetector(
                    onTap: () {
                      controller.animateToPage(0,
                          duration: Duration(milliseconds: 500),
                          curve: Curves.ease);
                    },
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
                      "",
                      style: const TextStyle(
                          fontSize: 18,
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
                return SliverToBoxAdapter(
                  child: Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 10,
                        ),
                        FilterChip(
                          label: Text(
                            "Upcoming",
                            style: TextStyle(color: Colors.white),
                          ),
                          onSelected: (bool value) {
                            if (value) {
                              reqList = ["UPCOMING"];
                              BlocProvider.of<BookingslistBloc>(context).add(
                                  BookingsListRequested(
                                      statusRequired: reqList));
                            } else {
                              reqList = [];
                              BlocProvider.of<BookingslistBloc>(context).add(
                                  BookingsListRequested(
                                      statusRequired: reqList));
                            }
                          },
                          selected: reqList.contains("UPCOMING"),
                          selectedColor: Theme.of(context).primaryColor,
                          backgroundColor: Colors.grey,
                          checkmarkColor: Colors.white,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        FilterChip(
                          label: Text(
                            "Cancelled",
                            style: TextStyle(color: Colors.white),
                          ),
                          onSelected: (value) {
                            if (value) {
                              reqList = [
                                "CANCELLED",
                                "CANCELLED BY SUBSCRIBER"
                              ];
                              BlocProvider.of<BookingslistBloc>(context).add(
                                  BookingsListRequested(
                                      statusRequired: reqList));
                            } else {
                              reqList = [];
                              BlocProvider.of<BookingslistBloc>(context).add(
                                  BookingsListRequested(
                                      statusRequired: reqList));
                            }
                          },
                          backgroundColor: Colors.grey,
                          selected: reqList.contains("CANCELLED"),
                          selectedColor: Theme.of(context).primaryColor,
                          checkmarkColor: Colors.white,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        FilterChip(
                          label: Text(
                            "Completed",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          onSelected: (value) {
                            if (value) {
                              reqList = ["DONE"];
                              BlocProvider.of<BookingslistBloc>(context).add(
                                  BookingsListRequested(
                                      statusRequired: reqList));
                            } else {
                              reqList = [];
                              BlocProvider.of<BookingslistBloc>(context).add(
                                  BookingsListRequested(
                                      statusRequired: reqList));
                            }
                          },
                          selected: reqList.contains("DONE"),
                          selectedColor: Theme.of(context).primaryColor,
                          backgroundColor: Colors.grey,
                          checkmarkColor: Colors.white,
                        ),
                      ],
                    ),
                  ),
                );
              }),
              BlocBuilder<BookingslistBloc, BookingslistState>(
                builder: (context, state) {
                  if (state is BookingslistInitial) {
                    BlocProvider.of<BookingslistBloc>(context)
                        .add(BookingsListRequested());
                    return SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                      ),
                    );
                  } else if (state is BookingsListLoading) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
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
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.cancel),
                            Text(
                              "Oops, something went wrong.\nTry retrying...\n${state.errorMessage}",
                              textAlign: TextAlign.center,
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
                    if (list.length == 0 && reqList.length == 0) {
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
                    } else if (reqList.length != 0 && list.length == 0) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "No Entries available for your request",
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                      );
                    } else {
                      return SliverList(
                          delegate:
                              SliverChildBuilderDelegate((context, index) {
                        if (list[index].slotStatus == "UPCOMING") {
                          return ListItemBooked(
                            primaryContext: context,
                            name: list[index].subscriberName,
                            location: list[index].address,
                            slot: list[index].slot.startTime,
                            otp: list[index].otp.toString(),
                            counterId: list[index].counterId,
                            latitude: list[index].latitude,
                            longitude: list[index].longitude,
                          );
                        } else if (list[index].slotStatus == "DONE") {
                          return ListItemFinished(
                            name: list[index].subscriberName,
                            location: list[index].address,
                            slot: list[index].slot.startTime,
                            rating: list[index].reviewedByUser == 1
                                ? list[index].userRating * 1.0
                                : 0.0,
                            counterId: list[index].counterId,
                            subscriberId: list[index].subscriberId,
                            subscriberName: list[index].subscriberName,
                            primaryContext: context,
                            latitude: list[index].latitude,
                            longitude: list[index].longitude,
                            review: list[index].userReview,
                          );
                        } else {
                          return ListItemCancelled(
                            name: list[index].subscriberName,
                            location: list[index].address,
                            slot: list[index].slot.startTime,
                            latitude: list[index].latitude,
                            longitude: list[index].longitude,
                          );
                        }
                      }, childCount: list.length));
                    }
                  }
                  return Container();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
