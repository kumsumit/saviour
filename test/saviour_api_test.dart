import 'package:flutter_test/flutter_test.dart';
import 'package:saviour/services/saviour_api.dart';

void main() {
  test(
    'OTP, authenticated operations and optional false match server schema',
    () async {
      final calls = <Map<String, Object?>>[];
      final api = SaviourApi(
        transport: (request) async {
          calls.add(request);
          final payload = switch (request['operation']) {
            'OTP_REQUEST' => {
              'otpRequested': {
                'challengeId': 'challenge',
                'expiresIn': 300,
                'developmentCode': '123456',
              },
            },
            'OTP_VERIFY' => {
              'otpVerified': {
                'accessToken': 'session',
                'user': {'id': 'user', 'available': true},
              },
            },
            'PROFILE_UPDATE' => {
              'userProfile': {'id': 'user', 'available': false},
            },
            'BLOOD_REQUEST_CREATE' => {
              'bloodRequest': {'id': 'request'},
            },
            _ => <String, Object?>{},
          };
          return {
            'protocolVersion': 1,
            'requestId': request['requestId'],
            'operation': request['operation'],
            'status': 'OK',
            ...payload,
          };
        },
      );
      final challenge = await api.requestOtp('+919876543210');
      expect(challenge.demoCode, '123456');
      expect(calls.single['otpRequest'], {'phone': '+919876543210'});
      await api.verifyOtp(challengeId: challenge.id, code: '123456');
      await api.setAvailability(false);
      expect(calls.last['accessToken'], 'session');
      expect(calls.last['profileUpdate'], {'available': false});
      await api.createRequest(
        patientName: 'Patient',
        hospital: 'Hospital',
        contactPhone: '+919876543210',
        bloodGroup: 'O−',
        urgent: false,
        units: 2,
      );
      expect((calls.last['bloodRequestCreate'] as Map)['bloodGroup'], 'O-');
      expect((calls.last['bloodRequestCreate'] as Map)['units'], 2);
      api.signOut();
      expect(api.isAuthenticated, false);
      await expectLater(
        api.reserveCamp('camp'),
        throwsA(isA<SaviourApiException>()),
      );
    },
  );
  test('server errors are surfaced', () async {
    final api = SaviourApi(
      transport: (r) async => {
        'protocolVersion': 1,
        'requestId': r['requestId'],
        'operation': r['operation'],
        'status': 'ERROR',
        'error': {'code': 'invalid_code', 'message': 'Code is incorrect.'},
      },
    );
    await expectLater(
      api.verifyOtp(challengeId: 'x', code: '000000'),
      throwsA(
        isA<SaviourApiException>().having(
          (e) => e.message,
          'message',
          'Code is incorrect.',
        ),
      ),
    );
  });
  test('rejects uncorrelated server responses', () async {
    final api = SaviourApi(
      transport: (r) async => {
        'protocolVersion': 1,
        'requestId': 'wrong',
        'operation': r['operation'],
        'status': 'OK',
        'health': {},
      },
    );
    await expectLater(api.health(), throwsA(isA<SaviourApiException>()));
  });
}
