package com.calonuria.backend.features.user.dto.auth;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

/**
 * DTO para el login de usuarios.
 * Contiene las credenciales necesarias para autenticación.
 */
@Data
public class LoginDTO {
    @NotBlank @Email
    private String email;

    @NotBlank
    private String password;
}