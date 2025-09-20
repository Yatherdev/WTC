import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/purchase.dart';
import '../../Widgets/textForm_widget.dart';
import '../../providers/providers.dart';


class AddPurchaseDialog extends StatefulWidget {
  final WidgetRef ref;

  const AddPurchaseDialog({super.key, required this.ref});

  @override
  State<AddPurchaseDialog> createState() => _AddPurchaseDialogState();
}

class _AddPurchaseDialogState extends State<AddPurchaseDialog> {
  final TextEditingController sawTypeController = TextEditingController();
  final TextEditingController sizeController = TextEditingController();
  final TextEditingController thicknessController = TextEditingController();
  final TextEditingController widthController = TextEditingController();
  final TextEditingController lengthController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController directVolumeController = TextEditingController();
  final TextEditingController numberController = TextEditingController();
  bool useDirectVolume = false;
  late final GlobalKey<FormState> formKey;

  @override
  void dispose() {
    sawTypeController.dispose();
    sizeController.dispose();
    thicknessController.dispose();
    widthController.dispose();
    lengthController.dispose();
    quantityController.dispose();
    priceController.dispose();
    directVolumeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Center(child: Text('إضافة وارد جديد')),
      content: TextFormWidget(
        useDirectVolume: useDirectVolume,
        onToggleUseDirectVolume: (val) {
          setState(() {
            useDirectVolume = val;
          });
        },
        sawTypeController: sawTypeController,
        thicknessController: thicknessController,
        widthController: widthController,
        lengthController: lengthController,
        quantityController: quantityController,
        directVolumeController: directVolumeController,
        priceController: priceController,
        sizeController: sizeController,
        numberController: numberController,
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        const SizedBox(width: 70),
        FilledButton(
          onPressed: () async {
            if (sawTypeController.text.isNotEmpty &&
                priceController.text.isNotEmpty &&
                sizeController.text.isNotEmpty &&
                (!useDirectVolume
                    ? thicknessController.text.isNotEmpty &&
                    widthController.text.isNotEmpty &&
                    lengthController.text.isNotEmpty &&
                    quantityController.text.isNotEmpty
                    : directVolumeController.text.isNotEmpty && numberController.text.isNotEmpty))
            {
              final double price = double.tryParse(priceController.text) ?? 0.0;
              final double volume = useDirectVolume
                  ? (double.tryParse(directVolumeController.text) ?? 0.0)
                  : ((double.tryParse(thicknessController.text) ?? 0.0) *
                  (double.tryParse(widthController.text) ?? 0.0) *
                  (double.tryParse(lengthController.text) ?? 0.0) *
                  (double.tryParse(quantityController.text) ?? 0.0)) /
                  1000000;

              final purchase = Purchase(
                id: UniqueKey().toString(),
                sawType: sawTypeController.text,
                thickness: useDirectVolume ? 0.0 : (double.tryParse(thicknessController.text) ?? 0.0),
                width: useDirectVolume ? 0.0 : (double.tryParse(widthController.text) ?? 0.0),
                length: useDirectVolume ? 0.0 : (double.tryParse(lengthController.text) ?? 0.0),
                quantity: useDirectVolume ? 0 : (int.tryParse(quantityController.text) ?? 0),
                number: double.tryParse(numberController.text) ?? 0,
                volume: volume,
                directVolume: useDirectVolume ? (double.tryParse(directVolumeController.text) ?? 0.0) : 0.0,
                price: price,
                date: DateTime.now(),
                size: sizeController.text,
              );

              try {
                final notifier = widget.ref.read(purchasesProvider.notifier);
                await notifier.add(purchase); // ✅ مش محتاج key
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تمت الإضافة بنجاح')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(' خطأ أثناء الإضافة: $e')),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('يرجى إدخال جميع الحقول المطلوبة'),
                ),
              );
            }
          },
          child: const Text('حفظ'),
        ),
      ],
    );
  }
}