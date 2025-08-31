import 'package:hive/hive.dart';

import '../../domain/models/expense.dart';
import '../hive/hive_services.dart';

class ExpenseRepository {
  final box = Hive.box<Expense>(HiveService.expensesBox);
  List<Expense> getAll() => box.values.toList();
  Future<void> add(Expense expense) => box.add(expense);
  Future<void> update(Expense expense) => expense.save();
  Future<void> delete(Expense expense) => expense.delete();
}