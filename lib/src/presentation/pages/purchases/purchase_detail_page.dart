import 'package:flutter/material.dart';
import '../../../domain/models/purchase.dart';
import '../../providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PurchaseDetailsDialog extends ConsumerWidget {
  final Purchase purchase;

  const PurchaseDetailsDialog({super.key, required this.purchase});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      shadowColor: Colors.black,
      backgroundColor: Colors.white,
      title: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const Text(
            'تفاصيل المنتج',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(purchase.date.toLocal().toString().split(' ')[0]),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('إسم الشركه', purchase.sawType),
            _buildDetailRow('المقاس', purchase.size),
            _buildDetailRow('السمك', '${purchase.thickness.toStringAsFixed(2)} مم'),
            _buildDetailRow('العرض', '${purchase.width.toStringAsFixed(2)} مم'),
            _buildDetailRow('الطول', '${purchase.length.toStringAsFixed(2)} م'),
            _buildDetailRow('العدد', '${purchase.quantity}'),
            _buildDetailRow('سعر المتر المكعب', '${purchase.price.toStringAsFixed(2)} ج.م'),
            _buildDetailRow('إجمالى التكعيب', '${purchase.volume.toStringAsFixed(3)} m³'),
            _buildDetailRow('سعر المنتج الإجمالي', '${(purchase.price * purchase.volume).toStringAsFixed(2)} ج.م'),
          ],
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
        onPressed: () async {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Center(child: const Text("تأكيد الحذف")),
            content: const Text("هل أنت متأكد أنك تريد حذف هذا المنتج؟"),
            actions: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text("إلغاء"),
                ),
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: const Text("حذف", style: TextStyle(color: Colors.red)),
                  ),],)
            ],
          );
        },
      );

      if (confirm == true) {
        await ref.read(purchasesProvider.notifier).remove(purchase);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("تم الحذف بنجاح")),
        );
      }
    },
              child: const Text(
                "حذف",
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("إغلاق"),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(value, style: const TextStyle(fontSize: 16)),
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}