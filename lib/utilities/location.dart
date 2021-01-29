import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:qme/api/app_exceptions.dart';
import 'package:latlong/latlong.dart';
import 'package:qme/model/location.dart';
import 'package:qme/services/analytics.dart';

Future<LocationData> getLocationHelper() async {
  bool serviceEnabled;
  LocationPermission permission;
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
  Box box = await Hive.openBox('location');
  LocationData location = LocationData(
    latitude: _currentPosition.latitude,
    longitude: _currentPosition.longitude,
    placeMark: place,
  );
  box.put("location", location);
  return location;
}

Future<LocationData> getLocation({@required bool override}) async {
  Box box = await Hive.openBox('location');
  if (!box.containsKey("location") || override) {
    LocationData location = await getLocationHelper();
    return location;
  }
  LocationData location = box.get("location");
  return location;
}

LocationData getLocationUnsafe() => Hive.box('location').get('location');

Future<Placemark> getAddressFromLatLng(LatLng coords) async {
  List<Placemark> p =
      await placemarkFromCoordinates(coords.latitude, coords.longitude);
  Placemark place = p[0];
  return place;
}

Future<LocationData> getCompleteLocationDataFromLatLong(LatLng _coords) async {
  List<Placemark> p =
      await placemarkFromCoordinates(_coords.latitude, _coords.longitude);
  return LocationData(
    latitude: _coords.latitude,
    longitude: _coords.longitude,
    placeMark: p[0],
  );
}

Future<LatLng> getCoordinatesFromAddress(String address) async {
  List<Location> l = await locationFromAddress(address);
  Location location = l[0];
  return LatLng(
    location.latitude,
    location.longitude,
  );
}

void updateStoredAddress(LocationData newLocationData) {
  Hive.box('location').put('location', newLocationData);
}

void registerLocationAdapter() {
  Hive.registerAdapter(LocationDataAdapter());
  Hive.registerAdapter(PlacemarkAdapter());
}
