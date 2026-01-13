import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient({required this.baseUrl, http.Client? httpClient})
    : _client = httpClient ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  Uri _uri(String path) {
    final normalizedBase =
        baseUrl.endsWith('/')
            ? baseUrl.substring(0, baseUrl.length - 1)
            : baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$normalizedBase$normalizedPath');
  }

  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
  }) async {
    final resp = await _client.post(
      _uri(path),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        ...?headers,
      },
      body: jsonEncode(body),
    );

    final decoded = jsonDecode(resp.body);
    if (decoded is! Map) {
      throw FormatException('Unexpected response shape');
    }

    final map = decoded.cast<String, dynamic>();
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      final err = map['error'];
      throw Exception(err is String && err.isNotEmpty ? err : 'Request failed');
    }

    return map;
  }

  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, String>? headers,
  }) async {
    final resp = await _client.get(
      _uri(path),
      headers: {'Accept': 'application/json', ...?headers},
    );

    final decoded = jsonDecode(resp.body);
    if (decoded is! Map) {
      throw FormatException('Unexpected response shape');
    }

    final map = decoded.cast<String, dynamic>();
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      final err = map['error'];
      throw Exception(err is String && err.isNotEmpty ? err : 'Request failed');
    }

    return map;
  }
}
