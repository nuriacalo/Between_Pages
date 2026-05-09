import 'package:between_pages/repositories/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:between_pages/models/user/user_response_dto.dart';

// Proveedor que obtiene los datos del usuario logueado
final userProfileProvider = FutureProvider<UserResponseDTO>((ref) async {
  final authRepository = ref.watch(authRepositoryProvider);
  return await authRepository.getUserProfile();
});