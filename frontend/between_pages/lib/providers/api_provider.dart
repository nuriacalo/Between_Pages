import 'package:between_pages/core/constants/api_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
import '../api/auth_token_storage.dart';

final authTokenStorageProvider = Provider<AuthTokenStorage>((ref) {
  return AuthTokenStorage();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final tokenStorage = ref.watch(authTokenStorageProvider);
  return ApiClient(
    baseUrl: ApiConstants.baseUrl,
    tokenStorage: tokenStorage,
  );
});