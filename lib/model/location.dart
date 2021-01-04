import 'package:hive/hive.dart';
import 'package:latlong/latlong.dart';
import 'package:geocoding/geocoding.dart';
part 'location.g.dart';

@HiveType(typeId: 2)
class LocationData extends HiveObject {
  @HiveField(0)
  double latitude;

  @HiveField(1)
  double longitude;

  @HiveField(2)
  Placemark placeMark;
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
