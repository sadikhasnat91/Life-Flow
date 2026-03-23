// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_model.dart';

class HabitModelAdapter extends TypeAdapter<HabitModel> {
  @override
  final int typeId = 2;

  @override
  HabitModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      final value = reader.read();
      fields[key] = value;
    }
    return HabitModel(
      id: fields[0] as String,
      title: fields[1] as String,
      icon: fields[2] as String? ?? '⭐',
      completedDates: (fields[3] as List?)?.cast<String>(),
      createdAt: fields[4] as DateTime,
      colorValue: fields[5] as int? ?? 0xFF6C63FF,
      isActive: fields[6] as bool? ?? true,
      reminderTime: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, HabitModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.icon)
      ..writeByte(3)
      ..write(obj.completedDates)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.colorValue)
      ..writeByte(6)
      ..write(obj.isActive)
      ..writeByte(7)
      ..write(obj.reminderTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
