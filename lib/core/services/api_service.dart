import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// خدمة استدعاء الـ API بتعامل نظيف مع
/// - GET / POST (x-www-form-urlencoded / JSON)
/// - رفع ملفات (Multipart)
/// - رسائل أخطاء واضحة عند HTML/HTTP/JSON errors
///
/// ملاحظة: التوكن **ملغى افتراضيًا**.
/// لو رجّعته لاحقًا، مرّر includeToken:true ووفّر قيمة token في الدالة.
class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// مهلة افتراضية للاتصال (اختياري)
  Duration timeout = const Duration(seconds: 25);

  /// GET
  Future<dynamic> get(
    String url, {
    Map<String, String>? query,
    bool includeToken = false,
    String? token,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse(url).replace(
      queryParameters: {
        if (query != null) ...query,
        if (includeToken && token != null && token.isNotEmpty) 'token': token,
      },
    );
    debugPrint('[GET] $uri');

    final r = await _client
        .get(uri, headers: _mergedHeaders(headers))
        .timeout(timeout);

    return _decode(r, uri);
  }

  /// POST (x-www-form-urlencoded)
  Future<dynamic> postForm(
    String url,
    Map<String, String> body, {
    bool includeToken = false,
    String? token,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse(url);
    final b = <String, String>{
      ...body,
      if (includeToken && token != null && token.isNotEmpty) 'token': token,
    };

    debugPrint('[POST:FORM] $uri body=$b');

    final r = await _client
        .post(
          uri,
          headers: _mergedHeaders({
            'Content-Type': 'application/x-www-form-urlencoded',
            ...?headers,
          }),
          body: b,
        )
        .timeout(timeout);

    return _decode(r, uri);
  }

  /// POST (application/json)
  Future<dynamic> postJson(
    String url,
    Map<String, dynamic> body, {
    bool includeToken = false,
    String? token,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse(url);
    final payload = {
      ...body,
      if (includeToken && token != null && token.isNotEmpty) 'token': token,
    };

    debugPrint('[POST:JSON] $uri body=$payload');

    final r = await _client
        .post(
          uri,
          headers: _mergedHeaders({
            'Content-Type': 'application/json',
            ...?headers,
          }),
          body: jsonEncode(payload),
        )
        .timeout(timeout);

    return _decode(r, uri);
  }

  /// رفع ملف (Multipart)
  Future<dynamic> uploadFile(
    String url, {
    required String filePath,
    String fieldName = 'image',
    Map<String, String>? extraFields,
  }) async {
    final uri = Uri.parse(url);

    final req = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath(fieldName, filePath));

    if (extraFields != null && extraFields.isNotEmpty) {
      req.fields.addAll(extraFields);
    }

    final streamed = await req.send(); // StreamedResponse
    final body = await streamed.stream.bytesToString(); // String

    // رجّع JSON لو أمكن، وإلا رجّع النص كما هو
    try {
      return json.decode(body); // Map أو List
    } catch (_) {
      return body; // String
    }
  }

  /* -------------------- داخلي -------------------- */

  Map<String, String> _mergedHeaders(Map<String, String>? extra) {
    return {'Accept': 'application/json', ...?extra};
  }

  dynamic _decode(http.Response r, Uri uri) {
    final text = r.body.trim();

    // حالة HTTP
    if (r.statusCode < 200 || r.statusCode >= 300) {
      throw 'HTTP ${r.statusCode} for $uri\n${_peek(text)}';
    }

    // بعض السيرفرات ترجع HTML عند الأخطاء/المسارات الغلط
    if (text.startsWith('<!DOCTYPE') ||
        text.startsWith('<html') ||
        (text.isNotEmpty && text[0] == '<')) {
      throw 'Non-JSON response from $uri\n${_peek(text)}';
    }

    // جرّب JSON
    try {
      final j = jsonDecode(text);

      // نمط {status,data}
      if (j is Map && j['status'] == 'error') {
        throw j['message'] ?? 'API error';
      }
      if (j is Map && j.containsKey('status') && j.containsKey('data')) {
        return j['data'];
      }

      // رجّعه كما هو (قد تكون List أو Map مباشرة)
      return j;
    } catch (e) {
      throw 'JSON parse error from $uri\n${_peek(text)}';
    }
  }

  String _peek(String s) => s.length <= 300 ? s : ('${s.substring(0, 300)} …');
}
