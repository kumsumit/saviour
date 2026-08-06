import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:saviour/services/saviour_api.dart';

void main() {
  test('requests and verifies an OTP through the companion API', () async {
    final calls = <String>[];
    final client = MockClient((request) async {
      calls.add('${request.method} ${request.url.path}');
      if (request.url.path.endsWith('/request')) {
        expect(jsonDecode(request.body)['phone'], '+919876543210');
        return http.Response(
          jsonEncode({
            'challengeId': 'otp_test',
            'expiresIn': 300,
            'demoCode': '123456',
          }),
          201,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }
      expect(jsonDecode(request.body), {
        'challengeId': 'otp_test',
        'code': '123456',
      });
      return http.Response(
        jsonEncode({
          'accessToken': 'session_test',
          'user': {'id': 'user_demo', 'bloodGroup': 'O−'},
        }),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });
    final api = SaviourApi(
      client: client,
      baseUri: Uri.parse('http://localhost:8080'),
    );

    final challenge = await api.requestOtp('+919876543210');
    final user = await api.verifyOtp(challengeId: challenge.id, code: '123456');

    expect(challenge.demoCode, '123456');
    expect(user['bloodGroup'], 'O−');
    expect(api.isAuthenticated, isTrue);
    expect(calls, ['POST /v1/auth/otp/request', 'POST /v1/auth/otp/verify']);
  });

  test('surfaces server problem messages', () async {
    final api = SaviourApi(
      client: MockClient(
        (_) async => http.Response(
          jsonEncode({
            'error': {'code': 'invalid_code', 'message': 'Code is incorrect.'},
          }),
          401,
        ),
      ),
      baseUri: Uri.parse('http://localhost:8080'),
    );

    expect(
      () => api.verifyOtp(challengeId: 'otp_test', code: '000000'),
      throwsA(
        isA<SaviourApiException>().having(
          (error) => error.message,
          'message',
          'Code is incorrect.',
        ),
      ),
    );
  });
}
