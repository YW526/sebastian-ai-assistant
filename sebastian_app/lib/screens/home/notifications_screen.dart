import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sebastian_app/widgets/common/custom_TextField.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final titleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('알림'),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: CustomTextField(
              controller: titleController,
              type: TextFieldType.box,
              hintText: '제목',
            ),
          ),
          Expanded(
            child: CustomTextField(
              controller: titleController,
              type: TextFieldType.box,
              hintText: '제목',
            ),
          ),
        ],
      ),
    );
  }
}