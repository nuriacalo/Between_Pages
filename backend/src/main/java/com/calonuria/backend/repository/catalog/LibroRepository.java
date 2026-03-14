package com.calonuria.backend.repository.catalog;

import com.calonuria.backend.model.catalog.Libro;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface LibroRepository extends JpaRepository<Libro, Long> {

    // Búsqueda por ID externo
    Optional<Libro> findByGoogleBooksId(String googleBooksId);

    // Búsqueda por título
    List<Libro> findByTituloContainingIgnoreCase(String titulo);

    // Búsqueda por autor
    List<Libro> findByAutorContainingIgnoreCase(String autor);

    // Búsqueda por género
    List<Libro> findByGeneroIgnoreCase(String genero);

    // Búsqueda por tipo (Saga, Serie, Autoconclusivo...)
    List<Libro> findByTipoLibroIgnoreCase(String tipoLibro);

    // Búsqueda combinada título + género
    List<Libro> findByTituloContainingIgnoreCaseAndGeneroIgnoreCase(String titulo, String genero);
}