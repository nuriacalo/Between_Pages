package com.calonuria.backend.features.user.service;

import com.calonuria.backend.features.user.dto.UserRegistrationDTO;
import com.calonuria.backend.features.user.dto.UserResponseDTO;
import com.calonuria.backend.features.user.dto.UserUpdateDTO;
import com.calonuria.backend.features.user.model.User;
import com.calonuria.backend.features.user.repository.UserRepository;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.Optional;

/**
 * Servicio para la gestión de usuarios.
 */
@Service
public class UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public UserService(UserRepository userRepository, PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    /**
     * Registra un nuevo usuario.
     * @param registrationDTO datos de registro
     * @return DTO con la información del usuario registrado
     */
    public UserResponseDTO registerUser(UserRegistrationDTO registrationDTO) {
        if (userRepository.existsByEmail(registrationDTO.getEmail())) {
            throw new RuntimeException("El email ya está registrado.");
        }

        User newUser = new User();
        newUser.setName(registrationDTO.getName());
        newUser.setEmail(registrationDTO.getEmail());
        newUser.setPasswordHash(passwordEncoder.encode(registrationDTO.getPassword()));
        newUser.setRole("USER");

        User saved = userRepository.save(newUser);
        return mapToDTO(saved);
    }

    /**
     * Actualiza los datos del perfil de un usuario existente.
     * @param id ID del usuario
     * @param updateDTO datos a actualizar
     * @return DTO con la información del usuario actualizada
     */
    @Transactional
    public UserResponseDTO updateUserProfile(Long id, UserUpdateDTO updateDTO) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

        if (updateDTO.getName() != null && !updateDTO.getName().trim().isEmpty()) {
            user.setName(updateDTO.getName());
        }
        
        if (updateDTO.getEmail() != null && !updateDTO.getEmail().trim().isEmpty()) {
            user.setEmail(updateDTO.getEmail());
        }

        userRepository.save(user); // <-- Fuerza a Hibernate a ejecutar el UPDATE en la BD

        return mapToDTO(user);
    }

    /**
     * Obtiene un usuario por su ID.
     * @param id ID del usuario
     * @return Optional con el DTO del usuario
     */
    public Optional<UserResponseDTO> getUserById(Long id) {
        return userRepository.findById(id).map(this::mapToDTO);
    }

    /**
     * Mapea un usuario a su DTO de respuesta.
     * @param user usuario
     * @return DTO de respuesta
     */
    public UserResponseDTO mapToDTO(User user) {
        return new UserResponseDTO(
                user.getId(),
                user.getName(),
                user.getEmail(),
                user.getRole()
        );
    }
}