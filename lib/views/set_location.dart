import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:qme/model/location.dart';
import 'package:qme/utilities/location.dart';
import 'package:lottie/lottie.dart' as lottie;
import 'package:latlong/latlong.dart';

class SetLocationScreen extends StatefulWidget {
  final LocationData initialLocationData;

  SetLocationScreen({
    @required this.initialLocationData,
  });

  @override
  _SetLocationScreenState createState() => _SetLocationScreenState();
}

class _SetLocationScreenState extends State<SetLocationScreen> {
  MapController _mapController;
  LocationDataNotifier data;
  TextEditingController _editingController;

  @override
  void initState() {
    _mapController = new MapController();
    data = LocationDataNotifier(widget.initialLocationData);
    _editingController = TextEditingController();
    super.initState();
  }

  void getAddressFromCoordsStream(Stream<MapPosition> source) async {
    bool timerEnded = false;
    Timer timer = Timer(
      Duration(milliseconds: 500),
      () {},
    );
    await for (var point in source) {
      if (!timerEnded) {
        data.startLoading();
        timer.cancel();
        timer = new Timer(
          Duration(milliseconds: 500),
          () async {
            data.startLoading();
            LocationData _newLocationData =
                await getCompleteLocationDataFromLatLong(point.center);
            data.endLoading(_newLocationData);
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Theme.of(context).primaryColor,
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'Where do want to save time?',
                  // maxLines: 1,
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Text(
                'Specify a location...',
                // maxLines: 1,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Hero(
                tag: "search bar",
                child: Container(
                  width: MediaQuery.of(context).size.width - 40,
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    boxShadow: [
                      BoxShadow(
                          offset: Offset(0, 0),
                          spreadRadius: 0,
                          blurRadius: 5,
                          color: Colors.grey[700]),
                    ],
                    borderRadius: BorderRadius.all(
                      Radius.circular(
                        10,
                      ),
                    ),
                  ),
                  child: Material(
                    borderRadius: BorderRadius.circular(10),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText:
                            widget.initialLocationData.getSimplifiedAddress,
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontFamily: "AvenirAlt",
                        ),
                        contentPadding: EdgeInsets.all(3),
                        filled: true,
                        border: OutlineInputBorder(
                          borderSide: BorderSide(),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        fillColor: Colors.white,
                        focusColor: Colors.white,
                        prefixIcon: Icon(
                          Icons.search,
                        ),
                      ),
                      controller: _editingController,
                      onTap: () {
                        if (_editingController.text ==
                            widget.initialLocationData.getSimplifiedAddress) {
                          _editingController.clear();
                        }
                      },
                      onSubmitted: (String value) async {
                        _mapController.move(
                          await getCoordinatesFromAddress(value),
                          _mapController.zoom,
                        );
                      },
                    ),
                  ),
                ),
              ),
              Text(
                'or',
                // maxLines: 1,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Expanded(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      clipBehavior: Clip.antiAlias,
                      // height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(
                            10,
                          ),
                        ),
                      ),
                      margin: EdgeInsets.fromLTRB(20, 5, 20, 20),
                      child: FlutterMap(
                        mapController: _mapController,
                        options: new MapOptions(
                          center: widget.initialLocationData.getCoordinates,
                          zoom: 13.0,
                        ),
                        layers: [
                          new TileLayerOptions(
                              urlTemplate:
                                  "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                              subdomains: ['a', 'b', 'c']),
                          new MarkerLayerOptions(
                            markers: [
                              new Marker(
                                width: 150,
                                height: 85,
                                point:
                                    widget.initialLocationData.getCoordinates,
                                builder: (ctx) => new Container(
                                  child: Column(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          color: Colors.white,
                                          border: Border.all(
                                            color:
                                                Theme.of(context).primaryColor,
                                            width: 2,
                                          ),
                                        ),
                                        child: Text("Current location"),
                                        padding: EdgeInsets.all(5),
                                      ),
                                      Icon(
                                        Icons.location_on,
                                        size: 50,
                                        color: Colors.red,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(30),
                      child: FloatingActionButton(
                        child: Icon(Icons.my_location),
                        onPressed: () async {
                          LocationData _locationData =
                              await getLocation(override: true);
                          LatLng currentPos = LatLng(
                            _locationData.latitude,
                            _locationData.longitude,
                          );
                          _mapController.move(currentPos, 13);
                        },
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Icon(Icons.location_on),
                    )
                  ],
                ),
              ),
              FutureBuilder(
                  future: _mapController.onReady,
                  builder: (context, snapshot) {
                    getAddressFromCoordsStream(_mapController.position);
                    return ValueListenableBuilder<LocationData>(
                      valueListenable: data,
                      builder: (context, value, child) {
                        return LocationDetailsBox(
                          child: Text(
                            value.getSimplifiedAddress,
                            overflow: TextOverflow.fade,
                          ),
                          locationData: value,
                          initial: widget.initialLocationData,
                        );
                      },
                    );
                  })
            ],
          ),
        ),
      ),
    );
  }
}

class LocationDetailsBox extends StatelessWidget {
  const LocationDetailsBox({
    Key key,
    @required this.locationData,
    @required this.initial,
    @required this.child,
  }) : super(key: key);

  final LocationData locationData;
  final LocationData initial;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                  height: 48,
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
                  child: Container(padding: EdgeInsets.all(8), child: this.child
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                      //   children: [
                      //     Icon(
                      //       Icons.location_on,
                      //     ),
                      //     SizedBox(
                      //       width: 10,
                      //     ),
                      //     this.child,
                      //     Container(

                      //       child: locationData.loadStatus == LocationData.LOADING
                      //           ? Container(child: lottie.Lottie.asset("assets/loading_anim.json",),)
                      //           : Container(
                      //             width: 70,
                      //           ),
                      //     ),
                      //   ],
                      // ),
                      ),
                ),
              ),
              SizedBox(
                width: 15,
              ),
              Container(
                child: IconButton(
                  icon: Icon(Icons.done),
                  onPressed: () {
                    if (locationData == initial) {
                      Navigator.pop(
                        context,
                        initial,
                      );
                    } else {
                      Navigator.pop(context, locationData);
                    }
                  },
                ),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)),
                margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
              ),
            ],
          ),
        ),
        Positioned(
          right: 70,
          child: locationData.loadStatus == LocationData.LOADING
              ? Container(
                  child: lottie.Lottie.asset("assets/loading_anim.json",
                      width: 70, height: 50),
                )
              : Container(
                  width: 70,
                ),
        )
      ],
      alignment: Alignment.bottomRight,
    );
  }
}
