package com.calonuria.backend.repository.list;

import com.calonuria.backend.model.list.ListaManga;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface ListaMangaRepository extends JpaRepository<ListaManga, Long> {
    List<ListaManga> findByLista_IdListaOrderByOrden(Long idLista);
}