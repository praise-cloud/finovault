import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:finovault_flutter/core/mock/api.dart';
import 'package:finovault_flutter/core/mock/http_api.dart';

const _userJson = {
  'id': 'u1',
  'email': 'a@b.com',
  'fullName': 'Test User',
  'primaryRole': 'individual',
  'scheme': 'standard',
  'createdAt': '2024-01-01T00:00:00.000',
};

void main() {
  test('login posts to /rpc and parses the envelope', () async {
    final client = MockClient((request) async {
      expect(request.method, 'POST');
      expect(request.url.path, '/rpc');
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      expect(body['method'], 'login');
      expect(body['args']['email'], 'a@b.com');
      return http.Response(
        jsonEncode({
          'data': {'user': _userJson, 'token': 'tok123'},
          'error': null,
        }),
        200,
      );
    });
    final api = HttpFinovaultApi(baseUrl: 'http://test', client: client);
    final result = await api.login(email: 'a@b.com', password: 'pw');
    expect(result.token, 'tok123');
    expect(result.user.email, 'a@b.com');
  });

  test('error envelope throws FvApiException with code', () async {
    final client = MockClient((request) async => http.Response(
          jsonEncode({
            'data': null,
            'error': {'code': 'invalid_credentials', 'message': 'bad'},
          }),
          200,
        ));
    final api = HttpFinovaultApi(baseUrl: 'http://test', client: client);
    expect(
      () => api.login(email: 'a@b.com', password: 'pw'),
      throwsA(isA<FvApiException>().having((e) => e.code, 'code', 'invalid_credentials')),
    );
  });

  test('accounts parses a list from the envelope', () async {
    final client = MockClient((request) async => http.Response(
          jsonEncode({
            'data': [
              {'id': 'a1', 'name': 'Main', 'type': 'bank', 'balance': 100.0, 'institution': null}
            ],
            'error': null,
          }),
          200,
        ));
    final api = HttpFinovaultApi(baseUrl: 'http://test', client: client);
    final accounts = await api.accounts('tok');
    expect(accounts.length, 1);
    expect(accounts.first.name, 'Main');
    expect(accounts.first.balance, 100.0);
  });
}
