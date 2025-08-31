import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/models/purchase.dart';
import '../hive/hive_services.dart';

class PurchaseRepository {
  Box<Purchase> get box => Hive.box<Purchase>(HiveService.purchasesBox);

  List<Purchase> getAll() => box.values.toList();

  Future<void> add(Purchase purchase) async {
    final key = await box.add(purchase);
    final updatedPurchase = purchase..key = key.toString();
    await box.put(key, updatedPurchase);
  }

  Future<void> update(Purchase purchase) async {
    if (purchase.key != null) {
      await box.put(purchase.key, purchase);
    } else {
      throw Exception('Purchase key is null, cannot update');
    }
  }

  Future<void> delete(Purchase purchase) async {
    if (purchase.key != null) {
      await box.delete(purchase.key);
    } else {
      throw Exception('Purchase key is null, cannot delete');
    }
  }
}