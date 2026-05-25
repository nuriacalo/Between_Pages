import 'package:flutter_test/flutter_test.dart';
import 'package:between_pages/core/constants/api_constants.dart';

void main() {
  group('ApiConstants', () {
    test('baseUrl no está vacía', () {
      expect(ApiConstants.baseUrl, isNotEmpty);
    });

    test('jikanBaseUrl es válida', () {
      expect(ApiConstants.jikanBaseUrl, equals('https://api.jikan.moe/v4'));
    });

    test('endpoints de autenticación están correctamente formados', () {
      expect(ApiConstants.login, contains('/auth/login'));
      expect(ApiConstants.refresh, contains('/auth/refresh'));
      expect(ApiConstants.me, contains('/auth/me'));
    });

    test('endpoints de usuario están correctamente formados', () {
      expect(ApiConstants.userRegister, contains('/user/register'));
      expect(ApiConstants.user, contains('/user/'));
    });

    test('endpoints de libros están correctamente formados', () {
      expect(ApiConstants.bookSearch, contains('/book/search'));
      expect(ApiConstants.bookSearchLocal, contains('/book/search/local'));
      expect(ApiConstants.book, contains('/book'));
    });

    test('endpoints de manga están correctamente formados', () {
      expect(ApiConstants.mangaSearch, contains('/manga/search'));
      expect(ApiConstants.mangaSearchLocal, contains('/manga/search/local'));
      expect(ApiConstants.manga, contains('/manga'));
    });

    test('endpoints de fanfiction están correctamente formados', () {
      expect(ApiConstants.fanficSearch, contains('/fanfiction/search'));
      expect(ApiConstants.fanficStatus, contains('/fanfiction/status'));
      expect(ApiConstants.fanfic, contains('/fanfiction'));
    });

    test('todos los endpoints contienen el baseUrl', () {
      expect(ApiConstants.login, contains(ApiConstants.baseUrl));
      expect(ApiConstants.user, contains(ApiConstants.baseUrl));
      expect(ApiConstants.book, contains(ApiConstants.baseUrl));
      expect(ApiConstants.manga, contains(ApiConstants.baseUrl));
      expect(ApiConstants.fanfic, contains(ApiConstants.baseUrl));
    });
  });
}
