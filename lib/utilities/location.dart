import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:qme/api/app_exceptions.dart';
import 'package:latlong/latlong.dart';

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
  _currentAddress = "${place.locality}, ${place.subAdministrativeArea}";
  return _currentAddress;
}

Future<LatLng> getLocationLatLng() async {
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
  return LatLng(_currentPosition.latitude, _currentPosition.longitude,);
}

Future<String> getAddressFromLatLng(LatLng coords) async {
  List<Placemark> p = await placemarkFromCoordinates(
      coords.latitude, coords.longitude);
  Placemark place = p[0];
  String address = place.locality != '' ? place.locality + ", " + place.subAdministrativeArea : place.subAdministrativeArea;
  return address;
}