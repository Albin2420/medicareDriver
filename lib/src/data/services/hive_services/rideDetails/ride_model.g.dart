// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ride_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RideModelAdapter extends TypeAdapter<RideModel> {
  @override
  final int typeId = 1;

  @override
  RideModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RideModel(
      rideId: fields[0] as int,
      riderName: fields[1] as String,
      riderMobile: fields[2] as String,
      pickupLatitude: fields[3] as double,
      pickupLongitude: fields[4] as double,
      pickupLandmark: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, RideModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.rideId)
      ..writeByte(1)
      ..write(obj.riderName)
      ..writeByte(2)
      ..write(obj.riderMobile)
      ..writeByte(3)
      ..write(obj.pickupLatitude)
      ..writeByte(4)
      ..write(obj.pickupLongitude)
      ..writeByte(5)
      ..write(obj.pickupLandmark);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RideModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
