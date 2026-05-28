package com.calonuria.backend.features.user.controller;

import com.calonuria.backend.features.user.dto.UserRegistrationDTO;
import com.calonuria.backend.features.user.dto.UserResponseDTO;
import com.calonuria.backend.features.user.dto.UserUpdateDTO;
import com.calonuria.backend.features.user.service.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

/**
 * REST Controller for managing user profiles and registration.
 * Handles the creation of new accounts and fetching user metadata.
 * 
 * <p>Base path: {@code /api/user}</p>
 */
@RestController
@RequestMapping("/api/user")
@Tag(name = "Usuarios", description = "Endpoints para registro y consulta de usuarios")
public class UserController {

    private final UserService userService;

    /**
     * Constructs a new {@code UserController}.
     *
     * @param userService the service handling user persistence and logic
     */
    public UserController(UserService userService) {
        this.userService = userService;
    }

    /**
     * Registers a new user in the system.
     *
     * @param registrationDTO the payload containing name, email, and password
     * @return a {@link ResponseEntity} containing the registered {@link UserResponseDTO},
     *         or a 400 Bad Request with an error message if the email is already taken.
     */
    @Operation(summary = "Registrar un nuevo usuario")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Usuario registrado exitosamente"),
            @ApiResponse(responseCode = "400", description = "Email ya existente")
    })
    @PostMapping("/register")
    public ResponseEntity<?> registerUser(@Valid @RequestBody UserRegistrationDTO registrationDTO) {
        try {
            return ResponseEntity.ok(userService.registerUser(registrationDTO));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    /**
     * Updates an existing user's profile metadata.
     *
     * @param id the unique identifier of the user
     * @param updateDTO the payload containing updated fields
     * @return a {@link ResponseEntity} containing the updated {@link UserResponseDTO}
     */
    @Operation(summary = "Actualizar perfil de usuario")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Usuario actualizado exitosamente"),
            @ApiResponse(responseCode = "404", description = "Usuario no encontrado")
    })
    @PutMapping("/{id}")
    public ResponseEntity<?> updateUserProfile(@PathVariable Long id, @Valid @RequestBody UserUpdateDTO updateDTO) {
        try {
            return ResponseEntity.ok(userService.updateUserProfile(id, updateDTO));
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    /**
     * Retrieves the profile metadata for a specific user by their ID.
     *
     * @param id the unique identifier of the user
     * @return a {@link ResponseEntity} containing the {@link UserResponseDTO},
     *         or 404 Not Found if the user does not exist.
     */
    @Operation(summary = "Obtener usuario por ID")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Usuario encontrado"),
            @ApiResponse(responseCode = "404", description = "Usuario no encontrado")
    })
    @GetMapping("/{id}")
    public ResponseEntity<UserResponseDTO> getUser(@PathVariable Long id) {
        return userService.getUserById(id)
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }
}
