import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';
import '../../../domain/models/invoice.dart';

class InvoiceEditPage extends ConsumerStatefulWidget {
  final String id;
  const InvoiceEditPage({Key? key, required this.id}) : super(key: key);
  @override
  ConsumerState<InvoiceEditPage> createState() => _State();
}

class _State extends ConsumerState<InvoiceEditPage> {
  late Invoice invoice;
  bool ready = false;
  double discount = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final invs = ref.read(invoicesProvider);
      invoice = invs.firstWhere((i) => i.id == widget.id);
      discount = invoice.discount;
      setState(() => ready = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!ready) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final before = invoice.totalAfterDiscount;
    return Scaffold(
      appBar: AppBar(title: Text('تعديل فاتورة #${invoice.number}')),
      body: ListView(padding: const EdgeInsets.all(12), children: [
        TextFormField(initialValue: invoice.clientId ?? '', decoration: const InputDecoration(labelText: 'عميل'), onChanged: (v) => invoice.clientId = v),
        const SizedBox(height: 8),
        ...invoice.items.map((it) => Card(child: ListTile(title: Text(it.product.name), subtitle: Text('حجم: ${it.volume.toStringAsFixed(4)}'), trailing: Text(it.subtotal.toStringAsFixed(2))))),
        const SizedBox(height: 8),
        TextFormField(initialValue: discount.toString(), decoration: const InputDecoration(labelText: 'خصم'), keyboardType: const TextInputType.numberWithOptions(decimal: true), onChanged: (v) => discount = double.tryParse(v) ?? discount),
        const SizedBox(height: 12),
        FilledButton.icon(onPressed: () async {
          final after = invoice.totalBeforeDiscount - discount;
          final diff = after - before;
          invoice.discount = discount;
          await ref.read(invoicesProvider.notifier).update(invoice);
          if (invoice.paymentType == PaymentType.cash) await ref.read(cashboxProvider.notifier).addAmount(diff);
          if (context.mounted) Navigator.of(context).pop();
        }, icon: const Icon(Icons.save), label: const Text('حفظ'))
      ]),
    );
  }
}