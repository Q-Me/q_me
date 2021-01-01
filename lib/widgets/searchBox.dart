import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:qme/api/app_exceptions.dart';
import 'package:qme/bloc/home_bloc/home_bloc.dart';
import 'package:qme/utilities/logger.dart';

enum LocationFilterState {
  off,
  on,
  loading,
  error,
}

class SearchBox extends StatefulWidget {
  final String initialAddress;
  SearchBox({
    Key key,
    @required this.initialAddress,
  }) : super(key: key);

  @override
  _SearchBoxState createState() => _SearchBoxState();
}

class _SearchBoxState extends State<SearchBox> {
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialAddress);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<String> getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;
    String _currentAddress = '';
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error(
        GetLocationException(
          'Please switch on Location services',
        ),
      );
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        GetLocationException(
          'Location permission has been permanently denied for this Application',
        ),
      );
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return Future.error(
          GetLocationException(
            'Location permissions are denied (actual value: $permission).',
          ),
        );
      }
    }

    Position _currentPosition = await Geolocator.getCurrentPosition();
    List<Placemark> p = await placemarkFromCoordinates(
        _currentPosition.latitude, _currentPosition.longitude);
    Placemark place = p[0];
    _currentAddress = "${place.locality}";
    return _currentAddress;
  }

  final FocusNode _searchFocus = FocusNode();
  LocationFilterState state = LocationFilterState.on;
  TextEditingController _controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width - 40,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              offset: Offset(0, 10),
              // spreadRadius: 10,
              blurRadius: 20,
              color: Colors.black26,
            )
          ]),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _controller,
              focusNode: _searchFocus,
              style: TextStyle(fontSize: 18),
              textInputAction: TextInputAction.search,
              onFieldSubmitted: (value) {
                BlocProvider.of<HomeBloc>(context).add(SetLocation(value));
                logger.i("setting location from serach");
              },
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search by location',
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              ),
              onEditingComplete: () {
                _searchFocus.unfocus();
              },
            ),
          ),
          // Lottie.asset('assets/location_pin.json', width: 100, height: 50)
          IconButton(
            icon: state == LocationFilterState.loading
                ? CircularProgressIndicator(
                    strokeWidth: 3.0,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.grey,
                    ),
                  )
                : state == LocationFilterState.off ||
                        state == LocationFilterState.error
                    ? Icon(
                        Icons.location_off,
                        color: state == LocationFilterState.error
                            ? Colors.red[400]
                            : Colors.grey,
                      )
                    : Icon(
                        Icons.location_on,
                        color: Theme.of(context).primaryColor,
                      ),
            onPressed: () async {
              _searchFocus.unfocus();
              if (state == LocationFilterState.on) {
                logger.i("setting location from onpressed and turning off");
                BlocProvider.of<HomeBloc>(context).add(SetLocation(''));
                setState(() {
                  _controller.text = '';
                  state = LocationFilterState.off;
                });
              } else {
                setState(() {
                  state = LocationFilterState.loading;
                });
                String address = '';
                try {
                  address = await getLocation();
                } on GetLocationException catch (e) {
                  setState(() {
                    state = LocationFilterState.error;
                  });
                  Scaffold.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        e.toString(),
                      ),
                    ),
                  );
                } catch (e) {
                  setState(() {
                    state = LocationFilterState.error;
                  });
                  Scaffold.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          "An unknown error occurred while getting your location, please try refreshing"),
                    ),
                  );
                }
                if (state != LocationFilterState.error) {
                  logger.i(
                      "setting location from onpressed and turning location on");
                  BlocProvider.of<HomeBloc>(context).add(SetLocation(address));
                  setState(() {
                    _controller.text = address;
                    state = LocationFilterState.on;
                  });
                }
              }
            },
          )
        ],
      ),
    );
  }
}
