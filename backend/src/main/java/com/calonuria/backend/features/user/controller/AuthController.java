package com.calonuria.backend.features.user.controller;

import com.calonuria.backend.features.user.dto.auth.LoginDTO;
import com.calonuria.backend.features.user.dto.auth.RefreshTokenRequestDTO;
import com.calonuria.backend.features.user.service.AuthService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.web.bind.annotation.*;

/**
 * Controlador para la autenticación de usuarios.
 * Delega la lógica de negocio a AuthService.
 */
@RestController
@RequestMapping("/api/auth")
@Tag(name = "Autenticación", description = "Login y gestión de tokens JWT")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @Operation(summary = "Login — devuelve accessToken y refreshToken")
    @PostMapping("/login")
    public ResponseEntity<?> login(@Valid @RequestBody LoginDTO loginDTO) {
        try {
            return ResponseEntity.ok(authService.authenticate(loginDTO));
        } catch (AuthenticationException e) {
            return ResponseEntity.status(401).body("Email o contraseña incorrectos");
        }
    }

    @Operation(summary = "Renovar tokens")
    @PostMapping("/refresh")
    public ResponseEntity<?> refresh(
            @Valid @RequestBody RefreshTokenRequestDTO request) {
        try {
            return ResponseEntity.ok(authService.refreshToken(request.getRefreshToken()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(401).body(e.getMessage());
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
        try {
            return ResponseEntity.ok(authService.getCurrentUser(authentication.getName()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(401).body(e.getMessage());
        }
    }
}