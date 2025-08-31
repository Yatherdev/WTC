import 'package:hive/hive.dart';
import '../../domain/models/invoice.dart';
import '../hive/hive_services.dart';

class InvoiceRepository {
  final box = Hive.box<Invoice>(HiveService.invoicesBox);
  List<Invoice> getAll() => box.values.toList();
  Future<void> add(Invoice invoice) => box.add(invoice);
  Future<void> update(Invoice invoice) => invoice.save();
  Future<void> delete(Invoice invoice) => invoice.delete();
}