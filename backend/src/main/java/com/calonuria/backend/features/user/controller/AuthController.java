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
 * REST Controller for user authentication and authorization.
 * Handles login processing, JWT token issuance, and token refreshing.
 * Delegates actual business logic to {@link AuthService}.
 * 
 * <p>Base path: {@code /api/auth}</p>
 */
@RestController
@RequestMapping("/api/auth")
@Tag(name = "Autenticación", description = "Login y gestión de tokens JWT")
public class AuthController {

    private final AuthService authService;

    /**
     * Constructs a new {@code AuthController}.
     *
     * @param authService the service that handles authentication algorithms and token generation
     */
    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    /**
     * Authenticates a user by their email and password.
     *
     * @param loginDTO the payload containing the user's login credentials
     * @return a {@link ResponseEntity} containing an access token and a refresh token,
     *         or a 401 Unauthorized status if credentials are invalid.
     */
    @Operation(summary = "Login — devuelve accessToken y refreshToken")
    @PostMapping("/login")
    public ResponseEntity<?> login(@Valid @RequestBody LoginDTO loginDTO) {
        try {
            return ResponseEntity.ok(authService.authenticate(loginDTO));
        } catch (AuthenticationException e) {
            return ResponseEntity.status(401).body("Email o contraseña incorrectos");
        }
    }

    /**
     * Refreshes an expired access token using a valid refresh token.
     *
     * @param request the payload containing the active refresh token
     * @return a {@link ResponseEntity} containing the newly generated tokens,
     *         or a 401 Unauthorized status if the refresh token is invalid or expired.
     */
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

    /**
     * Retrieves the profile information of the currently authenticated user
     * using the access token passed in the Authorization header.
     *
     * @param authentication the authenticated security context
     * @return a {@link ResponseEntity} containing the user's data,
     *         or 401 Unauthorized if the token is missing or invalid.
     */
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
