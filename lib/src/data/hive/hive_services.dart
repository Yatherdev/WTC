import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/models/cachbox.dart';
import '../../domain/models/cachbox.g.dart';
import '../../domain/models/client.g.dart';
import '../../domain/models/product_item.dart';
import '../../domain/models/client.dart';
import '../../domain/models/invoice.dart';
import '../../domain/models/invoice_item.dart';
import '../../domain/models/expense.dart';
import '../../domain/models/purchase.dart';
import '../../domain/models/product_variant.dart';
import '../../domain/models/purchase.g.dart';

class HiveService {
  static const String productsBox = 'productsBox';
  static const String clientsBox = 'clientsBox';
  static const String invoicesBox = 'invoicesBox';
  static const String expensesBox = 'expensesBox';
  static const String countersBox = 'countersBox';
  static const String cashboxBox = 'cashboxBox';
  static const String purchasesBox = 'purchasesBox';

  static Future<void> init() async {
    try {
      print('Starting Hive initialization...');
      await Hive.initFlutter();
      Hive.registerAdapter(ProductItemAdapter());
      Hive.registerAdapter(ProductVariantAdapter());
      Hive.registerAdapter(ClientAdapter());
      Hive.registerAdapter(InvoiceAdapter());
      Hive.registerAdapter(InvoiceItemAdapter());
      Hive.registerAdapter(ExpenseAdapter());
      Hive.registerAdapter(CashboxAdapter());
      Hive.registerAdapter(PurchaseAdapter());
      Hive.registerAdapter(PaymentTypeAdapter());
      await Hive.openBox<ProductItem>(productsBox);
      await Hive.openBox<Client>(clientsBox);
      await Hive.openBox<Invoice>(invoicesBox);
      await Hive.openBox<Expense>(expensesBox);
      await Hive.openBox<int>(countersBox);
      await Hive.openBox<Cashbox>(cashboxBox);
      await Hive.openBox<Purchase>(purchasesBox);
      print('Hive initialization completed');
    } catch (e) {
      print('Error in Hive initialization: $e');
      rethrow;
    }
  }
}