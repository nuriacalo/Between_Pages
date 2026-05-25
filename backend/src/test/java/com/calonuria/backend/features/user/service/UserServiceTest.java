package com.calonuria.backend.features.user.service;

import com.calonuria.backend.features.user.dto.UserRegistrationDTO;
import com.calonuria.backend.features.user.dto.UserResponseDTO;
import com.calonuria.backend.features.user.model.User;
import com.calonuria.backend.features.user.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.verify;

@ExtendWith(MockitoExtension.class)
class UserServiceTest {

    @Mock
    private UserRepository userRepository;

    @Mock
    private PasswordEncoder passwordEncoder;

    @InjectMocks
    private UserService userService;

    private UserRegistrationDTO registrationDTO;
    private User user;

    @BeforeEach
    void setUp() {
        registrationDTO = new UserRegistrationDTO();
        registrationDTO.setName("Test User");
        registrationDTO.setEmail("test@example.com");
        registrationDTO.setPassword("password");

        user = new User();
        user.setId(1L);
        user.setName("Test User");
        user.setEmail("test@example.com");
        user.setPasswordHash("encodedPassword");
        user.setRole("USER");
    }

    @Test
    @DisplayName("registerUser - Success")
    void registerUser_Success() {
        given(userRepository.existsByEmail("test@example.com")).willReturn(false);
        given(passwordEncoder.encode("password")).willReturn("encodedPassword");
        given(userRepository.save(any(User.class))).willReturn(user);

        UserResponseDTO response = userService.registerUser(registrationDTO);

        assertNotNull(response);
        assertEquals(1L, response.getId());
        assertEquals("Test User", response.getName());
        verify(userRepository).save(any(User.class));
    }

    @Test
    @DisplayName("registerUser - Email Already Exists")
    void registerUser_EmailExists() {
        given(userRepository.existsByEmail("test@example.com")).willReturn(true);

        assertThrows(RuntimeException.class, () -> {
            userService.registerUser(registrationDTO);
        });
    }

    @Test
    @DisplayName("getUserById - Found")
    void getUserById_Found() {
        given(userRepository.findById(1L)).willReturn(Optional.of(user));

        Optional<UserResponseDTO> response = userService.getUserById(1L);

        assertTrue(response.isPresent());
        assertEquals(1L, response.get().getId());
    }

    @Test
    @DisplayName("getUserById - Not Found")
    void getUserById_NotFound() {
        given(userRepository.findById(1L)).willReturn(Optional.empty());

        Optional<UserResponseDTO> response = userService.getUserById(1L);

        assertFalse(response.isPresent());
    }
}