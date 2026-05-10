package com.calonuria.backend.features.session.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO para registrar una sesión de lectura del usuario.
 * Se envía desde frontend al finalizar timer.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "Registro de sesión de lectura")
public class ReadingSessionRecordDTO {

    @NotNull(message = "ID de usuario requerido")
    @Min(value = 1, message = "ID de usuario inválido")
    @Schema(description = "ID del usuario")
    private Long userId;

    @Schema(description = "ID del libro (si aplica)")
    private Long bookId;

    @Schema(description = "ID del manga (si aplica)")
    private Long mangaId;

    @Schema(description = "ID del fanfic (si aplica)")
    private Long fanficId;

    @NotNull(message = "Duración requerida")
    @Min(value = 1, message = "Duración mínima 1 segundo")
    @Schema(description = "Duración de la sesión en segundos")
    private Integer durationSeconds;

    @Min(value = 0, message = "Páginas leídas no puede ser negativo")
    @Schema(description = "Páginas/capítulos leídos en la sesión")
    private Integer pagesRead;
}
