import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/env.dart';

class ApiService {
  final _client = http.Client();

  Future<dynamic> get(String path, {Map<String, String>? query}) async {
    final uri = Uri.parse(
      '${Env.baseUrl}$path',
    ).replace(queryParameters: query);
    final r = await _client.get(uri);
    return _decode(r.body);
  }

  Future<dynamic> post(String path, Map<String, String> body) async {
    final r = await _client.post(
      Uri.parse('${Env.baseUrl}$path'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: body,
    );
    return _decode(r.body);
  }

  dynamic _decode(String b) {
    final t = b.trim();
    try {
      final j = jsonDecode(t);
      if (j is Map && j['status'] != null) {
        if (j['status'] == 'success') return j['data'];
        throw j['message'] ?? 'API error';
      }
      return j;
    } catch (_) {
      throw 'Invalid response format';
    }
  }
}
