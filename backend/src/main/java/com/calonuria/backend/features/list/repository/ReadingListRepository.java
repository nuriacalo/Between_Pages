package com.calonuria.backend.features.list.repository;

import com.calonuria.backend.features.list.model.ReadingList;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ReadingListRepository extends JpaRepository<ReadingList, Long> {
    
    /**
     * Busca todas las listas de un usuario.
     * @param userId ID del usuario
     * @return Lista de colecciones del usuario
     */
    List<ReadingList> findByUser_Id(Long userId);
}