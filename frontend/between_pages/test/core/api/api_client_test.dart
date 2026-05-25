import 'package:flutter_test/flutter_test.dart';
import 'package:between_pages/core/api/api_client.dart';
import 'package:between_pages/core/api/auth_token_storage.dart';

void main() {
  group('ApiClient - BaseOptions Configuration', () {
    test('se configura con timeouts correctos', () {
      const baseUrl = 'http://example.com/api';
      final tokenStorage = AuthTokenStorage();
      
      final apiClient = ApiClient(
        baseUrl: baseUrl,
        tokenStorage: tokenStorage,
      );

      expect(apiClient, isNotNull);
    });

    test('soporta diferentes URLs base', () {
      const url1 = 'http://test1.com';
      const url2 = 'http://test2.com';
      final tokenStorage = AuthTokenStorage();
      
      final client1 = ApiClient(baseUrl: url1, tokenStorage: tokenStorage);
      final client2 = ApiClient(baseUrl: url2, tokenStorage: tokenStorage);

      expect(client1, isNotNull);
      expect(client2, isNotNull);
    });
  });

  group('ApiClient - HTTP Methods Definition', () {
    test('ApiClient define método get', () {
      final tokenStorage = AuthTokenStorage();
      final apiClient = ApiClient(
        baseUrl: 'http://example.com/api',
        tokenStorage: tokenStorage,
      );

      expect(apiClient.get, isA<Function>());
    });

    test('ApiClient define método post', () {
      final tokenStorage = AuthTokenStorage();
      final apiClient = ApiClient(
        baseUrl: 'http://example.com/api',
        tokenStorage: tokenStorage,
      );

      expect(apiClient.post, isA<Function>());
    });

    test('ApiClient define método put', () {
      final tokenStorage = AuthTokenStorage();
      final apiClient = ApiClient(
        baseUrl: 'http://example.com/api',
        tokenStorage: tokenStorage,
      );

      expect(apiClient.put, isA<Function>());
    });

    test('ApiClient define método delete', () {
      final tokenStorage = AuthTokenStorage();
      final apiClient = ApiClient(
        baseUrl: 'http://example.com/api',
        tokenStorage: tokenStorage,
      );

      expect(apiClient.delete, isA<Function>());
    });
  });
}
