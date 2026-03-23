// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_model.dart';

class NoteModelAdapter extends TypeAdapter<NoteModel> {
  @override
  final int typeId = 3;

  @override
  NoteModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      final value = reader.read();
      fields[key] = value;
    }
    return NoteModel(
      id: fields[0] as String,
      title: fields[1] as String,
      content: fields[2] as String? ?? '',
      createdAt: fields[3] as DateTime,
      updatedAt: fields[4] as DateTime,
      category: fields[5] as String?,
      colorValue: fields[6] as int? ?? 0xFFFFFFFF,
    );
  }

  @override
  void write(BinaryWriter writer, NoteModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.content)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.updatedAt)
      ..writeByte(5)
      ..write(obj.category)
      ..writeByte(6)
      ..write(obj.colorValue);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NoteModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
