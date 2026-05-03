package com.calonuria.backend.service.journal;

/**
 * Utilidad para la conversión de estados de lectura entre el formato UI (español)
 * y el formato de base de datos (inglés mayúsculas).
 * <p>
 * Estados soportados por la base de datos:
 * <ul>
 *   <li>PENDING - Pendiente</li>
 *   <li>READING - Leyendo</li>
 *   <li>FINISHED - Terminado</li>
 *   <li>DROPPED - Abandonado</li>
 *   <li>PAUSED - Pausado</li>
 *   <li>TBR - Por leer (To Be Read)</li>
 *   <li>WISHLIST - Lista de deseos</li>
 *   <li>BOUGHT - Comprado</li>
 * </ul>
 */
public final class JournalStatusConverter {

    private JournalStatusConverter() {
        // Clase de utilidad, no instanciable
    }

    /**
     * Convierte un estado en español al formato inglés mayúsculas de la BD.
     *
     * @param status estado en español (ej: "Leyendo", "Terminado")
     * @return estado en formato BD (ej: "READING", "FINISHED"). Si es null, retorna "PENDING".
     */
    public static String toDatabase(String status) {
        if (status == null || status.isBlank()) {
            return "PENDING";
        }
        return switch (status.trim()) {
            case "Pendiente" -> "PENDING";
            case "Leyendo" -> "READING";
            case "Terminado" -> "FINISHED";
            case "Abandonado" -> "DROPPED";
            case "Pausado" -> "PAUSED";
            case "Por leer" -> "TBR";
            case "Lista de deseos" -> "WISHLIST";
            case "Comprado" -> "BOUGHT";
            default -> status.toUpperCase();
        };
    }

    /**
     * Convierte un estado de la BD al formato UI en español.
     *
     * @param dbStatus estado en formato BD (ej: "READING", "FINISHED")
     * @return estado en español. Si es null, retorna "Pendiente".
     */
    public static String toUi(String dbStatus) {
        if (dbStatus == null || dbStatus.isBlank()) {
            return "Pendiente";
        }
        return switch (dbStatus.trim()) {
            case "PENDING" -> "Pendiente";
            case "READING" -> "Leyendo";
            case "FINISHED" -> "Terminado";
            case "DROPPED" -> "Abandonado";
            case "PAUSED" -> "Pausado";
            case "TBR" -> "Por leer";
            case "WISHLIST" -> "Lista de deseos";
            case "BOUGHT" -> "Comprado";
            default -> dbStatus;
        };
    }
}
