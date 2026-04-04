import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sebastian_app/routes/app_routes.dart';
import 'package:sebastian_app/storage/token_storage.dart';
import 'package:sebastian_app/widgets/common/custom_topbar.dart';
import 'package:sebastian_app/widgets/common/custom_tabbar.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
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
            const Divider(height: 1, thickness: 1, color: Color(0xFFD9D9D9)),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _tile(
                    icon: Icons.smart_toy_outlined,
                    title: 'AI 설정 & 비용',
                    subtitle: 'API 키, 프로바이더, 사용량 확인',
                    onTap: () => Get.toNamed(AppRoutes.aiCost),
                  ),
                  _tile(
                    icon: Icons.person_outline,
                    title: '페르소나 설정',
                    subtitle: '세바스찬 성격 변경',
                    onTap: () {},
                  ),
                  _tile(
                    icon: Icons.lock_outline,
                    title: '비밀번호 변경',
                    subtitle: '계정 비밀번호 재설정',
                    onTap: () => Get.toNamed(AppRoutes.password),
                  ),
                  const Divider(),
                  _tile(
                    icon: Icons.logout,
                    title: '로그아웃',
                    subtitle: '',
                    color: Colors.red,
                    onTap: () async {
                      await TokenStorage.clearToken();
                      Get.offAllNamed(AppRoutes.login);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile({
    required IconData icon,
    required String title,
    required String subtitle,
    Color? color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.blueGrey),
      title: Text(title,
          style: TextStyle(
              fontWeight: FontWeight.w600,
              color: color)),
      subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}