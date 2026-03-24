import 'package:flutter/material.dart';
import 'package:sebastian_app/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  
  final authService = AuthService();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 100),
          child: Column(
            children: [
              // 상단 로고
              const Image(image: AssetImage("assets/images/logo1.png"), width: 80),
              const Text(
                "나의 세바스찬",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              // 로그인 박스
              Container(
                width: 288,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                ),
                child: Column(
                  children: [
                    Container(
                      height: 22,
                      width: double.infinity,
                      alignment: Alignment.topLeft,
                      padding: const EdgeInsets.only(left: 2, top: 0),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEFEFEF),
                        border: Border(
                          bottom: BorderSide(color: Colors.black),
                        ),
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            "assets/images/icon.png", 
                            width: 40,
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(20),
                
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 이메일
                          const Text(
                            "이메일",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextField(
                            controller: emailController,
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 2),
                              border: UnderlineInputBorder(),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // 비밀번호
                          const Text(
                            "비밀번호",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextField(
                            controller: passwordController,
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 2),
                              border: UnderlineInputBorder(),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // 비밀번호 찾기
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              "비밀번호를 잊으셨나요?",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // 로그인 버튼
                          Center(
                            child: SizedBox(
                              width: 170,
                              height: 35,
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: const BorderSide(color: Color(0xFFE1E1E1)),
                                  ),
                                ),
                                child: const Text(
                                  "로그인",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // 회원가입
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text("계정이 없으신가요? "),
                  Text(
                    "회원가입하기",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}