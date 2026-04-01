import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomTabBar extends StatefulWidget {
  const CustomTabBar({super.key});

  @override
  State<CustomTabBar> createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<CustomTabBar> {

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      width: 400,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            width: 100,
            height: 80,
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: const Text(
                  " 홈 ",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
          TextButton(
            onPressed: () => Get.toNamed('/calendar'),
            child: const Text(
              "일정",
              style: TextStyle(
                color: Colors.black,
                fontSize: 12,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Get.toNamed('/calendar'),
            child: const Text(
              "루틴",
              style: TextStyle(
                color: Colors.black,
                fontSize: 12,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Get.toNamed('/calendar'),
            child: const Text(
              "설정",
              style: TextStyle(
                color: Colors.black,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}