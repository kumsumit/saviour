import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:saviour/src/rust/api/server.dart' as native;

typedef SaviourTransport =
    Future<Map<String, Object?>> Function(Map<String, Object?> request);

class SaviourApi {
  SaviourApi({SaviourTransport? transport})
    : _transport = transport ?? _nativeTransport;
  static final SaviourApi instance = SaviourApi();
  final SaviourTransport _transport;
  String? _accessToken;
  int _sequence = 0;
  final revision = ValueNotifier<int>(0);
  Map<String, Object?>? currentUser;
  bool get isAuthenticated => _accessToken != null;

  static Future<Map<String, Object?>> _nativeTransport(
    Map<String, Object?> request,
  ) async {
    if (kIsWeb) {
      throw const SaviourApiException(
        'The QUIC server requires the native app.',
      );
    }
    const configured = String.fromEnvironment('SAVIOUR_SERVER_ADDRESS');
    const serverName = String.fromEnvironment(
      'SAVIOUR_SERVER_NAME',
      defaultValue: 'localhost',
    );
    const encodedCa = String.fromEnvironment('SAVIOUR_CA_BASE64');
    final ca = encodedCa.isEmpty ? '' : utf8.decode(base64Decode(encodedCa));
    final address = configured.isNotEmpty
        ? configured
        : '${defaultTargetPlatform == TargetPlatform.android ? '10.0.2.2' : '127.0.0.1'}:8080';
    return Map<String, Object?>.from(
      jsonDecode(
            await native.serverRequest(
              address: address,
              serverName: serverName,
              caPem: ca,
              requestJson: jsonEncode(request),
            ),
          )
          as Map,
    );
  }

  Future<Map<String, Object?>> _send(
    String operation,
    String responseField, {
    String payloadField = 'empty',
    Map<String, Object?> payload = const {},
    bool authenticated = true,
  }) async {
    if (authenticated && _accessToken == null) {
      throw const SaviourApiException('Please sign in first.');
    }
    final id = '${DateTime.now().microsecondsSinceEpoch}-${++_sequence}';
    try {
      final response = await _transport({
        'protocolVersion': 1,
        'requestId': id,
        'operation': operation,
        if (authenticated) 'accessToken': _accessToken,
        payloadField: payload,
      });
      if (response['protocolVersion'] != 1 ||
          response['requestId'] != id ||
          response['operation'] != operation) {
        throw const SaviourApiException('Invalid server response.');
      }
      if (response['status'] != 'OK') {
        final error = response['error'] as Map?;
        final code = error?['code'] as String?;
        if (code == 'unauthorized') signOut();
        throw SaviourApiException(
          error?['message'] as String? ?? 'Server request failed.',
          code: code,
        );
      }
      final result = Map<String, Object?>.from(response[responseField] as Map);
      if (operation == 'PROFILE_UPDATE') currentUser = result;
      if (const {
        'PROFILE_UPDATE',
        'BLOOD_REQUEST_CREATE',
        'BLOOD_REQUEST_RESPOND',
        'CAMP_RESERVE',
      }.contains(operation)) {
        revision.value++;
      }
      return result;
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

  Future<OtpChallenge> requestOtp(String phone) async {
    final json = await _send(
      'OTP_REQUEST',
      'otpRequested',
      payloadField: 'otpRequest',
      payload: {'phone': phone},
      authenticated: false,
    );
    return OtpChallenge(
      id: json['challengeId'] as String,
      expiresIn: json['expiresIn'] as int,
      demoCode: json['developmentCode'] as String?,
    );
  }

  Future<Map<String, Object?>> verifyOtp({
    required String challengeId,
    required String code,
  }) async {
    final json = await _send(
      'OTP_VERIFY',
      'otpVerified',
      payloadField: 'otpVerify',
      payload: {'challengeId': challengeId, 'code': code},
      authenticated: false,
    );
    _accessToken = json['accessToken'] as String;
    currentUser = Map<String, Object?>.from(json['user'] as Map);
    return currentUser!;
  }

  Future<Map<String, Object?>> health() =>
      _send('HEALTH_LIVE', 'health', authenticated: false);
  Future<Map<String, Object?>> dashboard() =>
      _send('DASHBOARD_GET', 'dashboard');
  Future<Map<String, Object?>> profile() => _send('PROFILE_GET', 'userProfile');
  Future<List<Map<String, Object?>>> requests({
    String? query,
    bool urgentOnly = false,
    int limit = 50,
    int offset = 0,
  }) async => _items(
    await _send(
      'BLOOD_REQUEST_LIST',
      'bloodRequestPage',
      payloadField: 'bloodRequestList',
      payload: {
        'query': query ?? '',
        'urgentOnly': urgentOnly,
        'limit': limit,
        'offset': offset,
      },
    ),
  );
  Future<List<Map<String, Object?>>> camps() async =>
      _items(await _send('CAMP_LIST', 'campList'));
  Future<List<Map<String, Object?>>> notifications() async =>
      _items(await _send('NOTIFICATION_LIST', 'notificationList'));
  static List<Map<String, Object?>> _items(Map<String, Object?> json) =>
      (json['items'] as List? ?? [])
          .map((e) => Map<String, Object?>.from(e as Map))
          .toList();
  Future<Map<String, Object?>> createRequest({
    required String patientName,
    required String hospital,
    required String contactPhone,
    required String bloodGroup,
    required bool urgent,
    String component = 'Whole blood',
    int units = 1,
  }) => _send(
    'BLOOD_REQUEST_CREATE',
    'bloodRequest',
    payloadField: 'bloodRequestCreate',
    payload: {
      'patientName': patientName,
      'hospital': hospital,
      'contactPhone': contactPhone,
      'bloodGroup': bloodGroup.replaceAll('−', '-'),
      'urgent': urgent,
      'component': component,
      'units': units,
    },
  );
  Future<void> respondToRequest(String id) async {
    await _send(
      'BLOOD_REQUEST_RESPOND',
      'actionResult',
      payloadField: 'idRequest',
      payload: {'id': id},
    );
  }

  Future<void> reserveCamp(String id) async {
    await _send(
      'CAMP_RESERVE',
      'reservation',
      payloadField: 'idRequest',
      payload: {'id': id},
    );
  }

  Future<Map<String, Object?>> updateProfile({
    String? name,
    String? bloodGroup,
    bool? available,
  }) async {
    currentUser = await _send(
      'PROFILE_UPDATE',
      'userProfile',
      payloadField: 'profileUpdate',
      payload: {
        'name': ?name,
        if (bloodGroup != null) 'bloodGroup': bloodGroup.replaceAll('−', '-'),
        'available': ?available,
      },
    );
    return currentUser!;
  }

  Future<void> setAvailability(bool available) async {
    await updateProfile(available: available);
  }

  void signOut() {
    _accessToken = null;
    currentUser = null;
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
  const SaviourApiException(this.message, {this.code});
  final String message;
  final String? code;
  @override
  String toString() => message;
}
