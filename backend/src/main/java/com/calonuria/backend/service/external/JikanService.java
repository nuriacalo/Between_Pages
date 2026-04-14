package com.calonuria.backend.service.external;

import com.calonuria.backend.dto.catalog.MangaResponseDTO;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

import java.util.ArrayList;
import java.util.List;

/**
 * Servicio para integración con Jikan API (MyAnimeList unofficial API).
 * Proporciona búsqueda de manga desde MyAnimeList.
 * 
 * Rate limits: 60 requests/min, 3 requests/sec
 * Documentación: https://api.jikan.moe/v4/
 */
@Service
public class JikanService {

    private static final Logger log = LoggerFactory.getLogger(JikanService.class);
    private static final String JIKAN_BASE_URL = "https://api.jikan.moe/v4";

    @Autowired
    private RestTemplate restTemplate;

    /**
     * Busca manga por título en MyAnimeList vía Jikan.
     * @param title título a buscar
     * @param page página de resultados (default: 1)
     * @param limit resultados por página (max: 25)
     * @return lista de manga encontrado
     */
    public List<MangaResponseDTO> searchManga(String title, int page, int limit) {
        UriComponentsBuilder urlBuilder = UriComponentsBuilder
                .fromHttpUrl(JIKAN_BASE_URL + "/manga")
                .queryParam("q", title)
                .queryParam("page", page)
                .queryParam("limit", Math.min(limit, 25)); // Jikan max: 25

        String url = urlBuilder.build().encode().toUriString();
        log.info("Buscando manga en Jikan: {}", title);

        List<MangaResponseDTO> results = new ArrayList<>();
        
        try {
            String json = restTemplate.getForObject(url, String.class);
            JsonNode root = new ObjectMapper().readTree(json);
            JsonNode data = root.path("data");

            if (data.isArray()) {
                for (JsonNode item : data) {
                    results.add(mapJikanToDTO(item));
                }
            }
            
            log.info("Encontrados {} resultados en Jikan", results.size());
        } catch (Exception e) {
            log.error("Error al conectar con Jikan API: {}", e.getMessage());
        }

        return results;
    }

    /**
     * Obtiene detalles de un manga específico por ID de MyAnimeList.
     * @param malId ID de MyAnimeList
     * @return DTO con información del manga
     */
    public MangaResponseDTO getMangaById(int malId) {
        String url = JIKAN_BASE_URL + "/manga/" + malId;
        log.info("Obteniendo manga de Jikan: ID {}", malId);

        try {
            String json = restTemplate.getForObject(url, String.class);
            JsonNode root = new ObjectMapper().readTree(json);
            return mapJikanToDTO(root.path("data"));
        } catch (Exception e) {
            log.error("Error al obtener manga de Jikan: {}", e.getMessage());
            return null;
        }
    }

    /**
     * Mapea respuesta de Jikan a MangaResponseDTO.
     * Jikan usa MyAnimeList ID, no MangaDex ID.
     */
    private MangaResponseDTO mapJikanToDTO(JsonNode manga) {
        MangaResponseDTO dto = new MangaResponseDTO();
        
        dto.setId(null); // No es nuestro ID de BD, es externo
        dto.setMangadexId(null); // Jikan usa MAL ID, no MangaDex
        dto.setSource("MyAnimeList (Jikan)");
        
        // Título
        String title = manga.has("title") ? manga.get("title").asText() : null;
        if (title == null && manga.has("title_english")) {
            title = manga.get("title_english").asText();
        }
        dto.setTitle(title);
        
        // Autores
        dto.setAuthor(extractAuthors(manga.path("authors")));
        
        // Demografía
        JsonNode demographics = manga.path("demographics");
        if (demographics.isArray() && demographics.size() > 0) {
            dto.setDemographic(demographics.get(0).path("name").asText());
        }
        
        // Géneros
        dto.setGenre(extractGenres(manga.path("genres")));
        
        // Descripción
        String synopsis = manga.has("synopsis") ? manga.get("synopsis").asText() : null;
        String background = manga.has("background") ? manga.get("background").asText() : null;
        dto.setDescription(synopsis != null ? synopsis : background);
        
        // Imagen de portada
        JsonNode images = manga.path("images");
        if (images.has("jpg")) {
            JsonNode jpg = images.path("jpg");
            String largeImage = jpg.has("large_image_url") ? jpg.get("large_image_url").asText() : null;
            String imageUrl = jpg.has("image_url") ? jpg.get("image_url").asText() : null;
            dto.setCoverUrl(largeImage != null ? largeImage : imageUrl);
        }
        
        // Capítulos y volúmenes
        if (manga.has("chapters") && !manga.get("chapters").isNull()) {
            dto.setTotalChapters(manga.get("chapters").asInt());
        }
        if (manga.has("volumes") && !manga.get("volumes").isNull()) {
            dto.setTotalVolumes(manga.get("volumes").asInt());
        }
        
        // Estado de publicación
        dto.setPublicationStatus(mapStatus(manga.path("status").asText()));
        
        return dto;
    }

    private String extractAuthors(JsonNode authors) {
        if (!authors.isArray() || authors.size() == 0) {
            return "Autor desconocido";
        }
        
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < authors.size(); i++) {
            JsonNode author = authors.get(i);
            String name = author.has("name") ? author.get("name").asText() : "";
            if (!name.isEmpty()) {
                if (sb.length() > 0) sb.append(", ");
                sb.append(name);
            }
        }
        
        return sb.length() > 0 ? sb.toString() : "Autor desconocido";
    }

    private String extractGenres(JsonNode genres) {
        if (!genres.isArray() || genres.size() == 0) {
            return "";
        }
        
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < genres.size(); i++) {
            JsonNode genre = genres.get(i);
            String name = genre.has("name") ? genre.get("name").asText() : "";
            if (!name.isEmpty()) {
                if (sb.length() > 0) sb.append(", ");
                sb.append(name);
            }
        }
        
        return sb.toString();
    }

    private String mapStatus(String jikanStatus) {
        if (jikanStatus == null) return null;
        
        switch (jikanStatus.toLowerCase()) {
            case "publishing":
                return "ONGOING";
            case "finished":
            case "completed":
                return "COMPLETED";
            case "on_hiatus":
                return "PAUSED";
            case "discontinued":
                return "CANCELLED";
            default:
                return jikanStatus.toUpperCase();
        }
    }
}
