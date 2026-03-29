import 'dart:convert';
import 'package:http/http.dart' as http;
import '../storage/token_storage.dart';

class UserService {
  final String baseUrl = 'http://localhost:3000';

  Future<Map<String, dynamic>?> getProfile() async {
    final token = await TokenStorage.getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/users/me'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    return null;
  }
}