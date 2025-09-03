import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/models/purchase.dart';
import '../../domain/models/purchase.g.dart';
import '../hive/hive_services.dart';

class PurchaseRepository {
  Box<Purchase> get box => Hive.box<Purchase>(HiveService.purchasesBox);

  Future<Box<Purchase>> _ensureAdapterAndBox() async {
    if (!Hive.isAdapterRegistered(9)) {
      Hive.registerAdapter(PurchaseAdapter());
    }
    if (!Hive.isBoxOpen(HiveService.purchasesBox)) {
      return await Hive.openBox<Purchase>(HiveService.purchasesBox);
    }
    return Hive.box<Purchase>(HiveService.purchasesBox);
  }

  Future<List<Purchase>> getAll() async {
    final targetBox = await _ensureAdapterAndBox();
    return targetBox.values.toList();
  }

  Future<void> add(Purchase purchase) async {
    final targetBox = await _ensureAdapterAndBox();
    await targetBox.add(purchase);
    // ✅ مش محتاج تعمل put تاني
  }

  Future<void> update(Purchase purchase) async {
    await _ensureAdapterAndBox();
    if (purchase.isInBox) {
      await purchase.save();
      // ✅ save هيعمل update باستخدام key اللي عند Hive
    } else {
      throw Exception('Purchase is not in box, cannot update');
    }
  }

  Future<void> delete(Purchase purchase) async {
    await _ensureAdapterAndBox();
    if (purchase.isInBox) {
      await purchase.delete();
      // ✅ delete هيحذف باستخدام المفتاح اللي مع Hive
    } else {
      throw Exception('Purchase is not in box, cannot delete');
    }
  }
}