import 'package:between_pages/features/auth/application/repositories/auth_repository.dart';
import 'package:between_pages/features/profile/domain/user_response_dto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


// Proveedor que obtiene los datos del usuario logueado
final userProfileProvider = FutureProvider<UserResponseDTO>((ref) async {
  final authRepository = ref.watch(authRepositoryProvider);
  return await authRepository.getUserProfile();
});