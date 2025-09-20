import 'package:calc_wood/src/data/hive/hive_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Import ScreenUtil
import 'package:hive_flutter/adapters.dart';
import 'src/presentation/pages/splash/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  try {
    await HiveService.init();
    print("Hive initialized successfully");
  } catch (e) {
    print("Error initializing Hive: $e");
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690), // Set the design size (e.g., based on your UI design)
      minTextAdapt: true, // Adapt text sizes
      splitScreenMode: true, // Support split-screen mode
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Cube',
          home: const SplashScreen(),
          builder: (context, widget) {
            // Ensure ScreenUtil is applied to all widgets
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
              child: widget!,
            );
          },
        );
      },
    );
  }
}