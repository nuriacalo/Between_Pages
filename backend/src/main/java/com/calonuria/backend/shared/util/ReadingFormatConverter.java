package com.calonuria.backend.shared.util;

/**
 * Utilidad para la normalización de formatos de lectura entre
 * el formato UI (español/título) y el formato de base de datos (inglés mayúsculas).
 * <p>
 * Formatos soportados por la base de datos:
 * <ul>
 *   <li>PHYSICAL - Físico</li>
 *   <li>DIGITAL - Digital / Ebook</li>
 *   <li>AUDIOBOOK - Audiolibro</li>
 *   <li>NONE - Ninguno</li>
 *   <li>BORROWED - Prestado</li>
 * </ul>
 */
public final class ReadingFormatConverter {

    private ReadingFormatConverter() {
        // Clase de utilidad, no instanciable
    }

    /**
     * Normaliza un formato de lectura desde UI al formato de base de datos.
     *
     * @param format formato en UI (ej: "Físico", "Digital", "Audiolibro")
     * @return formato en BD (ej: "PHYSICAL", "DIGITAL", "AUDIOBOOK"). Null si la entrada es null.
     */
    public static String toDatabase(String format) {
        if (format == null || format.isBlank()) {
            return null;
        }
        String normalized = format.trim();
        return switch (normalized) {
            case "Físico", "Fisico", "PHYSICAL" -> "PHYSICAL";
            case "Digital", "Ebook", "E-book", "DIGITAL" -> "DIGITAL";
            case "Audiolibro", "AUDIOBOOK" -> "AUDIOBOOK";
            case "Ninguno", "NONE" -> "NONE";
            case "Prestado", "BORROWED" -> "BORROWED";
            case "Online", "ONLINE" -> "DIGITAL"; // Online se considera digital
            default -> normalized.toUpperCase();
        };
    }

    /**
     * Convierte un formato de BD a un formato legible para la UI.
     *
     * @param dbFormat formato en BD (ej: "PHYSICAL")
     * @return formato legible (ej: "Físico"). Null si la entrada es null.
     */
    public static String toUi(String dbFormat) {
        if (dbFormat == null || dbFormat.isBlank()) {
            return null;
        }
        return switch (dbFormat.trim()) {
            case "PHYSICAL" -> "Físico";
            case "DIGITAL" -> "Digital";
            case "AUDIOBOOK" -> "Audiolibro";
            case "NONE" -> "Ninguno";
            case "BORROWED" -> "Prestado";
            default -> dbFormat;
        };
    }
}

