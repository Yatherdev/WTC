import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/models/cachbox.dart';
import '../../domain/models/cachbox.g.dart';
import '../../domain/models/client.g.dart';
import '../../domain/models/product_item.dart';
import '../../domain/models/product_variant.dart';
import '../../domain/models/client.dart';
import '../../domain/models/invoice.dart';
import '../../domain/models/invoice_item.dart';
import '../../domain/models/expense.dart';
import '../../domain/models/purchase.dart';
import '../../domain/models/purchase.g.dart';

class HiveService {
  static const productsBox = 'products_box_v2';
  static const clientsBox = 'clients_box_v1';
  static const invoicesBox = 'invoices_box_v1';
  static const expensesBox = 'expenses_box_v1';
  static const cashboxBox = 'cashbox_box_v1';
  static const purchasesBox = 'purchases_box_v1';
  static const countersBox = 'counters_box_v1';

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(ClientAdapter());
    Hive.registerAdapter(ProductItemAdapter());
    Hive.registerAdapter(ProductVariantAdapter());
    Hive.registerAdapter(InvoiceAdapter());
    Hive.registerAdapter(InvoiceItemAdapter());
    Hive.registerAdapter(ExpenseAdapter());
    Hive.registerAdapter(CashboxAdapter());
    if (!Hive.isAdapterRegistered(9)) {
      Hive.registerAdapter(PurchaseAdapter());
    }

    await Hive.openBox<Client>(clientsBox);
    await Hive.openBox<ProductItem>(productsBox);
    await Hive.openBox<ProductVariant>('product_variants_box_v1');
    await Hive.openBox<Invoice>(invoicesBox);
    await Hive.openBox<InvoiceItem>('invoice_items_box_v1');
    await Hive.openBox<Expense>(expensesBox);
    await Hive.openBox<Cashbox>(cashboxBox);
    if (!Hive.isBoxOpen(HiveService.purchasesBox)) {
      await Hive.openBox<Purchase>(HiveService.purchasesBox);
    }
    await Hive.openBox<int>(countersBox);
  }
}