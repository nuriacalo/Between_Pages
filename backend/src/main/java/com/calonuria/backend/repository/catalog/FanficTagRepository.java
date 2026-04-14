package com.calonuria.backend.repository.catalog;

import com.calonuria.backend.model.catalog.FanficTag;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

/**
 * Repositorio para la gestión de etiquetas de fanfiction.
 */
@Repository
public interface FanficTagRepository extends JpaRepository<FanficTag, Long> {

    /**
     * Busca todos los tags de un fanfiction.
     * @param fanficId ID del fanfiction
     * @return lista de tags
     */
    List<FanficTag> findByFanfic_Id(Long fanficId);

    /**
     * Busca tags por texto exacto.
     * @param tag texto del tag
     * @return lista de tags
     */
    List<FanficTag> findByTagIgnoreCase(String tag);

    /**
     * Busca tags que contengan una palabra.
     * @param tag texto a buscar
     * @return lista de tags
     */
    List<FanficTag> findByTagContainingIgnoreCase(String tag);

    /**
     * Elimina todos los tags de un fanfiction.
     * @param fanficId ID del fanfiction
     */
    void deleteByFanfic_Id(Long fanficId);
}