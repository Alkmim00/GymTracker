// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'muscle_group.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MuscleGroupAdapter extends TypeAdapter<MuscleGroup> {
  @override
  final int typeId = 1;

  @override
  MuscleGroup read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MuscleGroup(
      name: fields[0] as String,
      exercises: (fields[1] as List).cast<Exercise>(),
    );
  }

  @override
  void write(BinaryWriter writer, MuscleGroup obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.exercises);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MuscleGroupAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
