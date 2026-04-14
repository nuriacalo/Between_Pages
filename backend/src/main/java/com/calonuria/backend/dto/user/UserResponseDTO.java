package com.calonuria.backend.dto.user;

import lombok.Data;
import lombok.AllArgsConstructor;

/**
 * DTO para la respuesta con información de usuario.
 */
@Data
@AllArgsConstructor
public class UserResponseDTO {

    /**
     * ID del usuario.
     */
    private Long id;

    /**
     * Nombre del usuario.
     */
    private String name;

    /**
     * Correo electrónico del usuario.
     */
    private String email;

    /**
     * Rol del usuario (USER o ADMIN).
     */
    private String role;
}