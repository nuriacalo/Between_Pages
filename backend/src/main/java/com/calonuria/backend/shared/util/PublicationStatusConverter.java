package com.calonuria.backend.shared.util;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Utilidad para la normalización de estados de publicación de mangas.
 * <p>
 * Convierte entre diferentes formatos de entrada (Jikan API, MangaDex, UI)
 * al formato estandarizado de base de datos.
 * <p>
 * Estados soportados por la base de datos:
 * <ul>
 *   <li>Publishing - En publicación</li>
 *   <li>Finished - Finalizado</li>
 *   <li>On Hiatus - En pausa</li>
 *   <li>Discontinued - Discontinuado</li>
 *   <li>Not yet published - Aún no publicado</li>
 * </ul>
 */
public final class PublicationStatusConverter {

    private static final Logger log = LoggerFactory.getLogger(PublicationStatusConverter.class);

    private PublicationStatusConverter() {
        // Clase de utilidad, no instanciable
    }

    /**
     * Normaliza un estado de publicación desde cualquier formato conocido
     * al formato estandarizado de base de datos.
     *
     * @param status estado en cualquier formato (Jikan, MangaDex, UI)
     * @return estado normalizado para BD. Null si la entrada es null.
     */
    public static String toDatabase(String status) {
        if (status == null || status.isBlank()) {
            return null;
        }

        return switch (status.trim().toLowerCase()) {
            case "publishing", "ongoing" -> "Publishing";
            case "finished", "completed" -> "Finished";
            case "on_hiatus", "hiatus", "on hiatus" -> "On Hiatus";
            case "discontinued", "cancelled", "canceled" -> "Discontinued";
            case "not_yet_published", "not yet published" -> "Not yet published";
            default -> {
                log.warn("Estado de publicación desconocido: {}", status);
                yield status;
            }
        };
    }
}
