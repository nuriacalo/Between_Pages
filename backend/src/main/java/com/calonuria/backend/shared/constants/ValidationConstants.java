package com.calonuria.backend.shared.constants;

/**
 * Constantes para validaciones de DTOs.
 * Centraliza los patrones de validación para mantener consistencia.
 */
public final class ValidationConstants {

    private ValidationConstants() {
        // Clase de utilidad, no instanciable
    }

    /**
     * Estados de lectura válidos para journals.
     * WISHLIST, TBR, READING, PAUSED, DROPPED, FINISHED.
     * Eliminados: PENDING (redundante con TBR), BOUGHT (usar ownership).
     */
    public static final String READING_STATUS_PATTERN =
            "WISHLIST|TBR|READING|PAUSED|DROPPED|FINISHED";

    public static final String READING_STATUS_MESSAGE = "Estado no válido";

    /**
     * Formatos de lectura para libros.
     * PHYSICAL, DIGITAL, AUDIOBOOK.
     */
    public static final String BOOK_READING_FORMAT_PATTERN = "PHYSICAL|DIGITAL|AUDIOBOOK";

    public static final String BOOK_READING_FORMAT_MESSAGE = "Formato no válido";

    /**
     * Formatos de lectura para mangas.
     * PHYSICAL, DIGITAL.
     */
    public static final String MANGA_READING_FORMAT_PATTERN = "PHYSICAL|DIGITAL";

    public static final String MANGA_READING_FORMAT_MESSAGE = "Formato no válido";

    /**
     * Tipos de propiedad.
     * DIGITAL, PHYSICAL, NONE, BORROWED.
     */
    public static final String OWNERSHIP_PATTERN = "DIGITAL|PHYSICAL|NONE|BORROWED";

    public static final String OWNERSHIP_MESSAGE = "Propiedad no válida";

    /**
     * Niveles de angst para fanfics.
     * NONE, LOW, MEDIUM, HIGH, EXTREME.
     */
    public static final String ANGST_LEVEL_PATTERN = "NONE|LOW|MEDIUM|HIGH|EXTREME";

    public static final String ANGST_LEVEL_MESSAGE = "Nivel de angst no válido";

    /**
     * Tipos de canon para fanfics.
     * CANON, AU, CANON_DIVERGENT.
     */
    public static final String CANON_TYPE_PATTERN = "CANON|AU|CANON_DIVERGENT";

    public static final String CANON_TYPE_MESSAGE = "Valor no válido";

    /**
     * Mensajes de validación comunes.
     */
    public static final String USER_ID_REQUIRED = "El usuario es obligatorio";
    public static final String STATUS_REQUIRED = "El estado es obligatorio";
    public static final String RATING_MIN = "La valoración mínima es 1";
    public static final String RATING_MAX = "La valoración máxima es 10";
    public static final String TEAR_DROPS_MIN = "Mínimo 0 lágrimas";
    public static final String TEAR_DROPS_MAX = "Máximo 5 lágrimas";
    public static final String SPICE_FLAMES_MIN = "Mínimo 0 flames";
    public static final String SPICE_FLAMES_MAX = "Máximo 5 flames";
}
