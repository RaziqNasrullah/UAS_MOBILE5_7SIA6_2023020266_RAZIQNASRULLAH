import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_config.dart';

/// Error yang sudah diterjemahkan ke pesan ramah pengguna.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException(this.message, {this.statusCode, this.data});

  @override
  String toString() => message;
}

/// Respons API seragam `{ success, message, data }`.
class ApiResponse {
  final bool success;
  final String message;
  final dynamic data;

  ApiResponse({required this.success, required this.message, this.data});
}

/// Pembungkus `http` dengan timeout, try-catch, dan parsing JSON seragam.
class ApiService {
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final q = <String, String>{};
    query?.forEach((k, v) {
      if (v != null && v.toString().isNotEmpty) q[k] = v.toString();
    });
    return Uri.parse('${ApiConfig.baseUrl}/$path')
        .replace(queryParameters: q.isEmpty ? null : q);
  }

  Future<ApiResponse> get(String path, {Map<String, dynamic>? query}) {
    return _send(() => _client.get(_uri(path, query),
        headers: const {'Accept': 'application/json'}));
  }

  Future<ApiResponse> post(String path, [Map<String, dynamic>? body]) {
    return _send(() => _client.post(
          _uri(path),
          headers: const {
            'Content-Type': 'application/json; charset=utf-8',
            'Accept': 'application/json',
          },
          body: jsonEncode(body ?? {}),
        ));
  }

  /// Upload file multipart (dipakai untuk gambar produk).
  Future<ApiResponse> upload(String path, String field, File file) {
    return _send(() async {
      final req = http.MultipartRequest('POST', _uri(path))
        ..headers['Accept'] = 'application/json'
        ..files.add(await http.MultipartFile.fromPath(field, file.path));
      final streamed = await req.send();
      return http.Response.fromStream(streamed);
    }, timeout: ApiConfig.timeout * 2);
  }

  Future<ApiResponse> _send(
    Future<http.Response> Function() request, {
    Duration? timeout,
  }) async {
    http.Response res;
    try {
      res = await request().timeout(timeout ?? ApiConfig.timeout);
    } on TimeoutException {
      throw ApiException(
          'Server tidak merespons (timeout). Pastikan Apache & MySQL XAMPP aktif.');
    } on SocketException {
      throw ApiException(
          'Tidak dapat terhubung ke server ${ApiConfig.baseUrl}. Periksa XAMPP, alamat IP, dan koneksi Wi-Fi.');
    } on http.ClientException catch (e) {
      throw ApiException('Koneksi ke server gagal: ${e.message}');
    } catch (e) {
      throw ApiException('Terjadi kesalahan jaringan: $e');
    }

    final body = res.body.trim();
    if (body.isEmpty) {
      throw ApiException('Respons server kosong (HTTP ${res.statusCode}).',
          statusCode: res.statusCode);
    }

    Map<String, dynamic> json;
    try {
      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) throw const FormatException();
      json = decoded;
    } catch (_) {
      final msg = res.statusCode == 404
          ? 'Endpoint tidak ditemukan (404). Pastikan folder apotek_api sudah ada di htdocs.'
          : 'Format respons server tidak valid (HTTP ${res.statusCode}).';
      throw ApiException(msg, statusCode: res.statusCode);
    }

    final success = json['success'] == true;
    final message = (json['message'] ?? '').toString();
    if (!success || res.statusCode >= 400) {
      throw ApiException(
        message.isNotEmpty ? message : 'Permintaan gagal (HTTP ${res.statusCode}).',
        statusCode: res.statusCode,
        data: json['data'],
      );
    }
    return ApiResponse(success: true, message: message, data: json['data']);
  }
}
