import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/home/home_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';

  static final List<GetPage> pages = [
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
  ];
}