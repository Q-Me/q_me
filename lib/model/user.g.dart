// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserDataAdapter extends TypeAdapter<UserData> {
  @override
  final int typeId = 3;

  @override
  UserData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserData(
      id: fields[0] as String,
      name: fields[1] as String,
      isUser: fields[6] as bool,
      accessToken: fields[4] as String,
      refreshToken: fields[5] as String,
      email: fields[2] as String,
      phone: fields[3] as String,
      expiry: fields[9] as DateTime,
      fcmToken: fields[7] as String,
      isGuest: fields[8] as bool,
      password: fields[10] as String,
      idToken: fields[11] as String,
    );
  }

  @override
  void write(BinaryWriter writer, UserData obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.phone)
      ..writeByte(4)
      ..write(obj.accessToken)
      ..writeByte(5)
      ..write(obj.refreshToken)
      ..writeByte(6)
      ..write(obj.isUser)
      ..writeByte(7)
      ..write(obj.fcmToken)
      ..writeByte(8)
      ..write(obj.isGuest)
      ..writeByte(9)
      ..write(obj.expiry)
      ..writeByte(10)
      ..write(obj.password)
      ..writeByte(11)
      ..write(obj.idToken);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
