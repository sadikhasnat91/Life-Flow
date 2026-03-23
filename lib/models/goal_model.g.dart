// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal_model.dart';

class GoalModelAdapter extends TypeAdapter<GoalModel> {
  @override
  final int typeId = 1;

  @override
  GoalModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      final value = reader.read();
      fields[key] = value;
    }
    return GoalModel(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String? ?? '',
      targetDate: fields[3] as DateTime,
      isCompleted: fields[4] as bool? ?? false,
      createdAt: fields[5] as DateTime,
      milestones: (fields[6] as List?)?.cast<String>(),
      milestoneCompleted: (fields[7] as List?)?.cast<bool>(),
    );
  }

  @override
  void write(BinaryWriter writer, GoalModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.targetDate)
      ..writeByte(4)
      ..write(obj.isCompleted)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.milestones)
      ..writeByte(7)
      ..write(obj.milestoneCompleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
