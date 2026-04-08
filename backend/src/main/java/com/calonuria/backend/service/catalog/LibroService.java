package com.calonuria.backend.service.catalog;

import com.calonuria.backend.config.GoogleBooksConfig;
import com.calonuria.backend.dto.catalog.LibroRespuestaDTO;
import com.calonuria.backend.model.catalog.Libro;
import com.calonuria.backend.repository.catalog.LibroRepository;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;
import org.springframework.util.StringUtils;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class LibroService {

    private static final Logger log = LoggerFactory.getLogger(LibroService.class);

    @Autowired
    private LibroRepository libroRepository;

    @Autowired
    private RestTemplate restTemplate;

    @Autowired
    private GoogleBooksConfig googleBooksConfig;

    // Guarda solo si no existe ya por googleBooksId
    public LibroRespuestaDTO guardarSiNoExiste(Libro libro) {
        if (libro.getGoogleBooksId() != null) {
            Optional<Libro> existente = libroRepository.findByGoogleBooksId(libro.getGoogleBooksId());
            if (existente.isPresent()) {
                return mapearADTO(existente.get());
            }
        }
        return mapearADTO(libroRepository.save(libro));
    }

    public Optional<LibroRespuestaDTO> obtenerLibroPorId(Long id) {
        return libroRepository.findById(id).map(this::mapearADTO);
    }

    public List<LibroRespuestaDTO> buscarEnGoogleBooks(String titulo) {
        UriComponentsBuilder urlBuilder = UriComponentsBuilder
                .fromHttpUrl("https://www.googleapis.com/books/v1/volumes")
                .queryParam("q", "intitle:" + titulo)
                .queryParam("maxResults", 10);

        if (StringUtils.hasText(googleBooksConfig.getApiKey())) {
            urlBuilder.queryParam("key", googleBooksConfig.getApiKey());
        }

        String url = urlBuilder.build().encode().toUriString();

        List<LibroRespuestaDTO> resultados = new ArrayList<>();

        try {
            String json = restTemplate.getForObject(url, String.class);
            if (!StringUtils.hasText(json)) {
                log.warn("Google Books devolvió una respuesta vacía para el título '{}'", titulo);
                return buscarEnBD(titulo);
            }

            JsonNode root = new ObjectMapper().readTree(json);
            JsonNode error = root.path("error");
            if (!error.isMissingNode()) {
                log.warn("Google Books devolvió error {} para '{}': {}",
                        error.path("code").asInt(),
                        titulo,
                        error.path("message").asText("sin mensaje"));
                return buscarEnBD(titulo);
            }

            JsonNode items = root.path("items");

            if (items.isArray()) {
                for (JsonNode item : items) {
                    JsonNode info = item.path("volumeInfo");
                    LibroRespuestaDTO dto = new LibroRespuestaDTO();

                    dto.setGoogleBooksId(item.path("id").asText(null));
                    dto.setTitulo(info.path("title").asText("Título desconocido"));

                    if (info.path("authors").isArray() && info.path("authors").size() > 0) {
                        dto.setAutor(info.path("authors").get(0).asText());
                    } else {
                        dto.setAutor("Autor desconocido");
                    }

                    dto.setEditorial(info.path("publisher").asText(null));
                    dto.setDescripcion(info.path("description").asText(null));

                    JsonNode isbn = info.path("industryIdentifiers");
                    if (isbn.isArray() && isbn.size() > 0) {
                        dto.setIsbn(isbn.get(0).path("identifier").asText(null));
                    }

                    JsonNode categorias = info.path("categories");
                    if (categorias.isArray() && categorias.size() > 0) {
                        dto.setGenero(categorias.get(0).asText(null));
                    }

                    JsonNode portada = info.path("imageLinks");
                    if (!portada.isMissingNode()) {
                        dto.setPortadaUrl(portada.path("thumbnail").asText(null));
                    }

                    String fecha = info.path("publishedDate").asText("");
                    if (fecha.length() >= 4) {
                        try {
                            dto.setAnioPublicacion(Integer.parseInt(fecha.substring(0, 4)));
                        } catch (NumberFormatException e) {
                            dto.setAnioPublicacion(null);
                        }
                    }

                    resultados.add(dto);
                }
            }
        } catch (Exception e) {
            log.error("Error al conectar con Google Books para '{}': {}", titulo, e.getMessage());
            return buscarEnBD(titulo);
        }

        if (resultados.isEmpty()) {
            return buscarEnBD(titulo);
        }

        return resultados;
    }

    public List<LibroRespuestaDTO> buscarEnBD(String titulo) {
        return libroRepository.findByTituloContainingIgnoreCase(titulo)
                .stream().map(this::mapearADTO).collect(Collectors.toList());
    }

    public List<LibroRespuestaDTO> obtenerTodosLosLibros() {
        return libroRepository.findAll().stream()
                .map(this::mapearADTO)
                .collect(Collectors.toList());
    }


    public LibroRespuestaDTO mapearADTO(Libro libro) {
        LibroRespuestaDTO dto = new LibroRespuestaDTO();
        dto.setIdLibro(libro.getIdLibro());
        dto.setGoogleBooksId(libro.getGoogleBooksId());
        dto.setTitulo(libro.getTitulo());
        dto.setAutor(libro.getAutor());
        dto.setIsbn(libro.getIsbn());
        dto.setEditorial(libro.getEditorial());
        dto.setDescripcion(libro.getDescripcion());
        dto.setPortadaUrl(libro.getPortadaUrl());
        dto.setGenero(libro.getGenero());
        dto.setTipoLibro(libro.getTipoLibro());
        dto.setAnioPublicacion(libro.getAnioPublicacion());
        return dto;
    }
}