package com.calonuria.backend.dto.auth;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

/**
 * DTO para solicitar la renovación de tokens JWT.
 * Contiene el refresh token necesario para obtener un nuevo access token.
 */
@Data
public class RefreshTokenRequestDTO {
    @NotBlank
    private String refreshToken;
}