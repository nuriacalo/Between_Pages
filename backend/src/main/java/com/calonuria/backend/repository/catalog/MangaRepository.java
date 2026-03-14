package com.calonuria.backend.repository.catalog;

import com.calonuria.backend.model.catalog.Manga;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface MangaRepository extends JpaRepository<Manga, Long> {

    // Búsqueda por ID externo
    Optional<Manga> findByMangadexId(String mangadexId);

    // Búsqueda por título
    List<Manga> findByTituloContainingIgnoreCase(String titulo);

    // Búsqueda por mangaka
    List<Manga> findByMangakaContainingIgnoreCase(String mangaka);

    // Búsqueda por género
    List<Manga> findByGeneroIgnoreCase(String genero);

    // Búsqueda por demografía (Shonen, Seinen, Josei...)
    List<Manga> findByDemografiaIgnoreCase(String demografia);

    // Búsqueda por estado de publicación
    List<Manga> findByEstadoPublicacionIgnoreCase(String estadoPublicacion);

    // Búsqueda combinada título + demografía
    List<Manga> findByTituloContainingIgnoreCaseAndDemografiaIgnoreCase(
            String titulo, String demografia);
}