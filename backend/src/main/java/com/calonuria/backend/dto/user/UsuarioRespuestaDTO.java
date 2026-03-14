package com.calonuria.backend.dto.user;

import lombok.Data;
import lombok.AllArgsConstructor;

@Data
@AllArgsConstructor
public class UsuarioRespuestaDTO {
    private Long idUsuario;
    private String nombre;
    private String email;
    private String rol;
}