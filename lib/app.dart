import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:one_ai/constants/colors.dart';
import 'package:one_ai/controller_binder.dart';
import 'package:one_ai/feature/home/ui/screen/home_screen.dart';
import 'package:one_ai/route/app_route.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialBinding: ControllerBinder(),
      getPages: AppRoute.routes,
      title: 'One Ai',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: AppColors.getMaterialColor(AppColors.screenColor),
        ),
        scaffoldBackgroundColor: AppColors.getMaterialColor(
          AppColors.screenColor,
        ).shade900,
      ),
      home: HomeScreen(),
    );
  }
}
