import 'package:hive/hive.dart';

import '../hive/hive_services.dart';
class CountersRepository {
  final box = Hive.box<int>(HiveService.countersBox);
  int nextInvoiceNumber() {
    const key = 'invoice_number';
    final current = box.get(key, defaultValue: 0) ?? 0;
    box.put(key, current + 1);
    return current + 1;
  }
}