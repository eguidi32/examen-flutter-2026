import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../constants/app_strings.dart';

class ApiClient {
  ApiClient({
    http.Client? httpClient,
    this.timeout = ApiConstants.requestTimeout,
  }) : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;
  final Duration timeout;

  Future<dynamic> get(
    String path, {
    Map<String, Object?>? queryParameters,
    Map<String, String>? headers,
  }) {
    return _send(
      () => _httpClient.get(
        _buildUri(path, queryParameters: queryParameters),
        headers: _headers(headers, includeContentType: false),
      ),
    );
  }

  Future<dynamic> post(
    String path, {
    Object? body,
    Map<String, Object?>? queryParameters,
    Map<String, String>? headers,
  }) {
    return _send(
      () => _httpClient.post(
        _buildUri(path, queryParameters: queryParameters),
        headers: _headers(headers),
        body: body == null ? null : jsonEncode(body),
      ),
    );
  }

  void close() {
    _httpClient.close();
  }

  Future<dynamic> _send(Future<http.Response> Function() request) async {
    try {
      final response = await request().timeout(timeout);
      final decodedBody = _decodeBody(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return decodedBody;
      }

      throw ApiException(
        message: _extractErrorMessage(decodedBody, response.statusCode),
        statusCode: response.statusCode,
        body: decodedBody,
      );
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw const ApiException(message: AppStrings.requestTimeout);
    } on http.ClientException {
      throw const ApiException(message: AppStrings.networkUnavailable);
    } on FormatException {
      throw const ApiException(message: AppStrings.invalidResponse);
    } catch (_) {
      throw const ApiException(message: AppStrings.genericError);
    }
  }

  Uri _buildUri(String path, {Map<String, Object?>? queryParameters}) {
    final baseUri = Uri.parse(ApiConstants.baseUrl);
    final baseSegments = baseUri.pathSegments.where((segment) {
      return segment.isNotEmpty;
    });
    final pathSegments = path.split('/').where((segment) {
      return segment.isNotEmpty;
    });
    final cleanedQuery = queryParameters == null
        ? null
        : Map.fromEntries(
            queryParameters.entries
                .where((entry) => entry.value != null)
                .map((entry) => MapEntry(entry.key, entry.value.toString())),
          );

    return baseUri.replace(
      pathSegments: [...baseSegments, ...pathSegments],
      queryParameters: cleanedQuery == null || cleanedQuery.isEmpty
          ? null
          : cleanedQuery,
    );
  }

  Map<String, String> _headers(
    Map<String, String>? headers, {
    bool includeContentType = true,
  }) {
    return {
      'Accept': 'application/json',
      if (includeContentType) 'Content-Type': 'application/json',
      ...?headers,
    };
  }

  dynamic _decodeBody(String body) {
    if (body.trim().isEmpty) {
      return null;
    }

    return jsonDecode(body);
  }

  String _extractErrorMessage(dynamic decodedBody, int statusCode) {
    if (decodedBody is Map<String, dynamic>) {
      final message = decodedBody['message'];
      if (message is String && message.trim().isNotEmpty) {
        return message;
      }

      final detail = decodedBody['detail'];
      if (detail is String && detail.trim().isNotEmpty) {
        return detail;
      }

      final error = decodedBody['error'];
      if (error is String && error.trim().isNotEmpty) {
        return error;
      }
    }

    return switch (statusCode) {
      400 => 'Requete invalide.',
      401 => 'Authentification requise.',
      403 => 'Action non autorisee.',
      404 => 'Ressource introuvable.',
      409 => 'Operation impossible dans cet etat.',
      500 => 'Erreur serveur. Veuillez reessayer.',
      502 || 503 => 'Service temporairement indisponible.',
      _ => AppStrings.genericError,
    };
  }
}

class ApiException implements Exception {
  const ApiException({required this.message, this.statusCode, this.body});

  final String message;
  final int? statusCode;
  final dynamic body;

  @override
  String toString() {
    return 'ApiException(statusCode: $statusCode, message: $message)';
  }
}
