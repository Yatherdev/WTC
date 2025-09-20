import 'package:calc_wood/src/core/theme/app_theme.dart';
import 'package:calc_wood/src/presentation/pages/purchases/purchase_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../domain/models/purchase.dart';
import '../../Widgets/textForm_widget.dart';
import '../../providers/providers.dart';

class PurchasesPage extends ConsumerStatefulWidget {
  const PurchasesPage(this.selectedDate, {super.key});

  final DateTime? selectedDate;

  @override
  ConsumerState<PurchasesPage> createState() => _PurchasesPageState();
}

class _PurchasesPageState extends ConsumerState<PurchasesPage> {
  final TextEditingController sawTypeController = TextEditingController();
  final TextEditingController sizeController = TextEditingController();
  final TextEditingController thicknessController = TextEditingController();
  final TextEditingController widthController = TextEditingController();
  final TextEditingController lengthController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController directVolumeController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  final TextEditingController numberController = TextEditingController();


  bool useDirectVolume = false;

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
    searchController.dispose();
    super.dispose();
  }

  void _openAddDialog() {
    showDialog(
      context: context,
      builder:
          (_) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Center(child: Text('إضافة وارد جديد')),
                  content: TextFormWidget(
                    sawTypeController: sawTypeController,
                    sizeController: sizeController,
                    thicknessController: thicknessController,
                    widthController: widthController,
                    lengthController: lengthController,
                    quantityController: quantityController,
                    priceController: priceController,
                    directVolumeController: directVolumeController,
                    useDirectVolume: useDirectVolume,
                    numberController: numberController,
                    onToggleUseDirectVolume: (val) {
                      setState(() {
                        useDirectVolume = val;
                      });
                    },
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
                                ? (thicknessController.text.isNotEmpty &&
                                    widthController.text.isNotEmpty &&
                                    lengthController.text.isNotEmpty &&
                                    quantityController.text.isNotEmpty)
                                : directVolumeController.text.isNotEmpty && numberController.text.isNotEmpty)) {
                          final double price = double.tryParse(priceController.text) ?? 0.0;
                          final double volume =
                              useDirectVolume
                                  ? (double.tryParse(directVolumeController.text,) ?? 0.0)
                                  : ((double.tryParse(thicknessController.text,) ?? 0.0) *
                                          (double.tryParse(widthController.text,) ?? 0.0) *
                                          (double.tryParse(lengthController.text,) ?? 0.0) *
                                          (double.tryParse(quantityController.text,) ?? 0.0)) / 1000000;

                          final purchase = Purchase(
                            id: UniqueKey().toString(),
                            sawType: sawTypeController.text,
                            thickness: useDirectVolume ? 0.0
                                    : (double.tryParse(
                                          thicknessController.text,
                                        ) ??
                                        0.0),
                            width:
                                useDirectVolume
                                    ? 0.0
                                    : (double.tryParse(widthController.text) ??
                                        0.0),
                            length:
                                useDirectVolume
                                    ? 0.0
                                    : (double.tryParse(lengthController.text) ??
                                        0.0),
                            quantity:
                                useDirectVolume
                                    ? 0
                                    : (int.tryParse(quantityController.text) ??
                                        0),
                            number:
                            useDirectVolume
                                ? 0
                                : (double.tryParse(numberController.text) ??
                                0),
                            volume: volume,
                            directVolume:
                                useDirectVolume
                                    ? (double.tryParse(
                                          directVolumeController.text,
                                        ) ??
                                        0.0)
                                    : 0.0,
                            price: price,
                            date: widget.selectedDate ?? DateTime.now(),
                            size: sizeController.text,
                          );

                          try {
                            final notifier = ref.read(
                              purchasesProvider.notifier,
                            );
                            await notifier.add(purchase);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('تمت الإضافة بنجاح'),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('خطأ أثناء الإضافة: $e')),
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
                      child: const Text('إضافة'),
                    ),
                  ],
                ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final purchases = ref.watch(purchasesProvider);

    // فلترة المشتريات حسب التاريخ المحدد والبحث
    final filteredPurchases =
        purchases
            .where(
              (purchase) =>
                  (widget.selectedDate == null ||
                      purchase.date.toIso8601String().split('T')[0] ==
                          widget.selectedDate!.toIso8601String().split(
                            'T',
                          )[0]) &&
                  (purchase.sawType.toLowerCase().contains(
                        searchController.text.toLowerCase(),
                      ) ||
                      purchase.size.toLowerCase().contains(
                        searchController.text.toLowerCase(),
                      )),
            )
            .toList();
    final double totalVolume = filteredPurchases.fold(
      0.0,
          (sum, purchase) => sum + purchase.volume,
    );
    return Scaffold(
      appBar: AppBar(title: Text('الــــوارد'), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: 'بحث',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: double.infinity,
              height: 60,
              child: Card(
                elevation: 10,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment:MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      widget.selectedDate!.toLocal().toString().split(' ')[0],
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 100,),
                    IconButton(
                      onPressed: () => _openAddDialog(),
                      icon: Icon(Icons.add,color: Colors.blue[900],),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child:
                ListView.builder(
                      itemCount: filteredPurchases.length,
                      itemBuilder: (context, index) {
                        final purchase = filteredPurchases[index];
                        return Column(
                          children: [
                            Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              child: ListTile(
                                leading: ClipOval(child: Image.asset("assets/images/sca.png")),
                                title: Text('${purchase.size}'),
                                trailing: const Icon(Icons.arrow_forward_ios_outlined, color: Colors.blue),


                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder:
                                        (context) => PurchaseDetailsDialog(
                                          purchase: purchase,
                                        ),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
          ),
          Container(
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: AppColors.green5,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(20)
            ),
            width: double.infinity,
            height: 50,
            child: Center(child: Text("  إجمالى التكعيب  :  ${totalVolume.toStringAsFixed(2)}",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 15.sp),),),
          ),
        ],
      ),
    );
  }
}
