import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('Go Router Navigation Tests', () {
    test('GoRouter se inicializa con ruta inicial correcta', () {
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(path: '/', builder: (c, s) => const _DummyWidget()),
          GoRoute(path: '/login', builder: (c, s) => const _DummyWidget()),
        ],
      );
      
      expect(router.routeInformationProvider.value.location, equals('/'));
    });

    test('GoRouter puede cambiar ruta', () {
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(path: '/', builder: (c, s) => const _DummyWidget()),
          GoRoute(path: '/home', builder: (c, s) => const _DummyWidget()),
          GoRoute(path: '/profile', builder: (c, s) => const _DummyWidget()),
        ],
      );
      
      router.go('/home');
      expect(router.routeInformationProvider.value.location, equals('/home'));
      
      router.go('/profile');
      expect(router.routeInformationProvider.value.location, equals('/profile'));
    });

    test('GoRouter maneja rutas con parámetros', () {
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(path: '/', builder: (c, s) => const _DummyWidget()),
          GoRoute(
            path: '/item/:id',
            builder: (c, s) {
              final id = s.pathParameters['id'];
              expect(id, equals('123'));
              return const _DummyWidget();
            },
          ),
        ],
      );
      
      router.go('/item/123');
      expect(router.routeInformationProvider.value.location, contains('/item/'));
    });

    test('GoRouter soporta rutas anidadas', () {
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (c, s) => const _DummyWidget(),
            routes: [
              GoRoute(
                path: 'detail/:id',
                builder: (c, s) => const _DummyWidget(),
              ),
            ],
          ),
        ],
      );
      
      router.go('/detail/456');
      expect(router.routeInformationProvider.value.location, contains('detail'));
    });
  });
}

class _DummyWidget extends StatelessWidget {
  const _DummyWidget();

  @override
  Widget build(BuildContext context) => const SizedBox();
}
