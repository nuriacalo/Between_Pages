package com.calonuria.backend.dto.auth;

import lombok.AllArgsConstructor;
import lombok.Data;

/**
 * DTO para la respuesta de autenticación con tokens JWT.
 */
@Data
@AllArgsConstructor
public class AuthResponseDTO {
    private String accessToken;
    private String refreshToken;
    private String email;
    private String name;
    private String role;
}
