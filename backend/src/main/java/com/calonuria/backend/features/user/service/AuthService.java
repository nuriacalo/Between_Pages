package com.calonuria.backend.service.auth;

import com.calonuria.backend.dto.auth.AuthResponseDTO;
import com.calonuria.backend.dto.auth.LoginDTO;
import com.calonuria.backend.features.user.dto.UserResponseDTO;
import com.calonuria.backend.features.user.model.User;
import com.calonuria.backend.features.user.repository.UserRepository;
import com.calonuria.backend.shared.security.JwtUtil;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.AuthenticationException;
import org.springframework.stereotype.Service;

/**
 * Servicio para la autenticación de usuarios.
 * Gestiona login, renovación de tokens y obtención de datos del usuario.
 */
@Service
public class AuthService {

    private final AuthenticationManager authenticationManager;
    private final JwtUtil jwtUtil;
    private final UserRepository userRepository;

    public AuthService(AuthenticationManager authenticationManager,
                       JwtUtil jwtUtil,
                       UserRepository userRepository) {
        this.authenticationManager = authenticationManager;
        this.jwtUtil = jwtUtil;
        this.userRepository = userRepository;
    }

    /**
     * Autentica un usuario y genera tokens JWT.
     *
     * @param loginDTO credenciales del usuario
     * @return DTO con tokens y datos del usuario
     * @throws AuthenticationException si las credenciales son inválidas
     */
    public AuthResponseDTO authenticate(LoginDTO loginDTO) {
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        loginDTO.getEmail(), loginDTO.getPassword()
                )
        );

        User user = userRepository.findByEmail(loginDTO.getEmail())
                .orElseThrow(() -> new AuthenticationException("Usuario no encontrado") {});

        return new AuthResponseDTO(
                jwtUtil.generateAccessToken(user.getEmail()),
                jwtUtil.generateRefreshToken(user.getEmail()),
                user.getEmail(),
                user.getName(),
                user.getRole()
        );
    }

    /**
     * Renueva los tokens usando un refresh token válido.
     *
     * @param refreshToken token de refresco
     * @return DTO con nuevos tokens
     * @throws IllegalArgumentException si el token es inválido
     */
    public AuthResponseDTO refreshToken(String refreshToken) {
        String email = jwtUtil.extractEmail(refreshToken);
        if (!jwtUtil.isTokenValid(refreshToken)) {
            throw new IllegalArgumentException("Token inválido o expirado");
        }

        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("Usuario no encontrado"));

        return new AuthResponseDTO(
                jwtUtil.generateAccessToken(email),
                jwtUtil.generateRefreshToken(email),
                user.getEmail(),
                user.getName(),
                user.getRole()
        );
    }

    /**
     * Obtiene los datos del usuario autenticado.
     *
     * @param email email del usuario autenticado
     * @return DTO con datos del usuario
     * @throws IllegalArgumentException si el usuario no existe
     */
    public UserResponseDTO getCurrentUser(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("Usuario no encontrado"));

        return new UserResponseDTO(
                user.getId(),
                user.getName(),
                user.getEmail(),
                user.getRole()
        );
    }
}
