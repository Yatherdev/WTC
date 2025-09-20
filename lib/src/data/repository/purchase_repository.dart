import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/models/purchase.dart';
import '../hive/hive_services.dart';

class PurchaseRepository {
  Box<Purchase> get box => Hive.box<Purchase>(HiveService.purchasesBox);

  Future<Box<Purchase>> _ensureBoxOpened() async {
    if (!Hive.isBoxOpen(HiveService.purchasesBox)) {
      return await Hive.openBox<Purchase>(HiveService.purchasesBox);
    }
    return Hive.box<Purchase>(HiveService.purchasesBox);
  }

  Future<List<Purchase>> getAll() async {
    final targetBox = await _ensureBoxOpened();
    return targetBox.values.toList();
  }

  Future<void> add(Purchase purchase) async {
    final targetBox = await _ensureBoxOpened();
    await targetBox.add(purchase);
  }

  Future<void> update(Purchase purchase) async {
    await _ensureBoxOpened();
    if (purchase.isInBox) {
      await purchase.save();
    } else {
      throw Exception('Purchase is not in box, cannot update');
    }
  }

  Future<void> delete(Purchase purchase) async {
    await _ensureBoxOpened();
    if (purchase.isInBox) {
      await purchase.delete();
    } else {
      throw Exception('Purchase is not in box, cannot delete');
    }
  }
}