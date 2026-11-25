
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _endpoint =
      'https://api.api-ninjas.com/v1/motorcycles';

  static const String _apiKey =
      String.fromEnvironment('API_NINJAS_KEY');

  final http.Client _client;

  ApiService({http.Client? client})
      : _client = client ?? http.Client();

  Future<List<Map<String, dynamic>>> search({
    required String make,
    required String model,
  }) async {
    // 1. Validasi API Key
    if (_apiKey.isEmpty) {
      throw Exception(
        'API Key belum dipasang. '
        'Gunakan --dart-define=API_NINJAS_KEY=API_KEY_ANDA',
      );
    }

    // 2. Validasi parameter
    if (make.trim().isEmpty || model.trim().isEmpty) {
      throw Exception(
        'Merek dan model motor tidak boleh kosong.',
      );
    }

    // 3. Membuat URL request
    final uri = Uri.parse(_endpoint).replace(
      queryParameters: {
        'make': make.trim(),
        'model': model.trim(),
      },
    );

    debugPrint('========== ZONARIDER API ==========');
    debugPrint('Request URL: $uri');
    debugPrint('Merek: ${make.trim()}');
    debugPrint('Model: ${model.trim()}');

    try {
      // 4. Mengirim request ke API Ninjas
      final response = await _client
          .get(
            uri,
            headers: {
              'X-Api-Key': _apiKey,
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 20));

      debugPrint('HTTP Status: ${response.statusCode}');
      debugPrint('API Response: ${response.body}');

      // 5. Menangani status HTTP
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded is! List) {
          throw Exception(
            'Format data API tidak sesuai. '
            'Respons seharusnya berupa List.',
          );
        }

        final results = decoded
            .whereType<Map>()
            .map(
              (item) => Map<String, dynamic>.from(item),
            )
            .toList();

        debugPrint('Jumlah data ditemukan: ${results.length}');
        debugPrint('===================================');

        return results;
      }

      if (response.statusCode == 400) {
        throw Exception(
          'HTTP 400 - Request tidak valid.\n'
          'Detail server: ${response.body}',
        );
      }

      if (response.statusCode == 401) {
        throw Exception(
          'HTTP 401 - API Key tidak valid atau tidak dikenali.',
        );
      }

      if (response.statusCode == 403) {
        throw Exception(
          'HTTP 403 - Akses API ditolak.',
        );
      }

      if (response.statusCode == 429) {
        throw Exception(
          'HTTP 429 - Batas permintaan API tercapai. '
          'Silakan coba lagi nanti.',
        );
      }

      throw Exception(
        'HTTP ${response.statusCode}: ${response.body}',
      );
    } on TimeoutException {
      throw Exception(
        'Koneksi API timeout. Periksa jaringan internet.',
      );
    } on FormatException catch (e) {
      throw Exception(
        'Gagal membaca JSON dari API: ${e.message}',
      );
    } catch (e) {
      debugPrint('API Error: $e');
      rethrow;
    }
  }

  void dispose() {
    _client.close();
  }
}
