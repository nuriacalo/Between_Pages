package com.calonuria.backend.dto.auth;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class AuthRespuestaDTO {
    private String accessToken;
    private String refreshToken;
    private String email;
    private String nombre;
    private String rol;
}