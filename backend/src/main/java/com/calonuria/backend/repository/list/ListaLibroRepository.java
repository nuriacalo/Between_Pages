package com.calonuria.backend.repository.list;

import com.calonuria.backend.model.list.ListaLibro;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface ListaLibroRepository extends JpaRepository<ListaLibro, Long> {
    List<ListaLibro> findByLista_IdListaOrderByOrden(Long idLista);
}