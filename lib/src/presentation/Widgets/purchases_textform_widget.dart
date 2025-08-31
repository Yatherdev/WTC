import 'package:flutter/material.dart';

class PurchasesTextformWidget extends StatelessWidget {
  final TextEditingController sawTypeController;
  final TextEditingController thicknessController;
  final TextEditingController widthController;
  final TextEditingController lengthController;
  final TextEditingController quantityController;
  final TextEditingController directVolumeController;
  final TextEditingController priceController;
  final TextEditingController sizeController;

  final bool useDirectVolume;
  final ValueChanged<bool> onToggleUseDirectVolume;

  const PurchasesTextformWidget({
    super.key,
    required this.sawTypeController,
    required this.thicknessController,
    required this.widthController,
    required this.lengthController,
    required this.quantityController,
    required this.directVolumeController,
    required this.priceController,
    required this.sizeController,
    required this.useDirectVolume,
    required this.onToggleUseDirectVolume,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 400,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 130,
                  child: TextField(
                    controller: sawTypeController,
                    decoration: const InputDecoration(
                      labelText: 'إسم المنشار',
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: 130,
                  child: TextField(
                    keyboardType: TextInputType.text,
                    controller: sizeController,
                    decoration: const InputDecoration(labelText: 'المقاس'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SwitchListTile(
            title: const Text('إدخال التكعيب مباشرة'),
            value: useDirectVolume,
            onChanged: onToggleUseDirectVolume,
          ),
          if (!useDirectVolume) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: 130,
                  child: TextField(
                    controller: thicknessController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'السمك (مم)'),
                  ),
                ),
                SizedBox(width: 130,
                  child: TextField(
                    controller: widthController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'العرض (مم)'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: 130,
                  child: TextField(
                    controller: lengthController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'الطول (مم)'),
                  ),
                ),
                SizedBox(width: 130,
                  child: TextField(
                    controller: quantityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'العدد'),
                  ),
                ),
              ],
            ),
          ] else ...[
            TextField(
              controller: directVolumeController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'التكعيب المباشر (m³)',
              ),
            ),
          ],
          const SizedBox(height: 10),
          TextField(
            controller: priceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'سعر المتر المكعب (ج.م)',
            ),
          ),
        ],
      ),
    );
  }
}