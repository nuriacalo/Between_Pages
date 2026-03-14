package com.calonuria.backend.dto.list;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class ListaRegistroDTO {

    @NotNull(message = "El usuario es obligatorio")
    private Long idUsuario;

    @NotBlank(message = "El nombre es obligatorio")
    @Size(min = 1, max = 150, message = "El nombre debe tener entre 1 y 150 caracteres")
    private String nombre;
}