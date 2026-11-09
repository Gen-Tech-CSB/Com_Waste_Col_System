import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:community_waste_frontend/services/api_client.dart';

void main() {
  test(
    'login uses API credentials, saves token and clears expired sessions',
    () async {
      final api = ApiClient(
        client: MockClient((request) async {
          if (request.url.path.endsWith('/login')) {
            expect(jsonDecode(request.body), {
              'email': 'new@example.test',
              'password': 'password123',
            });
            return http.Response(
              jsonEncode({
                'success': true,
                'data': {
                  'token': 'session-token',
                  'user': {'id': 12, 'role': 'resident'},
                },
              }),
              200,
            );
          }
          expect(request.headers['Authorization'], 'Bearer session-token');
          return http.Response('{"success":false}', 401);
        }),
      );
      expect((await api.login(' NEW@example.test ', 'password123'))['id'], 12);
      expect(api.token, 'session-token');
      await expectLater(
        api.request('GET', '/auth/me', authenticated: true),
        throwsA(isA<ApiException>().having((e) => e.status, 'status', 401)),
      );
      expect(api.token, isNull);
      expect(api.user, isNull);
    },
  );
  test('server validation errors remain actionable without exposing internal errors', () async {
    final api = ApiClient(
      client: MockClient(
        (request) async => http.Response(
          '{"success":false,"message":"Invalid input","errors":[{"path":["email"],"message":"Invalid email"}]}',
          400,
        ),
      ),
    );
    await expectLater(
      api.request('POST', '/auth/register'),
      throwsA(
        isA<ApiException>().having(
          (e) => e.fields['email'],
          'email field',
          'Invalid email',
        ),
      ),
    );
    final server = ApiClient(
      client: MockClient(
        (_) async => http.Response('password=private database error', 500),
      ),
    );
    await expectLater(
      server.request('GET', '/areas'),
      throwsA(
        isA<ApiException>().having(
          (e) => e.message,
          'safe message',
          contains('unavailable'),
        ),
      ),
    );
  });
  test(
    'HTML responses, offline errors, and timeouts have friendly messages',
    () async {
      final invalid = ApiClient(
        client: MockClient(
          (_) async => http.Response('<html>proxy</html>', 200),
        ),
      );
      await expectLater(
        invalid.request('GET', '/areas'),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            contains('unexpected'),
          ),
        ),
      );
      final offline = ApiClient(
        client: MockClient(
          (_) async => throw http.ClientException('network details'),
        ),
      );
      await expectLater(
        offline.request('GET', '/areas'),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            contains('Cannot reach'),
          ),
        ),
      );
      final timeout = ApiClient(
        timeout: const Duration(milliseconds: 1),
        client: MockClient((_) => Completer<http.Response>().future),
      );
      await expectLater(
        timeout.request('GET', '/areas'),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            contains('timed out'),
          ),
        ),
      );
    },
  );
}
