import 'package:hive/hive.dart';
part 'client.g.dart';

@HiveType(typeId: 3)
class Client extends HiveObject {
  @HiveField(0)
  String id; // uuid
  @HiveField(1)
  String name;
  @HiveField(2)
  String phone;
  @HiveField(3)
  String? avatarPath;
  @HiveField(4)
  String? notes;

  Client({required this.id, required this.name, required this.phone, this.avatarPath, this.notes});
}