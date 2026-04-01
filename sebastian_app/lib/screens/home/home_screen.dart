import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sebastian_app/screens/home/Schedule_screen.dart';
import 'package:sebastian_app/screens/home/Routine_screen.dart';
import 'package:sebastian_app/screens/home/Setting_screen.dart';
import 'package:sebastian_app/routes/app_routes.dart';
import 'package:sebastian_app/services/auth_service.dart';
import 'package:sebastian_app/storage/token_storage.dart';
import 'package:sebastian_app/widgets/common/custom_topbar.dart';
import 'package:sebastian_app/widgets/common/custom_tabbar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final titleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Column(
          children: [
            CustomTopBar(),
            CustomTabBar(),
            TextButton(
              onPressed: () => Get.toNamed('/calendar'),
              child: const Text(
                "+",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}