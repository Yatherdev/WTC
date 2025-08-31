import 'package:calc_wood/src/presentation/pages/purchases/purchases_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/purchase.dart';
import 'add_purchase_dialog.dart';
import '../../providers/providers.dart';

class PurchasesDatesPage extends StatefulWidget {
  const PurchasesDatesPage({Key? key, this.selectedDate}) : super(key: key);
  final DateTime? selectedDate;

  @override
  State<PurchasesDatesPage> createState() => _DatesPageState();
}

class _DatesPageState extends State<PurchasesDatesPage> {
  String searchQuery = "";
  DateTime _currentDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.selectedDate != null) {
      _currentDate = widget.selectedDate!;
    }
  }

  Future<void> _addPurchase(BuildContext context, WidgetRef ref) async {
    showDialog(
      context: context,
      builder: (context) => AddPurchaseDialog(ref: ref),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        try {
          final purchases = ref.watch(purchasesProvider);

          // استخراج التواريخ الفريدة
          final uniqueDates = purchases != null
              ? purchases
              .map((p) => p.date.toIso8601String().split('T')[0])
              .toSet()
              .toList()
              : <String>[];

          uniqueDates.sort((a, b) => b.compareTo(a)); // ترتيب تنازلي

          // فلترة حسب البحث
          final filteredDates =
          uniqueDates.where((date) => date.contains(searchQuery)).toList();

          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: const Text(
                'كشــف الواردات',
                style: TextStyle(color: Colors.black),
              ),
              foregroundColor: Colors.white,
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // مربع البحث
                  TextField(
                    decoration: const InputDecoration(
                      labelText: "البحث",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value.trim();
                      });
                    },
                  ),
                  const SizedBox(height: 10),

                  // قائمة التواريخ
                  Expanded(
                    child: filteredDates.isEmpty
                        ? const Center(
                      child: Text(
                        'لا توجد نتائج مطابقة',
                        style:
                        TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                        : ListView.builder(
                      itemCount: filteredDates.length,
                      itemBuilder: (context, index) {
                        final dateString = filteredDates[index];
                        final selectedDate = DateTime.parse(dateString);
                        return Card(
                          child: ListTile(
                            title: Text(dateString),
                            trailing:
                            const Icon(Icons.arrow_forward_ios_outlined),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PurchasesPage(selectedDate),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => _addPurchase(context, ref),
              child: const Icon(Icons.add),
            ),
          );
        } catch (e) {
          return Scaffold(
            body: Center(
              child: Text(
                'خطأ في التحميل: $e',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }
      },
    );
  }
}