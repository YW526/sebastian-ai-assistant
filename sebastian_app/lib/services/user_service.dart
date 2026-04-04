import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sebastian_app/config/api_config.dart';
import '../storage/token_storage.dart';

class UserService {
  Future<Map<String, dynamic>?> getProfile() async {
    final token = await TokenStorage.getToken();

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/users/me'),
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
