import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:finovault_flutter/core/mock/api.dart';
import 'package:finovault_flutter/core/mock/http_api.dart';
import 'package:finovault_flutter/core/models.dart';

void main() {
  group('HttpFinovaultApi', () {
    test('login posts the RPC envelope and decodes the data field', () async {
      late http.Request captured;
      final client = MockClient((request) async {
        captured = request;
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['method'], 'login');
        expect(body['args']['email'], 'u@example.com');
        expect(body['args']['password'], 'secret');
        return http.Response(
          jsonEncode({
            'data': {
              'user': UserProfile(
                id: '1',
                email: 'u@example.com',
                fullName: 'Test',
                primaryRole: PrimaryRole.individual,
                scheme: RoleScheme.standard,
                createdAt: _epoch,
              ).toJson(),
              'token': 'tok-123',
            },
          }),
          200,
        );
      });

      final api = HttpFinovaultApi(baseUrl: 'https://api.example.com', client: client);
      final result = await api.login(email: 'u@example.com', password: 'secret');

      expect(captured.url.toString(), 'https://api.example.com/rpc');
      expect(captured.headers['Authorization'], isNull); // no token on login
      expect(result.token, 'tok-123');
      expect(result.user.email, 'u@example.com');
    });

    test('authenticated calls send a Bearer token header', () async {
      late http.Request captured;
      final client = MockClient((request) async {
        captured = request;
        return http.Response(
          jsonEncode({
            'data': UserProfile(
              id: '1',
              email: 'u@example.com',
              fullName: 'Test',
              primaryRole: PrimaryRole.individual,
              scheme: RoleScheme.standard,
              createdAt: _epoch,
            ).toJson(),
          }),
          200,
        );
      });

      final api = HttpFinovaultApi(baseUrl: 'https://api.example.com', client: client);
      await api.getSession('my-token');

      expect(captured.headers['Authorization'], 'Bearer my-token');
    });

    test('enums are encoded as their .name and DateTime as ISO-8601', () async {
      late Map<String, dynamic> args;
      final due = DateTime(2026, 4, 1);
      final client = MockClient((request) async {
        args = (jsonDecode(request.body) as Map<String, dynamic>)['args'] as Map<String, dynamic>;
        final sample = Invoice(
          id: 'i1',
          clientName: 'Client',
          amount: 100,
          dueDate: due,
          status: InvoiceStatus.sent,
        ).toJson();
        return http.Response(jsonEncode({'data': sample}), 200);
      });

      final api = HttpFinovaultApi(baseUrl: 'https://api.example.com', client: client);
      final inv = await api.createInvoice('t', clientName: 'Client', amount: 100, dueDate: due);

      expect(args['dueDate'], due.toIso8601String());
      expect(inv.dueDate, due);
    });

    test('BillCategory enum is sent as its name', () async {
      late Map<String, dynamic> args;
      final client = MockClient((request) async {
        args = (jsonDecode(request.body) as Map<String, dynamic>)['args'] as Map<String, dynamic>;
        final sample = BillPayment(
          id: 'bp1',
          category: BillCategory.electricity,
          billerName: 'CWA',
          amount: 100,
          status: BillPaymentStatus.paid,
          date: _epoch,
          customerRef: 'REF',
        ).toJson();
        return http.Response(jsonEncode({'data': sample}), 200);
      });

      final api = HttpFinovaultApi(baseUrl: 'https://api.example.com', client: client);
      final payment = await api.payBill(
        't',
        category: BillCategory.electricity,
        billerName: 'CWA',
        amount: 100,
        customerRef: 'REF',
      );

      expect(args['category'], 'electricity');
      expect(payment.status, BillPaymentStatus.paid);
    });

    test('createTransfer sends an idempotency key and decodes the transfer', () async {
      late Map<String, dynamic> args;
      final client = MockClient((request) async {
        args = (jsonDecode(request.body) as Map<String, dynamic>)['args'] as Map<String, dynamic>;
        final sample = Transfer(
          id: 'tr1',
          sourceAccountId: 'a1',
          payeeName: 'Bob',
          destination: 'ACC',
          amount: 100,
          fee: 20,
          total: 120,
          status: TransferStatus.completed,
          createdAt: _epoch,
          externalRef: 'EXT-T1',
          idempotencyKey: 'k1',
        ).toJson();
        return http.Response(jsonEncode({'data': sample}), 200);
      });

      final api = HttpFinovaultApi(baseUrl: 'https://api.example.com', client: client);
      final transfer = await api.createTransfer(
        't',
        sourceAccountId: 'a1',
        payeeName: 'Bob',
        destination: 'ACC',
        amount: 100,
        idempotencyKey: 'k1',
      );

      expect(args['idempotencyKey'], 'k1');
      expect(transfer.fee, 20);
      expect(transfer.total, 120);
    });

    test('an error envelope is surfaced as FvApiException', () async {
      final client = MockClient((_) async => http.Response(
            jsonEncode({'error': {'code': 'invalid_credentials', 'message': 'Bad creds'}}),
            200,
          ));
      final api = HttpFinovaultApi(baseUrl: 'https://api.example.com', client: client);

      expect(
        () => api.login(email: 'a', password: 'b'),
        throwsA(isA<FvApiException>()
            .having((e) => e.code, 'code', 'invalid_credentials')
            .having((e) => e.message, 'message', 'Bad creds')),
      );
    });
  });
}

final DateTime _epoch = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
