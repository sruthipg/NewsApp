import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:top_news_app/resource/theme.dart';
import 'package:top_news_app/ui/news/topnews_list_page.dart';
import 'package:top_news_app/utils/news_background.dart';

import 'utils/constants.dart';

// Please enable the Notification Manually if you switch off the Notification
Future<void> main() async {
  // Initialize the Service
  WidgetsFlutterBinding.ensureInitialized();
  MyBackgroundService().initializeService();
  FlutterBackgroundService().invoke("setAsForeground");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // ScreenUtilInit is used for adapting screen and font size
    // We also need to update the pixel values by creating a dimen file
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (_, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: AppConstants.appName,
          theme: lightTheme,
          themeMode: ThemeMode.light,
          home: child,
        );
      },
      child: TopNewsList(),
    );
  }
}
