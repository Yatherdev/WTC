import 'package:calc_wood/src/data/hive/hive_services.dart';
import 'package:calc_wood/src/presentation/pages/invoices/invoice_date_page.dart';
import 'package:calc_wood/src/presentation/pages/invoices/invoice_form_page.dart';
import 'package:calc_wood/src/presentation/pages/main_menu/main_menu_page.dart';
import 'package:calc_wood/src/presentation/pages/purchases/purchases_dates_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'src/core/theme/app_theme.dart';
import 'src/presentation/pages/reports/daily_journal_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  try {
    await HiveService.init();
    print("Hive initialized successfully");
  } catch (e) {
    print("Error initializing Hive: $e");
  }

  runApp(const ProviderScope(child: WoodApp()));
}

// Splash Screen مؤقت
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // بعد 2 ثانية ينقل للصفحة الرئيسية
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeWrapper()));
    });
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

// Wrapper لتجنب مشاكل إعادة البناء
class HomeWrapper extends StatelessWidget {
  const HomeWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return const WoodApp();
  }
}

class WoodApp extends ConsumerStatefulWidget {
  const WoodApp({super.key});

  @override
  ConsumerState<WoodApp> createState() => _WoodAppState();
}

class _WoodAppState extends ConsumerState<WoodApp> {
  int selectedIndex = 0;

  final List<Widget> pages = const [
    MainMenuPage(),
    DailyJournalPage(),
    InvoiceFormPage(),
    InvoiceDatesPage(),
    PurchasesDatesPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wood Business Suite',
      theme: AppTheme.light,
      home: Scaffold(
        body: IndexedStack(index: selectedIndex, children: pages),
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
                GButton(icon: Icons.menu, text: 'المزيد'),
                GButton(icon: Icons.calendar_today, text: 'اليوميه'),
                GButton(icon: Icons.add_circle, text: '', iconSize: 40),
                GButton(icon: Icons.feed_outlined, text: 'الفواتير'),
                GButton(icon: Icons.attach_money, text: 'الوارادات'),
              ],
              selectedIndex: selectedIndex,
              onTabChange: (index) {
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
