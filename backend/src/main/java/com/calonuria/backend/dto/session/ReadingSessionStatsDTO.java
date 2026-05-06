package com.calonuria.backend.dto.session;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO de respuesta para estadísticas de velocidad de lectura.
 * Calculado desde historial de sesiones del usuario.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "Estadísticas de velocidad para estimar tiempo restante")
public class ReadingSessionStatsDTO {

    @Schema(description = "Velocidad promedio en páginas por hora", example = "30.5")
    private Double speedPagesPerHour;

    @Schema(description = "Tiempo estimado restante en segundos para remainingPages", example = "7200")
    private Long estimatedTimeRemainingSeconds;
}
