import 'package:flutter/material.dart';
import 'package:sebastian_app/services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  
  final authService = AuthService();

  Widget _buildDropdown(String text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(text, style: const TextStyle(fontSize: 13)),
            const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 80),
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

              const SizedBox(height: 20),

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
                              hintText: 'example@email.com',
                              hintStyle: TextStyle(color: Color(0xFFD9D9D9), fontSize: 14),
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
                              hintText: '1234',
                              hintStyle: TextStyle(color: Color(0xFFD9D9D9), fontSize: 14),
                            ),
                          ),

                          const SizedBox(height: 10),

                          const Text(
                            "비밀번호 확인",
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
                              hintText: '1234',
                              hintStyle: TextStyle(color: Color(0xFFD9D9D9), fontSize: 14),
                            ),
                          ),

                          const SizedBox(height: 20),

                          const Text(
                            "이름",
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
                              hintText: '엄마 저 힘낼게요',
                              hintStyle: TextStyle(color: Color(0xFFD9D9D9), fontSize: 14),
                            ),
                          ),

                          const SizedBox(height: 20),

                          const Text(
                            "생년월일",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildDropdown("2000년"),
                              const SizedBox(width: 8),
                              _buildDropdown("10월"),
                              const SizedBox(width: 8),
                              _buildDropdown("22일"),
                            ],
                          ),

                          const SizedBox(height: 20),

                          const Text(
                            "성별",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Row(
                                children: const [
                                  Icon(Icons.check_box_outline_blank, size: 20),
                                  SizedBox(width: 6),
                                  Text("남자", style: TextStyle(fontSize: 14)),
                                ],
                              ),
                              Row(
                                children: const [
                                  Icon(Icons.check_box, size: 20, color: Color(0xFF333333)),
                                  SizedBox(width: 6),
                                  Text("여자", style: TextStyle(fontSize: 14)),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 25),

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
                                  "회원가입",
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
                  Text("계정이 있으신가요? "),
                  Text(
                    "로그인하기",
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