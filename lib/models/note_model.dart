import 'package:hive/hive.dart';

part 'note_model.g.dart';

@HiveType(typeId: 3)
class NoteModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String content;

  @HiveField(3)
  DateTime createdAt;

  @HiveField(4)
  DateTime updatedAt;

  @HiveField(5)
  String? category;

  @HiveField(6)
  int colorValue;

  NoteModel({
    required this.id,
    required this.title,
    this.content = '',
    required this.createdAt,
    required this.updatedAt,
    this.category,
    this.colorValue = 0xFFFFFFFF,
  });
}
