package com.calonuria.backend.repository.catalog;

import com.calonuria.backend.model.catalog.Fanfiction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface FanfictionRepository extends JpaRepository<Fanfiction, Long> {

    // Búsqueda por ID externo
    Optional<Fanfiction> findByAo3Id(String ao3Id);

    // Búsqueda por título
    List<Fanfiction> findByTituloContainingIgnoreCase(String titulo);

    // Búsqueda por autor
    List<Fanfiction> findByAutorContainingIgnoreCase(String autor);

    // Búsqueda por género
    List<Fanfiction> findByGeneroIgnoreCase(String genero);

    // Búsqueda por estado de publicación
    List<Fanfiction> findByEstadoPublicacionIgnoreCase(String estadoPublicacion);

    // Búsqueda por fandom (historia base)
    List<Fanfiction> findByHistoriaBaseContainingIgnoreCase(String historiaBase);

    // Búsqueda por ship principal
    List<Fanfiction> findByShipPrincipalContainingIgnoreCase(String shipPrincipal);

    // Búsqueda por temática
    List<Fanfiction> findByTematicaContainingIgnoreCase(String tematica);

    // Búsqueda combinada título + estado
    List<Fanfiction> findByTituloContainingIgnoreCaseAndEstadoPublicacionIgnoreCase(
            String titulo, String estadoPublicacion);
}