import 'package:hive/hive.dart';
part 'cachbox.g.dart';

@HiveType(typeId: 7)
class Cashbox extends HiveObject {
  @HiveField(0)
  double balance;
  Cashbox({this.balance = 0});
}