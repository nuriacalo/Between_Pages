package com.calonuria.backend.service.catalog;

import com.calonuria.backend.config.GoogleBooksConfig;
import com.calonuria.backend.dto.catalog.BookResponseDTO;
import com.calonuria.backend.exception.ResourceNotFoundException;
import com.calonuria.backend.model.catalog.Book;
import com.calonuria.backend.model.catalog.Genre;
import com.calonuria.backend.repository.catalog.BookRepository;
import com.calonuria.backend.repository.catalog.GenreRepository;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;
import org.springframework.util.StringUtils;

import java.util.*;
import java.util.stream.Collectors;

@Service
public class BookService extends BaseCatalogService<Book, BookResponseDTO, Long> {

    private static final Logger log = LoggerFactory.getLogger(BookService.class);

    private final BookRepository bookRepository;
    private final GenreRepository genreRepository;
    private final RestTemplate restTemplate;
    private final GoogleBooksConfig googleBooksConfig;

    public BookService(BookRepository bookRepository,
                       GenreRepository genreRepository,
                       RestTemplate restTemplate,
                       GoogleBooksConfig googleBooksConfig) {
        super(bookRepository);
        this.bookRepository = bookRepository;
        this.genreRepository = genreRepository;
        this.restTemplate = restTemplate;
        this.googleBooksConfig = googleBooksConfig;
    }

    @Transactional
    public Book findOrCreateBook(Long bookId, String googleBooksId) {
        if (bookId != null) {
            return bookRepository.findById(bookId)
                    .orElseThrow(() -> new ResourceNotFoundException("Libro no encontrado con id: " + bookId));
        }

        if (StringUtils.hasText(googleBooksId)) {
            return bookRepository.findByGoogleBooksId(googleBooksId)
                    .orElseGet(() -> {
                        log.info("Libro con googleBooksId '{}' no encontrado en la BD. Buscando en Google Books.", googleBooksId);
                        Book newBook = fetchFromGoogleBooksById(googleBooksId);
                        return bookRepository.save(newBook);
                    });
        }

        throw new IllegalArgumentException("Se debe proporcionar un bookId o un googleBooksId para encontrar o crear un libro.");
    }

    private Book fetchFromGoogleBooksById(String googleBooksId) {
        UriComponentsBuilder urlBuilder = UriComponentsBuilder
                .fromHttpUrl("https://www.googleapis.com/books/v1/volumes/")
                .path(googleBooksId);

        if (StringUtils.hasText(googleBooksConfig.getApiKey())) {
            urlBuilder.queryParam("key", googleBooksConfig.getApiKey());
        }

        String url = urlBuilder.build().encode().toUriString();

        try {
            String json = restTemplate.getForObject(url, String.class);
            if (!StringUtils.hasText(json)) {
                throw new ResourceNotFoundException("Google Books devolvió una respuesta vacía para el ID: " + googleBooksId);
            }

            JsonNode root = new ObjectMapper().readTree(json);
            JsonNode error = root.path("error");
            if (!error.isMissingNode()) {
                throw new ResourceNotFoundException(String.format("Google Books devolvió error %d para '%s': %s",
                        error.path("code").asInt(),
                        googleBooksId,
                        error.path("message").asText("sin mensaje")));
            }

            return parseBookFromJsonNode(root);

        } catch (Exception e) {
            log.error("Error al conectar con Google Books para el ID '{}': {}", googleBooksId, e.getMessage());
            throw new ResourceNotFoundException("No se pudo obtener la información del libro desde Google Books para el ID: " + googleBooksId);
        }
    }

    private Book parseBookFromJsonNode(JsonNode item) {
        JsonNode info = item.path("volumeInfo");
        Book book = new Book();

        book.setGoogleBooksId(item.path("id").asText(null));
        book.setTitle(info.path("title").asText("Título desconocido"));

        if (info.path("authors").isArray() && info.path("authors").size() > 0) {
            book.setAuthor(info.path("authors").get(0).asText());
        } else {
            book.setAuthor("Autor desconocido");
        }

        book.setPublisher(info.path("publisher").asText(null));
        book.setDescription(info.path("description").asText(null));
        book.setPageCount(info.path("pageCount").asInt(0));

        JsonNode isbnNodes = info.path("industryIdentifiers");
        if (isbnNodes.isArray()) {
            for (JsonNode isbnNode : isbnNodes) {
                String type = isbnNode.path("type").asText();
                if ("ISBN_13".equals(type)) {
                    book.setIsbn(isbnNode.path("identifier").asText(null));
                    break;
                }
                if ("ISBN_10".equals(type)) {
                    book.setIsbn(isbnNode.path("identifier").asText(null));
                }
            }
        }

        JsonNode categories = info.path("categories");
        if (categories.isArray() && categories.size() > 0) {
            Set<Genre> genres = new HashSet<>();
            for (JsonNode categoryNode : categories) {
                String genreName = categoryNode.asText();
                if (StringUtils.hasText(genreName)) {
                    Genre genre = genreRepository.findByNameIgnoreCase(genreName)
                            .orElseGet(() -> {
                                Genre newGenre = new Genre();
                                newGenre.setName(genreName);
                                return genreRepository.save(newGenre);
                            });
                    genres.add(genre);
                }
            }
            book.setGenres(genres);
        }

        JsonNode cover = info.path("imageLinks");
        if (!cover.isMissingNode()) {
            String thumbnailUrl = cover.path("thumbnail").asText(null);
            if (thumbnailUrl != null && thumbnailUrl.startsWith("http:")) {
                thumbnailUrl = thumbnailUrl.replace("http:", "https:");
            }
            book.setCoverUrl(thumbnailUrl);
        }

        String date = info.path("publishedDate").asText("");
        if (date.length() >= 4) {
            try {
                book.setPublicationYear(Integer.parseInt(date.substring(0, 4)));
            } catch (NumberFormatException e) {
                book.setPublicationYear(null);
            }
        }
        
        book.setBookType("STANDALONE");

        return book;
    }

    public List<BookResponseDTO> searchInGoogleBooks(String title) {
        UriComponentsBuilder urlBuilder = UriComponentsBuilder
                .fromHttpUrl("https://www.googleapis.com/books/v1/volumes")
                .queryParam("q", "intitle:" + title)
                .queryParam("maxResults", 10);

        if (StringUtils.hasText(googleBooksConfig.getApiKey())) {
            urlBuilder.queryParam("key", googleBooksConfig.getApiKey());
        }

        String url = urlBuilder.build().encode().toUriString();

        List<BookResponseDTO> results = new ArrayList<>();

        try {
            String json = restTemplate.getForObject(url, String.class);
            if (!StringUtils.hasText(json)) {
                log.warn("Google Books devolvió una respuesta vacía para el título '{}'", title);
                return searchByTitle(title);
            }

            JsonNode root = new ObjectMapper().readTree(json);
            JsonNode error = root.path("error");
            if (!error.isMissingNode()) {
                log.warn("Google Books devolvió error {} para '{}': {}",
                        error.path("code").asInt(),
                        title,
                        error.path("message").asText("sin mensaje"));
                return searchByTitle(title);
            }

            JsonNode items = root.path("items");

            if (items.isArray()) {
                for (JsonNode item : items) {
                    Book book = parseBookFromJsonNode(item);
                    results.add(mapToDTO(book));
                }
            }
        } catch (Exception e) {
            log.error("Error al conectar con Google Books para '{}': {}", title, e.getMessage());
            return searchByTitle(title);
        }

        if (results.isEmpty()) {
            log.info("No se encontraron resultados en Google Books para '{}', buscando en BD local", title);
            return searchByTitle(title);
        }

        return results;
    }

    @Override
    public List<BookResponseDTO> searchByTitle(String title) {
        return bookRepository.findByTitleContainingIgnoreCase(title)
                .stream().map(this::mapToDTO).collect(Collectors.toList());
    }

    @Override
    public BookResponseDTO mapToDTO(Book book) {
        BookResponseDTO dto = new BookResponseDTO();
        dto.setId(book.getId());
        dto.setGoogleBooksId(book.getGoogleBooksId());
        dto.setTitle(book.getTitle());
        dto.setAuthor(book.getAuthor());
        dto.setIsbn(book.getIsbn());
        dto.setPublisher(book.getPublisher());
        dto.setDescription(book.getDescription());
        dto.setCoverUrl(book.getCoverUrl());
        if (book.getGenres() != null) {
            dto.setGenres(book.getGenres().stream().map(Genre::getName).collect(Collectors.toList()));
        }
        dto.setBookType(book.getBookType());
        dto.setPublicationYear(book.getPublicationYear());
        dto.setPageCount(book.getPageCount());
        return dto;
    }

    public Optional<BookResponseDTO> updateBook(Long id, BookResponseDTO dto) {
        return bookRepository.findById(id)
                .map(book -> {
                    book.setTitle(dto.getTitle());
                    book.setAuthor(dto.getAuthor());
                    book.setIsbn(dto.getIsbn());
                    book.setPublisher(dto.getPublisher());
                    book.setDescription(dto.getDescription());
                    book.setCoverUrl(dto.getCoverUrl());
                    
                    if (dto.getGenres() != null) {
                        Set<Genre> genres = new HashSet<>();
                        for (String genreName : dto.getGenres()) {
                            Genre genre = genreRepository.findByNameIgnoreCase(genreName)
                                    .orElseGet(() -> {
                                        Genre newGenre = new Genre();
                                        newGenre.setName(genreName);
                                        return genreRepository.save(newGenre);
                                    });
                            genres.add(genre);
                        }
                        book.setGenres(genres);
                    }

                    book.setBookType(dto.getBookType());
                    book.setPublicationYear(dto.getPublicationYear());
                    book.setPageCount(dto.getPageCount());
                    return mapToDTO(bookRepository.save(book));
                });
    }
}
