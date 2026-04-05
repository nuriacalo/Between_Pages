package com.calonuria.backend.repository.list;

import com.calonuria.backend.model.list.ListaFanfic;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface ListaFanficRepository extends JpaRepository<ListaFanfic, Long> {
    List<ListaFanfic> findByLista_IdListaOrderByOrden(Long idLista);
}