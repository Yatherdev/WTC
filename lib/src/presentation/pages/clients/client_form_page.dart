import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../../data/hive/hive_services.dart';
import '../../../domain/models/client.dart';
import '../../providers/providers.dart';

class ClientFormDialog extends ConsumerStatefulWidget {
  const ClientFormDialog({super.key});

  @override
  ConsumerState<ClientFormDialog> createState() => _ClientFormDialogState();
}

class _ClientFormDialogState extends ConsumerState<ClientFormDialog> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('إضافة عميل جديد'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'اسم العميل',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'رقم الهاتف',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), // إغلاق الحوار
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (nameController.text.isNotEmpty) {
              final client = Client(
                name: nameController.text,
                phone: phoneController.text,
                id: '', // يتم تعيينه تلقائيًا بواسطة Hive
              );
              final box = Hive.box<Client>(HiveService.clientsBox);
              await box.add(client);
              ref.invalidate(clientsProvider);
              Navigator.pop(context, true); // إغلاق الحوار مع إرجاع قيمة للتحديث
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('يرجى إدخال اسم العميل')),
              );
            }
          },
          child: const Text('حفظ العميل'),
        ),
      ],
    );
  }
}