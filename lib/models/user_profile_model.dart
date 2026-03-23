import 'package:hive/hive.dart';

part 'user_profile_model.g.dart';

@HiveType(typeId: 4)
class UserProfileModel extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String? avatarPath;

  @HiveField(2)
  bool isDarkMode;

  @HiveField(3)
  bool notificationsEnabled;

  @HiveField(4)
  DateTime createdAt;

  UserProfileModel({
    this.name = 'User',
    this.avatarPath,
    this.isDarkMode = false,
    this.notificationsEnabled = true,
    required this.createdAt,
  });
}
