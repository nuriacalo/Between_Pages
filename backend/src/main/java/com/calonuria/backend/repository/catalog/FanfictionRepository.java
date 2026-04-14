package com.calonuria.backend.repository.catalog;

import com.calonuria.backend.model.catalog.Fanfiction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

/**
 * Repositorio para la gestión de fanfictions en el catálogo.
 */
@Repository
public interface FanfictionRepository extends JpaRepository<Fanfiction, Long> {

    /**
     * Busca un fanfiction por su ID de AO3.
     * @param ao3Id ID de AO3
     * @return Optional con el fanfiction
     */
    Optional<Fanfiction> findByAo3Id(String ao3Id);

    /**
     * Busca fanfictions por título.
     * @param title título a buscar
     * @return lista de fanfictions
     */
    List<Fanfiction> findByTitleContainingIgnoreCase(String title);

    /**
     * Busca fanfictions por autor.
     * @param author autor a buscar
     * @return lista de fanfictions
     */
    List<Fanfiction> findByAuthorContainingIgnoreCase(String author);

    /**
     * Busca fanfictions por género.
     * @param genre género a buscar
     * @return lista de fanfictions
     */
    List<Fanfiction> findByGenreIgnoreCase(String genre);

    /**
     * Busca fanfictions por estado de publicación.
     * @param publicationStatus estado de publicación
     * @return lista de fanfictions
     */
    List<Fanfiction> findByPublicationStatusIgnoreCase(String publicationStatus);

    /**
     * Busca fanfictions por material original.
     * @param sourceMaterial material original
     * @return lista de fanfictions
     */
    List<Fanfiction> findBySourceMaterialContainingIgnoreCase(String sourceMaterial);

    /**
     * Busca fanfictions por ship principal.
     * @param mainShip ship principal
     * @return lista de fanfictions
     */
    List<Fanfiction> findByMainShipContainingIgnoreCase(String mainShip);

    /**
     * Busca fanfictions por temática.
     * @param theme temática a buscar
     * @return lista de fanfictions
     */
    List<Fanfiction> findByThemeContainingIgnoreCase(String theme);

    /**
     * Busca fanfictions por título y estado.
     * @param title título a buscar
     * @param publicationStatus estado de publicación
     * @return lista de fanfictions
     */
    List<Fanfiction> findByTitleContainingIgnoreCaseAndPublicationStatusIgnoreCase(
            String title, String publicationStatus);
}