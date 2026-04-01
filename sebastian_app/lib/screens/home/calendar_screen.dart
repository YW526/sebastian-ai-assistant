import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sebastian_app/widgets/common/custom_TextField.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final titleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('캘린더'),
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