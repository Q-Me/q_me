import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qme/bloc/home_bloc/home_bloc.dart';
import 'package:qme/utilities/location.dart';
import 'package:qme/views/set_location.dart';
import 'package:latlong/latlong.dart';

class SearchBox extends StatelessWidget {
  final ValueNotifier<String> setLocation;
  final bool shouldNavigate;

  SearchBox({
    @required this.setLocation,
    @required this.shouldNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: setLocation,
        builder: (context, String value, Widget child) {
          return Center(
            child: GestureDetector(
              onTap: this.shouldNavigate
                  ? () async {
                      LatLng coords = await getLocationLatLng();
                      String chosenAddress = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SetLocationScreen(
                            locationAddress: setLocation,
                            locationCoords: coords,
                          ),
                        ),
                      );
                      BlocProvider.of<HomeBloc>(context).add(
                        SetLocation(
                          chosenAddress,
                        ),
                      );
                    }
                  : () => Navigator.pop(context),
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
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                      ),
                      child: Text(
                        "$value",
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
