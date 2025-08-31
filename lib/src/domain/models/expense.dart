import 'package:hive/hive.dart';

part 'expense.g.dart';

@HiveType(typeId: 6)
class Expense extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  double amount;
  @HiveField(2)
  String purpose;
  @HiveField(3)
  DateTime date;

  Expense({
    required this.id,
    required this.amount,
    required this.purpose,
    required this.date,
  });
}
