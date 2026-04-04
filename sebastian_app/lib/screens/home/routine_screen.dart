import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sebastian_app/widgets/common/custom_button.dart';
import 'package:sebastian_app/routes/app_routes.dart';
import 'package:sebastian_app/services/auth_service.dart';
import 'package:sebastian_app/storage/token_storage.dart';
import 'package:sebastian_app/widgets/common/custom_TextField.dart';
import 'package:sebastian_app/widgets/common/custom_topbar.dart';
import 'package:sebastian_app/widgets/common/custom_tabbar.dart';

class RoutineScreen extends StatefulWidget {
  const RoutineScreen({super.key});

  @override
  State<RoutineScreen> createState() => _RoutineScreenState();
}

class _RoutineScreenState extends State<RoutineScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Column(
          children: [
            const CustomTopBar(),
            const SizedBox(height: 10),
            const CustomTabBar(),
            const SizedBox(height: 20),
            const Divider(
              height: 1,
              thickness: 1,
              color: Color(0xFFD9D9D9),
            ),
          ],
        ),
      ),
    );
  }
}