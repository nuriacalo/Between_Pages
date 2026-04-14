package com.calonuria.backend.controller.auth;

import com.calonuria.backend.dto.auth.AuthResponseDTO;
import com.calonuria.backend.dto.auth.LoginDTO;
import com.calonuria.backend.dto.auth.RefreshTokenRequestDTO;
import com.calonuria.backend.dto.user.UserResponseDTO;
import com.calonuria.backend.model.user.User;
import com.calonuria.backend.repository.user.UserRepository;
import com.calonuria.backend.security.JwtUtil;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.web.bind.annotation.*;

/**
 * Controlador para la autenticación de usuarios.
 */
@RestController
@RequestMapping("/api/auth")
@Tag(name = "Autenticación", description = "Login y gestión de tokens JWT")
public class AuthController {

    @Autowired private AuthenticationManager authenticationManager;
    @Autowired private JwtUtil jwtUtil;
    @Autowired private UserRepository userRepository;

    @Operation(summary = "Login — devuelve accessToken y refreshToken")
    @PostMapping("/login")
    public ResponseEntity<?> login(@Valid @RequestBody LoginDTO loginDTO) {
        try {
            authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(
                            loginDTO.getEmail(), loginDTO.getPassword()
                    )
            );
            User user = userRepository.findByEmail(loginDTO.getEmail())
                    .orElseThrow();

            return ResponseEntity.ok(new AuthResponseDTO(
                    jwtUtil.generateAccessToken(user.getEmail()),
                    jwtUtil.generateRefreshToken(user.getEmail()),
                    user.getEmail(),
                    user.getName(),
                    user.getRole()
            ));
        } catch (AuthenticationException e) {
            return ResponseEntity.status(401).body("Email o contraseña incorrectos");
        }
    }

    @Operation(summary = "Renovar tokens")
    @PostMapping("/refresh")
    public ResponseEntity<?> refresh(
            @Valid @RequestBody RefreshTokenRequestDTO request) {
        try {
            String email = jwtUtil.extractEmail(request.getRefreshToken());
            if (!jwtUtil.isTokenValid(request.getRefreshToken())) {
                return ResponseEntity.status(401).body("Token inválido o expirado");
            }
            User user = userRepository.findByEmail(email).orElseThrow();

            return ResponseEntity.ok(new AuthResponseDTO(
                    jwtUtil.generateAccessToken(email),
                    jwtUtil.generateRefreshToken(email),
                    user.getEmail(),
                    user.getName(),
                    user.getRole()
            ));
        } catch (Exception e) {
            return ResponseEntity.status(401).body("Refresh token inválido");
        }
    }

    @Operation(summary = "Datos del usuario autenticado")
    @GetMapping("/me")
    public ResponseEntity<?> getCurrentUser(Authentication authentication) {
        if (authentication == null || !authentication.isAuthenticated()) {
            return ResponseEntity.status(401).body("No autenticado");
        }
        User user = userRepository.findByEmail(authentication.getName())
                .orElseThrow();

        return ResponseEntity.ok(new UserResponseDTO(
                user.getId(),
                user.getName(),
                user.getEmail(),
                user.getRole()
        ));
    }
}