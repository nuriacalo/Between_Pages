package com.calonuria.backend.service.catalog;

import com.calonuria.backend.dto.catalog.MangaRespuestaDTO;
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

@Service
public class MangaService {

    private static final Logger log = LoggerFactory.getLogger(MangaService.class);

    @Autowired
    private MangaRepository mangaRepository;

    @Autowired
    private RestTemplate restTemplate;

    // Guarda solo si no existe ya por mangadexId
    public MangaRespuestaDTO guardarSiNoExiste(Manga manga) {
        if (manga.getMangadexId() != null) {
            Optional<Manga> existente = mangaRepository.findByMangadexId(manga.getMangadexId());
            if (existente.isPresent()) {
                return mapearADTO(existente.get());
            }
        }
        return mapearADTO(mangaRepository.save(manga));
    }

    public Optional<MangaRespuestaDTO> obtenerMangaPorId(Long id) {
        return mangaRepository.findById(id).map(this::mapearADTO);
    }

    public List<MangaRespuestaDTO> buscarEnMangaDex(String titulo) {
        String url = "https://api.mangadex.org/manga?title=" + titulo + "&limit=10&includes[]=author&includes[]=cover_art";
        List<MangaRespuestaDTO> resultados = new ArrayList<>();

        try {
            String json = restTemplate.getForObject(url, String.class);
            JsonNode data = new ObjectMapper().readTree(json).path("data");

            if (data.isArray()) {
                for (JsonNode item : data) {
                    MangaRespuestaDTO dto = new MangaRespuestaDTO();
                    String mangadexId = item.path("id").asText(null);
                    dto.setMangadexId(mangadexId);

                    JsonNode attrs = item.path("attributes");

                    // Título en español o inglés
                    JsonNode titulos = attrs.path("title");
                    if (!titulos.path("es").isMissingNode()) {
                        dto.setTitulo(titulos.path("es").asText());
                    } else {
                        dto.setTitulo(titulos.path("en").asText("Título desconocido"));
                    }

                    // Descripción
                    JsonNode descripciones = attrs.path("description");
                    if (!descripciones.path("es").isMissingNode()) {
                        dto.setDescripcion(descripciones.path("es").asText(null));
                    } else {
                        dto.setDescripcion(descripciones.path("en").asText(null));
                    }

                    // Estado
                    dto.setEstadoPublicacion(attrs.path("status").asText(null));

                    // Demografía
                    JsonNode demografia = attrs.path("publicationDemographic");
                    if (!demografia.isNull()) {
                        dto.setDemografia(demografia.asText(null));
                    }

                    // Géneros desde tags
                    JsonNode tags = attrs.path("tags");
                    if (tags.isArray() && tags.size() > 0) {
                        dto.setGenero(tags.get(0).path("attributes").path("name").path("en").asText(null));
                    }

                    // Mangaka y portada desde relationships
                    JsonNode rels = item.path("relationships");
                    if (rels.isArray()) {
                        for (JsonNode rel : rels) {
                            String type = rel.path("type").asText();
                            if ("author".equals(type)) {
                                dto.setMangaka(rel.path("attributes").path("name").asText("Desconocido"));
                            }
                            if ("cover_art".equals(type)) {
                                String fileName = rel.path("attributes").path("fileName").asText(null);
                                if (fileName != null) {
                                    dto.setPortadaUrl("https://uploads.mangadex.org/covers/" + mangadexId + "/" + fileName);
                                }
                            }
                        }
                    }

                    if (dto.getMangaka() == null) dto.setMangaka("Desconocido");
                    resultados.add(dto);
                }
            }
        } catch (Exception e) {
            log.error("Error al conectar con MangaDex: {}", e.getMessage());
        }

        return resultados;
    }

    public List<MangaRespuestaDTO> buscarEnBD(String titulo) {
        return mangaRepository.findByTituloContainingIgnoreCase(titulo)
                .stream().map(this::mapearADTO).collect(Collectors.toList());
    }

    public MangaRespuestaDTO mapearADTO(Manga manga) {
        MangaRespuestaDTO dto = new MangaRespuestaDTO();
        dto.setIdManga(manga.getIdManga());
        dto.setMangadexId(manga.getMangadexId());
        dto.setTitulo(manga.getTitulo());
        dto.setMangaka(manga.getMangaka());
        dto.setDemografia(manga.getDemografia());
        dto.setGenero(manga.getGenero());
        dto.setDescripcion(manga.getDescripcion());
        dto.setPortadaUrl(manga.getPortadaUrl());
        dto.setTotalCapitulos(manga.getTotalCapitulos());
        dto.setTotalVolumenes(manga.getTotalVolumenes());
        dto.setEstadoPublicacion(manga.getEstadoPublicacion());
        return dto;
    }
}