import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class SaviourApi {
  SaviourApi({http.Client? client, Uri? baseUri})
    : _client = client ?? http.Client(),
      baseUri = baseUri ?? defaultBaseUri;

  static final SaviourApi instance = SaviourApi();

  static Uri get defaultBaseUri {
    const configured = String.fromEnvironment('SAVIOUR_API_URL');
    if (configured.isNotEmpty) return Uri.parse(configured);
    final host = !kIsWeb && defaultTargetPlatform == TargetPlatform.android
        ? '10.0.2.2'
        : '127.0.0.1';
    return Uri.parse('http://$host:8080');
  }

  final http.Client _client;
  final Uri baseUri;
  String? _accessToken;

  bool get isAuthenticated => _accessToken != null;

  Future<OtpChallenge> requestOtp(String phone) async {
    final json = await _send(
      'POST',
      '/v1/auth/otp/request',
      body: {'phone': phone},
    );
    return OtpChallenge(
      id: json['challengeId']! as String,
      expiresIn: json['expiresIn']! as int,
      demoCode: json['demoCode'] as String?,
    );
  }

  Future<Map<String, Object?>> verifyOtp({
    required String challengeId,
    required String code,
  }) async {
    final json = await _send(
      'POST',
      '/v1/auth/otp/verify',
      body: {'challengeId': challengeId, 'code': code},
    );
    _accessToken = json['accessToken']! as String;
    return Map<String, Object?>.from(json['user']! as Map);
  }

  Future<List<Map<String, Object?>>> requests({
    String? query,
    bool urgentOnly = false,
  }) async {
    final parameters = <String, String>{
      if (query != null && query.isNotEmpty) 'q': query,
      if (urgentOnly) 'urgent': 'true',
    };
    final json = await _send('GET', '/v1/requests', query: parameters);
    return (json['items']! as List)
        .map((item) => Map<String, Object?>.from(item as Map))
        .toList();
  }

  Future<Map<String, Object?>> createRequest({
    required String patientName,
    required String hospital,
    required String contactPhone,
    required String bloodGroup,
    required bool urgent,
  }) => _send(
    'POST',
    '/v1/requests',
    authenticated: true,
    body: {
      'patientName': patientName,
      'hospital': hospital,
      'contactPhone': contactPhone,
      'bloodGroup': bloodGroup,
      'urgent': urgent,
    },
  );

  Future<void> respondToRequest(String id) async {
    await _send('POST', '/v1/requests/$id/respond', authenticated: true);
  }

  Future<void> reserveCamp(String id) async {
    await _send('POST', '/v1/camps/$id/reservations', authenticated: true);
  }

  Future<void> setAvailability(bool available) async {
    await _send(
      'PATCH',
      '/v1/profile',
      authenticated: true,
      body: {'available': available},
    );
  }

  void signOut() => _accessToken = null;

  Future<Map<String, Object?>> _send(
    String method,
    String path, {
    Map<String, String>? query,
    Map<String, Object?>? body,
    bool authenticated = false,
  }) async {
    final uri = baseUri
        .resolve(path)
        .replace(queryParameters: query?.isEmpty ?? true ? null : query);
    final headers = <String, String>{
      'accept': 'application/json',
      if (body != null) 'content-type': 'application/json',
      if (authenticated && _accessToken != null)
        'authorization': 'Bearer $_accessToken',
    };
    try {
      final response = await switch (method) {
        'GET' => _client.get(uri, headers: headers),
        'POST' => _client.post(
          uri,
          headers: headers,
          body: body == null ? null : jsonEncode(body),
        ),
        'PATCH' => _client.patch(uri, headers: headers, body: jsonEncode(body)),
        _ => throw ArgumentError.value(method, 'method'),
      }.timeout(const Duration(seconds: 8));
      final decoded = response.body.isEmpty
          ? <String, Object?>{}
          : jsonDecode(response.body);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        final error = decoded is Map ? decoded['error'] : null;
        final message = error is Map ? error['message'] as String? : null;
        throw SaviourApiException(
          message ?? 'The server returned ${response.statusCode}.',
          statusCode: response.statusCode,
        );
      }
      return Map<String, Object?>.from(decoded as Map);
    } on SaviourApiException {
      rethrow;
    } catch (error) {
      throw SaviourApiException(
        kDebugMode
            ? 'Could not reach the Saviour server: $error'
            : 'Could not reach the Saviour server. Please try again.',
      );
    }
  }
}

class OtpChallenge {
  const OtpChallenge({
    required this.id,
    required this.expiresIn,
    this.demoCode,
  });
  final String id;
  final int expiresIn;
  final String? demoCode;
}

class SaviourApiException implements Exception {
  const SaviourApiException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}
