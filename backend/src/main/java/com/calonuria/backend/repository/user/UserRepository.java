package com.calonuria.backend.repository.user;

import com.calonuria.backend.model.user.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

/**
 * Repositorio para la gestión de usuarios.
 */
@Repository
public interface UserRepository extends JpaRepository<User, Long> {

    /**
     * Busca un usuario por su email.
     * @param email email del usuario
     * @return Optional con el usuario
     */
    Optional<User> findByEmail(String email);

    /**
     * Verifica si existe un usuario con el email dado.
     * @param email email a verificar
     * @return true si existe
     */
    boolean existsByEmail(String email);

    /**
     * Busca usuarios por nombre (contiene, ignorando mayúsculas).
     * @param name nombre a buscar
     * @return lista de usuarios
     */
    List<User> findByNameContainingIgnoreCase(String name);

    /**
     * Busca usuarios por rol.
     * @param role rol a buscar
     * @return lista de usuarios
     */
    List<User> findByRole(String role);
}