import 'dart:convert';
import 'package:http/http.dart' as http;

class DeepAIService {
  final String _apiKey = '09cf1785-ee87-4fb5-9f75-c1bbb491c679'; // Replace this with your actual key

  Future<String> getResponse(String prompt) async {
    final url = Uri.parse("https://api.deepai.org/api/text-generator");

    final response = await http.post(
      url,
      headers: {
        'api-key': _apiKey,
      },
      body: {
        'text': prompt,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['output'];
    } else {
      throw Exception("Failed to get response: ${response.body}");
    }
  }
}
