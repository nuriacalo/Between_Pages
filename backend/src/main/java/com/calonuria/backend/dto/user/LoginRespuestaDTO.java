package com.calonuria.backend.dto.user;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class LoginRespuestaDTO {
    private String token;
    private String email;
    private String nombre;
    private String rol;
}