package com.calonuria.backend.repository.catalog;

import com.calonuria.backend.model.catalog.Manga;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

/**
 * Repositorio para la gestión de mangas en el catálogo.
 */
@Repository
public interface MangaRepository extends JpaRepository<Manga, Long> {

    /**
     * Busca un manga por su ID de MangaDex.
     * @param mangadexId ID de MangaDex
     * @return Optional con el manga
     */
    Optional<Manga> findByMangadexId(String mangadexId);

    /**
     * Busca mangas por título.
     * @param title título a buscar
     * @return lista de mangas
     */
    List<Manga> findByTitleContainingIgnoreCase(String title);

    /**
     * Busca mangas por autor.
     * @param author autor a buscar
     * @return lista de mangas
     */
    List<Manga> findByAuthorContainingIgnoreCase(String author);

    /**
     * Busca mangas por género.
     * @param genre género a buscar
     * @return lista de mangas
     */
    List<Manga> findByGenreIgnoreCase(String genre);

    /**
     * Busca mangas por demografía.
     * @param demographic demografía a buscar
     * @return lista de mangas
     */
    List<Manga> findByDemographicIgnoreCase(String demographic);

    /**
     * Busca mangas por estado de publicación.
     * @param publicationStatus estado de publicación
     * @return lista de mangas
     */
    List<Manga> findByPublicationStatusIgnoreCase(String publicationStatus);

    /**
     * Busca mangas por título y demografía.
     * @param title título a buscar
     * @param demographic demografía a buscar
     * @return lista de mangas
     */
    List<Manga> findByTitleContainingIgnoreCaseAndDemographicIgnoreCase(
            String title, String demographic);
}