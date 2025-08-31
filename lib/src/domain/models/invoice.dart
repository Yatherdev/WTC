import 'package:hive/hive.dart';
import 'invoice_item.dart';
part 'invoice.g.dart';

@HiveType(typeId: 8)
enum PaymentType { @HiveField(0) cash, @HiveField(1) credit }

@HiveType(typeId: 4)
class Invoice extends HiveObject {
  @HiveField(0)
  String id; // uuid
  @HiveField(1)
  String number; // متزايد
  @HiveField(2)
  DateTime date;
  @HiveField(3)
  String? clientId;
  @HiveField(4)
  List<InvoiceItem> items;
  @HiveField(5)
  PaymentType paymentType;
  @HiveField(6)
  double discount;
  @HiveField(7)
  bool isPaid;

  Invoice({
    required this.id,
    required this.number,
    required this.date,
    this.clientId,
    required this.items,
    required this.paymentType,
    this.discount = 0,
    this.isPaid = false,
  });

  double get totalBeforeDiscount => items.fold(0.0, (s, e) => s + e.subtotal);
  double get totalAfterDiscount => (totalBeforeDiscount - discount).clamp(0, double.infinity);

  // helper factory for preview (not persisted)
  factory Invoice.tempFrom({required List<InvoiceItem> items, required PaymentType paymentType, double discount = 0, String? clientId}) {
    return Invoice(id: 'temp', number: 'TEMP', date: DateTime.now(), clientId: clientId, items: items, paymentType: paymentType, discount: discount, isPaid: paymentType == PaymentType.cash);
  }
}