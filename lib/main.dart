import 'package:calc_wood/src/data/hive/hive_services.dart';
import 'package:calc_wood/src/domain/models/invoice.dart';
import 'package:calc_wood/src/presentation/pages/invoices/invoice_confirmation.dart';
import 'package:calc_wood/src/presentation/pages/invoices/invoice_edite_page.dart';
import 'package:calc_wood/src/presentation/pages/invoices/invoice_list_page.dart';
import 'package:calc_wood/src/presentation/pages/main_menu/main_menu_page.dart';
import 'package:calc_wood/src/presentation/pages/products/product_form_page.dart';
import 'package:calc_wood/src/presentation/pages/products/product_list_page.dart';
import 'package:calc_wood/src/presentation/pages/purchases/purchases_dates_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:hive/hive.dart';
import 'src/core/theme/app_theme.dart';
import 'src/presentation/pages/reports/daily_journal_page.dart';
import 'src/presentation/pages/invoices/invoice_form_page.dart';
import 'src/presentation/pages/clients/client_detail_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    print('Initializing Hive...');
    await HiveService.init();
    print('Hive initialized successfully');
  } catch (e) {
    print('Error initializing Hive: $e');
  }
  runApp(const ProviderScope(child: WoodApp()));
}

class WoodApp extends ConsumerStatefulWidget {
  const WoodApp({super.key});

  @override
  ConsumerState<WoodApp> createState() => _WoodAppState();
}

class _WoodAppState extends ConsumerState<WoodApp> {
  int selectedIndex = 0;
  bool isLoading = true; // متغير لتتبع حالة التحميل

  final List<Widget> pages = const [
    MainMenuPage(),
    DailyJournalPage(),
    ProductFormPage(),
    InvoicesListPage(),
    PurchasesDatesPage(),
  ];

  @override
  void initState() {
    super.initState();
    // التحقق من أن Hive جاهز قبل تحميل الصفحات
    Future.delayed(Duration.zero, () async {
      try {
        print('Checking Hive boxes...');
        await Hive.box(HiveService.productsBox).isOpen;
        await Hive.box(HiveService.clientsBox).isOpen;
        await Hive.box(HiveService.invoicesBox).isOpen;
        await Hive.box(HiveService.expensesBox).isOpen;
        await Hive.box(HiveService.countersBox).isOpen;
        await Hive.box(HiveService.cashboxBox).isOpen;
        await Hive.box(HiveService.purchasesBox).isOpen;
        print('All Hive boxes are open');
        setState(() {
          isLoading = false;
        });
      } catch (e) {
        print('Error checking Hive boxes: $e');
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wood Business Suite',
      theme: AppTheme.light,
      // إضافة المسارات لدعم التنقل
      routes: {
        '/product_list': (context) => const ProductListPage(),
        '/product_form': (context) => const ProductFormPage(),
        '/invoices_list': (context) => const InvoicesListPage(),
        '/invoices_by_date': (context) => const PurchasesDatesPage(),
        '/invoice_form': (context) => const InvoiceFormPage(),
        '/invoice_confirmation': (context) => InvoiceConfirmationPage(
          invoice: ModalRoute.of(context)!.settings.arguments as Invoice,
          shopName: 'متجري',
        ),
        '/client_detail': (context) => ClientDetailPage(
          id: ModalRoute.of(context)!.settings.arguments as String,
        ),
        '/invoice_edit': (context) => InvoiceEditPage(
          id: ModalRoute.of(context)!.settings.arguments as String,
        ),
      },
      home: isLoading
          ? const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      )
          : Scaffold(
        body: IndexedStack(
          index: selectedIndex,
          children: pages,
        ),
        bottomNavigationBar: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: GNav(
              backgroundColor: Colors.grey.withOpacity(0.1),
              color: Colors.black,
              activeColor: Colors.blueGrey,
              rippleColor: Colors.white,
              haptic: true,
              hoverColor: Colors.black,
              tabBackgroundColor: Colors.grey.withOpacity(0.5),
              padding: const EdgeInsets.all(16),
              gap: 1,
              tabs: [
                GButton(
                  icon: Icons.menu,
                  text: 'المزيد',
                ),
                GButton(
                  icon: Icons.calendar_today,
                  text: 'اليوميه',
                ),
                GButton(
                  icon: Icons.add_circle,
                  text: '',
                  iconSize: 40,
                ),
                GButton(
                  icon: Icons.feed_outlined,
                  text: 'الفواتير',
                ),
                GButton(
                  icon: Icons.attach_money,
                  text: 'الوارادات',
                ),
              ],
              selectedIndex: selectedIndex,
              onTabChange: (index) {
                print('Switching to page index: $index');
                setState(() {
                  selectedIndex = index;
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}