package com.calonuria.backend.repository.user;

import com.calonuria.backend.model.user.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface UsuarioRepository extends JpaRepository<Usuario, Long> {

    // Para login y autenticación
    Optional<Usuario> findByEmail(String email);

    // Para validar si el email ya está registrado
    boolean existsByEmail(String email);

    // Para búsqueda de usuarios por nombre (útil si hay admin)
    List<Usuario> findByNombreContainingIgnoreCase(String nombre);

    // Para filtrar por rol
    List<Usuario> findByRol(String rol);
}