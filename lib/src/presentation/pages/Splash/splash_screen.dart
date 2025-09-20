import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:lottie/lottie.dart';
import '../main_menu/main_menu_page.dart';
import '../reports/daily_journal_page.dart';
import '../invoices/invoice_form_page.dart';
import '../invoices/invoice_date_page.dart';
import '../purchases/purchases_dates_page.dart';
import '../../../core/theme/app_theme.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _navigated = false;

  void _goToApp() {
    if (!_navigated) {
      _navigated = true;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const WoodApp()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.green4,// غيرها حسب تصميمك
      body: Center(
        child: Lottie.asset(
          'assets/animation/logo.json',
          width: 350.w,
          height: 350.w,
          repeat: false, // يتشغل مرة واحدة بس
          onLoaded: (composition) {
            // بعد ما يخلص الأنيميشن → يروح للتطبيق
            Future.delayed(composition.duration, _goToApp);
          },
        ),
      ),
    );
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
      title: 'Cube',
      theme: AppTheme.light,
      home: Scaffold(
        body: IndexedStack(index: selectedIndex, children: pages),
        bottomNavigationBar: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: GNav(
              backgroundColor: AppColors.green3.withValues(alpha: .2),
              color: AppColors.green1,
              activeColor: AppColors.blue3,
              rippleColor:  AppColors.green3,
              haptic: true,
              hoverColor: AppColors.green7,
              tabBackgroundColor: AppColors.green6,
              padding: const EdgeInsets.all(16),
              gap: 1,
              tabs: const [
                GButton(icon: Icons.menu, text: 'المزيد',),
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