import 'dart:convert';
import 'package:http/http.dart' as http;

class API {
  final String _url = 'http://127.0.0.1:3000/api';

  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password 
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_url/users/register'),
        headers: { 'Content-Type': 'application/json' },
        body: jsonEncode({
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'password': password
        })
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } on Exception catch (e) {
      print('Exception details:\n $e');
      throw Exception('Encountered an error on the server.');
    }
  }

  Future<bool> login({
    required String email,
    required String password
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_url/users/login'),
        headers: { 'Content-Type': 'application/json' },
        body: jsonEncode({
          'email': email,
          'password': password
        })
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } on Exception catch (e) {
      print('Exception details:\n $e');
      throw Exception('Encountered an error on the server.');
    }
  }
}