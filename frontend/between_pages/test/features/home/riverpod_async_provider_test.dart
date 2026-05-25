import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('Riverpod AsyncProvider Tests', () {
    test('StateNotifier mantiene estado correctamente', () async {
      final container = ProviderContainer();
      
      // Crear un provider simple que cambia estado
      final counterProvider = StateNotifierProvider<CounterNotifier, int>((ref) {
        return CounterNotifier();
      });
      
      // Leer estado inicial
      expect(container.read(counterProvider), equals(0));
      
      // Cambiar estado
      container.read(counterProvider.notifier).increment();
      expect(container.read(counterProvider), equals(1));
      
      container.read(counterProvider.notifier).increment();
      expect(container.read(counterProvider), equals(2));
    });

    test('FutureProvider resuelve correctamente', () async {
      final container = ProviderContainer();
      
      final futureProvider = FutureProvider<String>((ref) async {
        await Future.delayed(const Duration(milliseconds: 10));
        return 'Dato cargado';
      });
      
      // Verificar estado loading/data
      final state = container.read(futureProvider);
      
      expect(state.when(
        data: (data) => data,
        loading: () => 'loading',
        error: (e, st) => 'error',
      ), equals('loading')); // Inicial es loading
    });

    test('Provider notifier puede invalidar cache', () async {
      final container = ProviderContainer();
      
      int callCount = 0;
      final cachingProvider = FutureProvider<int>((ref) async {
        callCount++;
        return callCount;
      });
      
      // Primera lectura
      await container.read(cachingProvider.future);
      expect(callCount, equals(1));
      
      // Invalidar y releer
      container.invalidate(cachingProvider);
      await container.read(cachingProvider.future);
      expect(callCount, equals(2));
    });
  });
}

class CounterNotifier extends StateNotifier<int> {
  CounterNotifier() : super(0);
  
  void increment() => state++;
  void decrement() => state--;
}
