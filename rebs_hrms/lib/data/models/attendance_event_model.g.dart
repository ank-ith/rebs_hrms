// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_event_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AttendanceEventModelAdapter extends TypeAdapter<AttendanceEventModel> {
  @override
  final int typeId = 2;

  @override
  AttendanceEventModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AttendanceEventModel(
      eventId: fields[0] as String,
      type: fields[1] as String,
      timestamp: fields[2] as String,
      latitude: fields[3] as double,
      longitude: fields[4] as double,
      syncStatusIndex: fields[5] as int,
      rejectionReason: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, AttendanceEventModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.eventId)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.timestamp)
      ..writeByte(3)
      ..write(obj.latitude)
      ..writeByte(4)
      ..write(obj.longitude)
      ..writeByte(5)
      ..write(obj.syncStatusIndex)
      ..writeByte(6)
      ..write(obj.rejectionReason);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttendanceEventModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
