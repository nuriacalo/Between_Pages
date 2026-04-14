package com.calonuria.backend.service.catalog;

import com.calonuria.backend.dto.catalog.MangaResponseDTO;
import com.calonuria.backend.model.catalog.Manga;
import com.calonuria.backend.repository.catalog.MangaRepository;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

/**
 * Servicio para la gestión de mangas en el catálogo.
 * Integra con MangaDex API para búsquedas externas.
 */
@Service
public class MangaService {

    private static final Logger log = LoggerFactory.getLogger(MangaService.class);

    @Autowired
    private MangaRepository mangaRepository;

    @Autowired
    private RestTemplate restTemplate;

    /**
     * Guarda un manga solo si no existe ya por mangadexId.
     * @param manga manga a guardar
     * @return DTO con la información del manga guardado
     */
    public MangaResponseDTO saveIfNotExists(Manga manga) {
        if (manga.getMangadexId() != null) {
            Optional<Manga> existing = mangaRepository.findByMangadexId(manga.getMangadexId());
            if (existing.isPresent()) {
                return mapToDTO(existing.get());
            }
        }
        return mapToDTO(mangaRepository.save(manga));
    }

    /**
     * Obtiene un manga por su ID.
     * @param id ID del manga
     * @return Optional con el DTO del manga
     */
    public Optional<MangaResponseDTO> getMangaById(Long id) {
        return mangaRepository.findById(id).map(this::mapToDTO);
    }

    /**
     * Busca mangas en MangaDex API.
     * @param title título a buscar
     * @return lista de mangas encontrados
     */
    public List<MangaResponseDTO> searchInMangaDex(String title) {
        String url = "https://api.mangadex.org/manga?title=" + title + "&limit=10&includes[]=author&includes[]=cover_art";
        List<MangaResponseDTO> results = new ArrayList<>();

        try {
            String json = restTemplate.getForObject(url, String.class);
            JsonNode data = new ObjectMapper().readTree(json).path("data");

            if (data.isArray()) {
                for (JsonNode item : data) {
                    MangaResponseDTO dto = new MangaResponseDTO();
                    String mangadexId = item.path("id").asText(null);
                    dto.setMangadexId(mangadexId);

                    JsonNode attrs = item.path("attributes");

                    // Título en español o inglés
                    JsonNode titles = attrs.path("title");
                    if (!titles.path("es").isMissingNode()) {
                        dto.setTitle(titles.path("es").asText());
                    } else {
                        dto.setTitle(titles.path("en").asText("Título desconocido"));
                    }

                    // Descripción
                    JsonNode descriptions = attrs.path("description");
                    if (!descriptions.path("es").isMissingNode()) {
                        dto.setDescription(descriptions.path("es").asText(null));
                    } else {
                        dto.setDescription(descriptions.path("en").asText(null));
                    }

                    // Estado
                    dto.setPublicationStatus(attrs.path("status").asText(null));

                    // Demografía
                    JsonNode demographic = attrs.path("publicationDemographic");
                    if (!demographic.isNull()) {
                        dto.setDemographic(demographic.asText(null));
                    }

                    // Géneros desde tags
                    JsonNode tags = attrs.path("tags");
                    if (tags.isArray() && tags.size() > 0) {
                        dto.setGenre(tags.get(0).path("attributes").path("name").path("en").asText(null));
                    }

                    // Autor y portada desde relationships
                    JsonNode rels = item.path("relationships");
                    if (rels.isArray()) {
                        for (JsonNode rel : rels) {
                            String type = rel.path("type").asText();
                            if ("author".equals(type)) {
                                dto.setAuthor(rel.path("attributes").path("name").asText("Desconocido"));
                            }
                            if ("cover_art".equals(type)) {
                                String fileName = rel.path("attributes").path("fileName").asText(null);
                                if (fileName != null) {
                                    dto.setCoverUrl("https://uploads.mangadex.org/covers/" + mangadexId + "/" + fileName);
                                }
                            }
                        }
                    }

                    if (dto.getAuthor() == null) dto.setAuthor("Desconocido");
                    results.add(dto);
                }
            }
        } catch (Exception e) {
            log.error("Error al conectar con MangaDex: {}", e.getMessage());
        }

        return results;
    }

    /**
     * Busca mangas en la base de datos local.
     * @param title título a buscar
     * @return lista de mangas encontrados
     */
    public List<MangaResponseDTO> searchInDatabase(String title) {
        return mangaRepository.findByTitleContainingIgnoreCase(title)
                .stream().map(this::mapToDTO).collect(Collectors.toList());
    }

    /**
     * Mapea un manga a su DTO de respuesta.
     * @param manga manga
     * @return DTO de respuesta
     */
    public MangaResponseDTO mapToDTO(Manga manga) {
        MangaResponseDTO dto = new MangaResponseDTO();
        dto.setId(manga.getId());
        dto.setMangadexId(manga.getMangadexId());
        dto.setSource(manga.getSource());
        dto.setTitle(manga.getTitle());
        dto.setAuthor(manga.getAuthor());
        dto.setDemographic(manga.getDemographic());
        dto.setGenre(manga.getGenre());
        dto.setDescription(manga.getDescription());
        dto.setCoverUrl(manga.getCoverUrl());
        dto.setTotalChapters(manga.getTotalChapters());
        dto.setTotalVolumes(manga.getTotalVolumes());
        dto.setPublicationStatus(manga.getPublicationStatus());
        return dto;
    }
}