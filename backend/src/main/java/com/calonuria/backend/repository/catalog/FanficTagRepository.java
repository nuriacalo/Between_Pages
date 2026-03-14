package com.calonuria.backend.repository.catalog;

import com.calonuria.backend.model.catalog.FanficTag;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface FanficTagRepository extends JpaRepository<FanficTag, Long> {

    // Todos los tags de un fanfic concreto
    List<FanficTag> findByFanfic_IdFanfic(Long idFanfic);

    // Buscar fanfics que tengan un tag concreto
    List<FanficTag> findByTagIgnoreCase(String tag);

    // Buscar tags que contengan una palabra (ej: "fluff" encuentra "fluff extremo")
    List<FanficTag> findByTagContainingIgnoreCase(String tag);

    // Eliminar todos los tags de un fanfic (útil al actualizar)
    void deleteByFanfic_IdFanfic(Long idFanfic);
}