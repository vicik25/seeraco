import 'dart:async';
import 'dart:convert';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class SeeraApiException implements Exception {
  const SeeraApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class SeeraApi {
  SeeraApi._();

  static const _baseUrl = String.fromEnvironment(
    'SEERA_API_BASE_URL',
    defaultValue: 'https://seeraco.kesug.com/',
  );
  static final _defaultClient = http.Client();
  static http.Client? _clientOverride;
  static const _timeout = Duration(seconds: 20);
  static http.Client get _client => _clientOverride ?? _defaultClient;
  static Uri _url(String endpoint) => Uri.parse(_baseUrl).resolve(endpoint);

  static void setClientForTesting(http.Client client) {
    _clientOverride = client;
  }

  static void clearClientForTesting() {
    _clientOverride?.close();
    _clientOverride = null;
  }

  static Future<List<Map<String, dynamic>>> getList(String endpoint) async {
    final response = await _request(
      endpoint,
      () => _client.get(_url(endpoint)),
    );
    final decoded = _decodeResponse(response);
    final dynamic rows = decoded is List
        ? decoded
        : decoded is Map<String, dynamic>
        ? decoded['data'] ??
              decoded['produk'] ??
              decoded['review'] ??
              decoded['reviews']
        : null;
    if (rows is! List) {
      throw const SeeraApiException('Format data dari server tidak sesuai.');
    }
    return rows
        .whereType<Map>()
        .map((row) => Map<String, dynamic>.from(row))
        .toList(growable: false);
  }

  static Future<Map<String, dynamic>> postForm(
    String endpoint,
    Map<String, String> fields,
  ) async {
    final response = await _request(
      endpoint,
      () => _client.post(
        _url(endpoint),
        headers: const {
          'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
        },
        body: fields,
      ),
    );
    final decoded = _decodeResponse(response);
    if (decoded is Map<String, dynamic>) return decoded;
    return {'data': decoded};
  }

  static Future<Map<String, dynamic>> postFields(
    String endpoint,
    Map<String, String> fields, {
    XFile? file,
    String? fileField,
  }) async {
    final request = http.MultipartRequest('POST', _url(endpoint))
      ..fields.addAll(fields);
    if (file != null) {
      if (fileField == null) {
        throw ArgumentError.value(
          fileField,
          'fileField',
          'Required when file is provided.',
        );
      }
      request.files.add(
        http.MultipartFile.fromBytes(
          fileField,
          await file.readAsBytes(),
          filename: file.name,
          contentType: MediaType(
            'image',
            file.name.toLowerCase().endsWith('.png') ? 'png' : 'jpeg',
          ),
        ),
      );
    }
    final streamed = await _request(endpoint, () => _client.send(request));
    final response = await http.Response.fromStream(streamed);
    final decoded = _decodeResponse(response);
    if (decoded is Map<String, dynamic>) return decoded;
    return {'data': decoded};
  }

  static Future<T> _request<T>(
    String endpoint,
    Future<T> Function() send,
  ) async {
    try {
      return await send().timeout(_timeout);
    } on http.ClientException {
      throw SeeraApiException(
        kIsWeb
            ? 'API $endpoint tidak dapat diakses dari browser. Server harus mengizinkan origin aplikasi melalui CORS dan mengembalikan JSON (bukan halaman proteksi).'
            : 'Tidak dapat terhubung ke API $endpoint. Periksa koneksi dan server.',
      );
    } on TimeoutException {
      throw SeeraApiException(
        'Permintaan ke API $endpoint melewati batas waktu. Coba lagi.',
      );
    }
  }

  static dynamic _decodeResponse(http.Response response) {
    dynamic decoded;
    try {
      decoded = jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw SeeraApiException(
          'Server merespons HTTP ${response.statusCode}: ${response.body}',
        );
      }
      final body = utf8.decode(response.bodyBytes).trimLeft().toLowerCase();
      if (body.startsWith('<!doctype html') ||
          body.startsWith('<html') ||
          body.startsWith('<script')) {
        throw const SeeraApiException(
          'Endpoint API mengembalikan halaman HTML/proteksi, bukan JSON. Minta hosting menonaktifkan challenge untuk endpoint API.',
        );
      }
      throw const SeeraApiException(
        'Respons server bukan JSON yang valid. Periksa format respons endpoint API.',
      );
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = decoded is Map
          ? decoded['message'] ?? decoded['error']
          : null;
      throw SeeraApiException(
        message?.toString() ?? 'Server merespons HTTP ${response.statusCode}.',
      );
    }
    if (decoded is Map && decoded['success'] == false) {
      throw SeeraApiException(
        decoded['message']?.toString() ?? 'Permintaan gagal diproses server.',
      );
    }
    return decoded;
  }

  static Uri resolveImageUri(String value) {
    final uri = Uri.tryParse(value);
    return uri != null && uri.hasScheme ? uri : _url(value);
  }
}
