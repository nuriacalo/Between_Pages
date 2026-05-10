package com.calonuria.backend.shared.util;

/**
 * Utilidad para la conversión de estados de lectura entre el formato UI (español)
 * y el formato de base de datos (inglés mayúsculas).
 * <p>
 * Estados soportados por la base de datos:
 * <ul>
 *   <li>WISHLIST - Lista de deseos</li>
 *   <li>TBR - Por leer (To Be Read)</li>
 *   <li>READING - Leyendo</li>
 *   <li>PAUSED - Pausado</li>
 *   <li>DROPPED - Abandonado</li>
 *   <li>FINISHED - Terminado</li>
 * </ul>
 * <p>
 */
public final class JournalStatusConverter {

    private JournalStatusConverter() {
        // Clase de utilidad, no instanciable
    }

    /**
     * Convierte un estado en español al formato inglés mayúsculas de la BD.
     *
     * @param status estado en español (ej: "Leyendo", "Terminado")
     * @return estado en formato BD (ej: "READING", "FINISHED"). Si es null, retorna "TBR".
     */
    public static String toDatabase(String status) {
        if (status == null || status.isBlank()) {
            return "TBR";
        }
        return switch (status.trim()) {
            case "Lista de deseos" -> "WISHLIST";
            case "Por leer", "Pendiente" -> "TBR";
            case "Leyendo" -> "READING";
            case "Pausado" -> "PAUSED";
            case "Abandonado" -> "DROPPED";
            case "Terminado" -> "FINISHED";
            default -> status.toUpperCase();
        };
    }

    /**
     * Convierte un estado de la BD al formato UI en español.
     *
     * @param dbStatus estado en formato BD (ej: "READING", "FINISHED")
     * @return estado en español. Si es null, retorna "Por leer".
     */
    public static String toUi(String dbStatus) {
        if (dbStatus == null || dbStatus.isBlank()) {
            return "Por leer";
        }
        return switch (dbStatus.trim()) {
            case "WISHLIST" -> "Lista de deseos";
            case "TBR" -> "Por leer";
            case "READING" -> "Leyendo";
            case "PAUSED" -> "Pausado";
            case "DROPPED" -> "Abandonado";
            case "FINISHED" -> "Terminado";
            default -> dbStatus;
        };
    }
}
