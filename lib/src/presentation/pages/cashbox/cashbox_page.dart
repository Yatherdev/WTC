import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';

class CashboxPage extends ConsumerWidget {
  const CashboxPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cashbox = ref.watch(cashboxProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('الخزنة'),centerTitle: true,),
      body: Center(child: Text('الرصيد: ${cashbox.balance.toStringAsFixed(2)} ج.م')),
    );
  }
}