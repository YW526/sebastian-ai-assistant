import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/password_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/home/notifications_screen.dart';
import '../screens/home/calendar_screen.dart';
import '../screens/home/routine_screen.dart';
import '../screens/home/setting_screen.dart';
import '../screens/home/ai_cost_screen.dart';

class AppRoutes {
  static const splash = '/splash';
  static const login = '/login';
  static const signup = '/signup';
  static const home = '/home';
  static const password = '/password';
  static const notifications = '/notifications';
  static const calendar = '/calendar';
  static const routine = '/routine';
  static const setting = '/setting';
  static const aiCost = '/ai-cost';

  static final List<GetPage> pages = [
    GetPage(
      name: splash,
      page: () => const SplashScreen(),
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: login,
      page: () => const LoginScreen(),
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: signup,
      page: () => const SignupScreen(),
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: home,
      page: () => const HomeScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
        name: password, 
        page: () => const PasswordScreen(),
        transition: Transition.fadeIn,
    ),
    GetPage(
        name: notifications, 
        page: () => const NotificationsScreen(),
        transition: Transition.fadeIn,
    ),
    GetPage(
        name: calendar, 
        page: () => const CalendarScreen(),
        transition: Transition.fadeIn,
    ),
    GetPage(
        name: routine, 
        page: () => const RoutineScreen(),
        transition: Transition.fadeIn,
    ),
    GetPage(
        name: setting, 
        page: () => const SettingScreen(),
        transition: Transition.fadeIn,
    ),
    GetPage(
        name: aiCost,
        page: () => const AiCostScreen(),
        transition: Transition.rightToLeft,
    ),
  ];
}