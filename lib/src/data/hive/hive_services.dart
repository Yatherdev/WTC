import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/models/cachbox.dart';
import '../../domain/models/client.dart';
import '../../domain/models/product_item.dart';
import '../../domain/models/product_variant.dart';
import '../../domain/models/invoice.dart';
import '../../domain/models/invoice_item.dart';
import '../../domain/models/expense.dart';
import '../../domain/models/purchase.dart';

class HiveService {
  static const productsBox = 'products_box_v2';
  static const clientsBox = 'clients_box_v1';
  static const invoicesBox = 'invoices_box_v1';
  static const invoiceItemsBox = 'invoice_items_box_v1';
  static const expensesBox = 'expenses_box_v1';
  static const cashboxBox = 'cashbox_box_v1';
  static const purchasesBox = 'purchases_box_v1';
  static const countersBox = 'counters_box_v1';

  static Future<void> init() async {
    await Hive.initFlutter();
    ensureAdapters();

    // Open all boxes in correct order
    await _openBoxSafe<Client>(clientsBox);
    await _openBoxSafe<ProductItem>(productsBox);
    await _openBoxSafe<ProductVariant>('product_variants_box_v1');
    await _openBoxSafe<InvoiceItem>(invoiceItemsBox);
    await _openBoxSafe<Invoice>(invoicesBox);
    await _openBoxSafe<Expense>(expensesBox);
    await _openBoxSafe<Cashbox>(cashboxBox);
    await _openBoxSafe<Purchase>(purchasesBox);
    await _openBoxSafe<int>(countersBox);
  }

  static Future<Box<T>> _openBoxSafe<T>(String name) async {
    try {
      if (Hive.isBoxOpen(name)) {
        return Hive.box<T>(name);
      }
      return await Hive.openBox<T>(name);
    } catch (e) {
      // If box is corrupted or unreadable, recreate it
      try {
        await Hive.deleteBoxFromDisk(name);
      } catch (_) {}
      return await Hive.openBox<T>(name);
    }
  }

  static void ensureAdapters() {
    if (!Hive.isAdapterRegistered(ClientAdapter().typeId)) {
      Hive.registerAdapter(ClientAdapter());
    }
    if (!Hive.isAdapterRegistered(ProductItemAdapter().typeId)) {
      Hive.registerAdapter(ProductItemAdapter());
    }
    if (!Hive.isAdapterRegistered(ProductVariantAdapter().typeId)) {
      Hive.registerAdapter(ProductVariantAdapter());
    }
    if (!Hive.isAdapterRegistered(InvoiceAdapter().typeId)) {
      Hive.registerAdapter(InvoiceAdapter());
    }
    // Register PaymentType enum adapter required by Invoice
    if (!Hive.isAdapterRegistered(8)) {
      Hive.registerAdapter(PaymentTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(InvoiceItemAdapter().typeId)) {
      Hive.registerAdapter(InvoiceItemAdapter());
    }
    if (!Hive.isAdapterRegistered(ExpenseAdapter().typeId)) {
      Hive.registerAdapter(ExpenseAdapter());
    }
    if (!Hive.isAdapterRegistered(CashboxAdapter().typeId)) {
      Hive.registerAdapter(CashboxAdapter());
    }
    if (!Hive.isAdapterRegistered(PurchaseAdapter().typeId)) {
      Hive.registerAdapter(PurchaseAdapter());
    }
  }
}