import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:latlong/latlong.dart';
import 'package:geocoding/geocoding.dart';
part 'location.g.dart';

@HiveType(typeId: 2)
class LocationData extends HiveObject with EquatableMixin {
  static const String INITIAL = "NOLOAD";
  static const String DONE = "DONE";
  static const String LOADING = "LOADING";

  LocationData({
    @required this.latitude,
    @required this.longitude,
    @required this.placeMark,
    this.loadStatus = INITIAL,
  });

  @HiveField(0)
  double latitude;

  @HiveField(1)
  double longitude;

  @HiveField(2)
  Placemark placeMark;

  String loadStatus;

  String get getSimplifiedAddress {
    List<String> _returnString = [];
    if (placeMark.locality.length != 0) {
      _returnString.add(placeMark.locality);
    }
    if (placeMark.subAdministrativeArea != "") {
      _returnString.add(placeMark.subAdministrativeArea);
    }
    if (placeMark.administrativeArea.length != 0) {
      _returnString.add(placeMark.administrativeArea);
    }

    if (_returnString.length >= 2) {
      if (_returnString[0] == _returnString[1]) {
        if (placeMark.thoroughfare.length != 0) {
          _returnString[0] = placeMark.thoroughfare;
          return placeMark.thoroughfare +
              ", " +
              (placeMark.subLocality.length != 0
                  ? placeMark.subLocality + ", " + _returnString[1]
                  : _returnString[1]);
        } else {
          return "Unknown location in " + _returnString[1];
        }
      }
      String answer = _returnString[0] + ", " + _returnString[1];
      return answer;
    } else {
      return _returnString[0];
    }
  }

  String get getApiAddress => placeMark.subAdministrativeArea;

  LatLng get getCoordinates => LatLng(latitude, longitude);

  Map<String, dynamic> get getAddressJsonComplete => placeMark.toJson();

  String get getAddressComplete => placeMark.toString();

  @override
  List<Object> get props => [latitude, longitude, loadStatus];
}

class LocationDataNotifier extends ValueNotifier<LocationData> {
  LocationDataNotifier(LocationData value) : super(value);

  void startLoading() {
    value = LocationData(
      latitude: value.latitude,
      longitude: value.longitude,
      placeMark: value.placeMark,
      loadStatus: LocationData.LOADING,
    );
    notifyListeners();
  }

  void endLoading(LocationData _newValue) {
    value = _newValue;
    value.loadStatus = LocationData.DONE;
    notifyListeners();
  }
}

class PlacemarkAdapter extends TypeAdapter<Placemark> {
  @override
  Placemark read(BinaryReader reader) {
    return Placemark(
      name: reader.read(),
      street: reader.read(),
      isoCountryCode: reader.read(),
      country: reader.read(),
      postalCode: reader.read(),
      administrativeArea: reader.read(),
      subAdministrativeArea: reader.read(),
      locality: reader.read(),
      subLocality: reader.read(),
      thoroughfare: reader.read(),
      subThoroughfare: reader.read(),
    );
  }

  @override
  int get typeId => 1;

  @override
  void write(BinaryWriter writer, Placemark obj) {
    writer.write(obj.name);
    writer.write(obj.street);
    writer.write(obj.isoCountryCode);
    writer.write(obj.country);
    writer.write(obj.postalCode);
    writer.write(obj.administrativeArea);
    writer.write(obj.subAdministrativeArea);
    writer.write(obj.locality);
    writer.write(obj.subLocality);
    writer.write(obj.thoroughfare);
    writer.write(obj.subThoroughfare);
  }
}
