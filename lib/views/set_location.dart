import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:qme/model/location.dart';
import 'package:qme/utilities/location.dart';
import 'package:qme/widgets/searchBox.dart';
import 'package:latlong/latlong.dart';

enum LocationState {
  waiting,
  loading,
  done,
}

class SetLocationScreen extends StatefulWidget {
  final ValueNotifier<String> locationAddress;
  final LatLng locationCoords;

  SetLocationScreen({
    @required this.locationAddress,
    @required this.locationCoords,
  });

  @override
  _SetLocationScreenState createState() => _SetLocationScreenState();
}

class _SetLocationScreenState extends State<SetLocationScreen> {
  MapController _mapController;
  ValueNotifier<String> address = ValueNotifier('');
  LocationData correspondingData;

  @override
  void initState() {
    _mapController = new MapController();
    super.initState();
  }

  void getAddressFromCoordsStream(Stream<MapPosition> source) async {
    bool timerEnded = false;
    Timer timer = Timer(
      Duration(milliseconds: 500),
      () async {
        address.value = "Move the pointer on the map to select that location";
      },
    );
    await for (var point in source) {
      if (!timerEnded) {
        address.value = "loading";
        timer.cancel();
        timer = new Timer(
          Duration(milliseconds: 500),
          () async {
            Placemark _selectedPlace = await getAddressFromLatLng(point.center);
            address.value =
                _selectedPlace.locality == '' || _selectedPlace == null
                    ? _selectedPlace.subAdministrativeArea
                    : _selectedPlace.locality +
                        ', ' +
                        _selectedPlace.subAdministrativeArea;
            correspondingData = LocationData()
            ..latitude = point.center.latitude
            ..longitude = point.center.longitude
            ..placeMark = _selectedPlace;
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
              'Your current location',
              // maxLines: 1,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Hero(
              tag: "search bar",
              child: SearchBox(
                setLocation: widget.locationAddress,
                shouldNavigate: false,
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
                        center: widget.locationCoords,
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
                              point: widget.locationCoords,
                              builder: (ctx) => new Container(
                                child: Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: Colors.white,
                                        border: Border.all(
                                          color: Theme.of(context).primaryColor,
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
                  if (snapshot.connectionState == ConnectionState.done) {
                    getAddressFromCoordsStream(_mapController.position);
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                              ),
                              height: 48,
                              margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
                              child: ValueListenableBuilder(
                                valueListenable: address,
                                builder: (context, value, child) {
                                  if (value == "loading") {
                                    return LocationDetailsBox(
                                      child: Theme(
                                        data: ThemeData(
                                          accentColor:
                                              Theme.of(context).primaryColor,
                                        ),
                                        child: LinearProgressIndicator(),
                                      ),
                                    );
                                  }
                                  if (value == '') {
                                    return LocationDetailsBox(
                                      child: Text("Unidentifiable Address"),
                                    );
                                  } else {
                                    return LocationDetailsBox(
                                      child: Text(value),
                                    );
                                  }
                                },
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
                                if (address.value ==
                                    "Move the pointer on the map to select that location") {
                                  Navigator.pop(
                                      context, [widget.locationAddress.value, correspondingData]);
                                } else {
                                  Navigator.pop(context, [address.value, correspondingData]);
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
                    );
                  } else {
                    return LocationDetailsBox(
                      child: Text("Setting up Maps, please wait"),
                    );
                  }
                })
          ],
        ),
      ),
    );
  }
}

class LocationDetailsBox extends StatelessWidget {
  final Widget child;

  LocationDetailsBox({@required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      child: Center(
        child: child,
      ),
    );
  }
}
