package com.calonuria.backend.repository.list;

import com.calonuria.backend.model.list.Lista;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface ListaRepository extends JpaRepository<Lista, Long> {

    // Todas las listas de un usuario
    @Query("SELECT l FROM Lista l WHERE l.usuario.idUsuario = :idUsuario")
    List<Lista> findByUsuario_IdUsuario(@Param("idUsuario") Long idUsuario);

    // Buscar lista por nombre (de un usuario concreto)
    Optional<Lista> findByUsuarioIdUsuarioAndNombreIgnoreCase(Long idUsuario, String nombre);

    // Listas de un usuario que contengan cierta palabra en el nombre
    List<Lista> findByUsuarioIdUsuarioAndNombreContainingIgnoreCase(Long idUsuario, String nombre);

    // Listas que contienen un libro concreto
    @Query("SELECT ll.lista FROM ListaLibro ll WHERE ll.libro.idLibro = :idLibro AND ll.lista.usuario.idUsuario = :idUsuario")
    List<Lista> findListasConLibro(@Param("idUsuario") Long idUsuario, @Param("idLibro") Long idLibro);

    // Listas que contienen un fanfic concreto
    @Query("SELECT lf.lista FROM ListaFanfic lf WHERE lf.fanfic.idFanfic = :idFanfic AND lf.lista.usuario.idUsuario = :idUsuario")
    List<Lista> findListasConFanfic(@Param("idUsuario") Long idUsuario, @Param("idFanfic") Long idFanfic);

    // Listas que contienen un manga concreto
    @Query("SELECT lm.lista FROM ListaManga lm WHERE lm.manga.idManga = :idManga AND lm.lista.usuario.idUsuario = :idUsuario")
    List<Lista> findListasConManga(@Param("idUsuario") Long idUsuario, @Param("idManga") Long idManga);
}