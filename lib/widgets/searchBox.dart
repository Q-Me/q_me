import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qme/bloc/home_bloc/home_bloc.dart';
import 'package:qme/model/location.dart';
import 'package:qme/utilities/location.dart';
import 'package:qme/views/set_location.dart';

class SearchBox extends StatelessWidget {
  final ValueNotifier<LocationData> locationChangeNotifier;

  SearchBox({
    @required this.locationChangeNotifier,
  });

  @override
  Widget build(BuildContext context) {
    if (locationChangeNotifier.value != null) {
      return ValueListenableBuilder<LocationData>(
          valueListenable: locationChangeNotifier,
          builder: (context, LocationData value, Widget child) {
            return Center(
              child: GestureDetector(
                onTap: () async {
                  LocationData _locationData = await getLocation(override: false);
                  LocationData _result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SetLocationScreen(
                        initialLocationData: _locationData,
                      ),
                    ),
                  );
                  if (_result == null) {
                    _result = _locationData;
                  } else {
                    updateStoredAddress(_result);
                    
                    BlocProvider.of<HomeBloc>(context).add(
                      SetLocation(
                        _result,
                      ),
                    );
                  }
                },
                child: Container(
                  width: MediaQuery.of(context).size.width - 40,
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
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
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.location_on,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                          ),
                          child: Material(
                            child: Text(
                              '${value.getSimplifiedAddress}',
                              overflow: TextOverflow.fade,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          });
    } else {
      return Center(
              child: GestureDetector(
                onTap: () async {
                  // LocationData _locationData = await getLocation(override: false);
                  // LocationData _result = await Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => SetLocationScreen(
                  //       initialLocationData: _locationData,
                  //     ),
                  //   ),
                  // );
                  // if (_result == null) {
                  //   _result = _locationData;
                  // } else {
                  //   updateStoredAddress(_result);
                    
                  //   BlocProvider.of<HomeBloc>(context).add(
                  //     SetLocation(
                  //       _result,
                  //     ),
                  //   );
                  // }
                },
                child: Container(
                  width: MediaQuery.of(context).size.width - 40,
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
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
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.location_off,
                          color: Colors.red,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                          ),
                          child: Material(
                            child: Text(
                              'Please switch on location services',
                              overflow: TextOverflow.fade,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
    }
  }
}
