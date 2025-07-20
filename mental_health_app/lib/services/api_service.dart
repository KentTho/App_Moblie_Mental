// lib/services/api_service.dart
// Placeholder for your existing ApiService.
// You should replace this with your actual ApiService implementation.
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'http://localhost:8000/api'; // Replace with your backend URL

  // This method should ideally get the token from your AuthProvider
  Future<Map<String, String>> _getHeaders() async {
    // In a real app, you'd fetch the user's auth token here
    // For now, we'll return basic headers.
    // final String? token = await AuthProvider().getToken(); // Example
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      // if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> get(String endpoint) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders();
    return http.get(uri, headers: headers);
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> data) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders();
    return http.post(uri, headers: headers, body: json.encode(data));
  }

  Future<http.Response> put(String endpoint, Map<String, dynamic> data) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders();
    return http.put(uri, headers: headers, body: json.encode(data));
  }

  Future<http.Response> delete(String endpoint) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders();
    return http.delete(uri, headers: headers);
  }
}
