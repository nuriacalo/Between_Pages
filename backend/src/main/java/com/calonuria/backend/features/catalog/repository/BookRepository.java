package com.calonuria.backend.features.catalog.repository;

import com.calonuria.backend.features.catalog.model.Book;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

/**
 * Repositorio para la gestión de libros en el catálogo.
 */
@Repository
public interface BookRepository extends JpaRepository<Book, Long> {

    /**
     * Busca un libro por su ID de Google Books.
     * @param googleBooksId ID de Google Books
     * @return Optional con el libro encontrado
     */
    Optional<Book> findByGoogleBooksId(String googleBooksId);

    /**
     * Busca libros por título (contiene, ignorando mayúsculas).
     * @param title título a buscar
     * @return lista de libros coincidentes
     */
    List<Book> findByTitleContainingIgnoreCase(String title);

    /**
     * Busca libros por autor (contiene, ignorando mayúsculas).
     * @param author autor a buscar
     * @return lista de libros coincidentes
     */
    List<Book> findByAuthorContainingIgnoreCase(String author);

    /**
     * Busca libros por tipo (Saga, Serie, Standalone...).
     * @param bookType tipo de libro
     * @return lista de libros coincidentes
     */
    List<Book> findByBookTypeIgnoreCase(String bookType);
}
