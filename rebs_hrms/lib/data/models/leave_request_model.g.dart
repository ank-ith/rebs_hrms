// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leave_request_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LeaveRequestModelAdapter extends TypeAdapter<LeaveRequestModel> {
  @override
  final int typeId = 4;

  @override
  LeaveRequestModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LeaveRequestModel(
      id: fields[0] as String,
      leaveType: fields[1] as String,
      startDate: fields[2] as String,
      endDate: fields[3] as String,
      reason: fields[4] as String,
      status: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, LeaveRequestModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.leaveType)
      ..writeByte(2)
      ..write(obj.startDate)
      ..writeByte(3)
      ..write(obj.endDate)
      ..writeByte(4)
      ..write(obj.reason)
      ..writeByte(5)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LeaveRequestModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
