// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'classroom.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ClassroomAdapter extends TypeAdapter<Classroom> {
  @override
  final int typeId = 0;

  @override
  Classroom read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Classroom(
      classId: fields[0] as String,
      className: fields[1] as String,
      description: fields[2] as String,
      creator: fields[3] as String,
      bannerImgPath: fields[4] as String,
      teacherId: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Classroom obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.classId)
      ..writeByte(1)
      ..write(obj.className)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.creator)
      ..writeByte(4)
      ..write(obj.bannerImgPath)
      ..writeByte(5)
      ..write(obj.teacherId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClassroomAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
