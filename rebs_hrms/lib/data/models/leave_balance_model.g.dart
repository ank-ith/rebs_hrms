// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leave_balance_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LeaveBalanceModelAdapter extends TypeAdapter<LeaveBalanceModel> {
  @override
  final int typeId = 3;

  @override
  LeaveBalanceModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LeaveBalanceModel(
      casualLeave: fields[0] as int,
      sickLeave: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, LeaveBalanceModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.casualLeave)
      ..writeByte(1)
      ..write(obj.sickLeave);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LeaveBalanceModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
