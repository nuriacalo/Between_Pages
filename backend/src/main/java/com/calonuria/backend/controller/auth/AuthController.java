package com.calonuria.backend.controller.auth;

import com.calonuria.backend.dto.auth.AuthRespuestaDTO;
import com.calonuria.backend.dto.auth.LoginDTO;
import com.calonuria.backend.dto.auth.RefreshTokenRequestDTO;
import com.calonuria.backend.dto.user.UsuarioRespuestaDTO;
import com.calonuria.backend.model.user.Usuario;
import com.calonuria.backend.repository.user.UsuarioRepository;
import com.calonuria.backend.security.JwtUtil;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@Tag(name = "Autenticación", description = "Login y gestión de tokens JWT")
public class AuthController {

    @Autowired private AuthenticationManager authenticationManager;
    @Autowired private JwtUtil jwtUtil;
    @Autowired private UsuarioRepository usuarioRepository;

    @Operation(summary = "Login — devuelve accessToken y refreshToken")
    @PostMapping("/login")
    public ResponseEntity<?> login(@Valid @RequestBody LoginDTO loginDTO) {
        try {
            authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(
                            loginDTO.getEmail(), loginDTO.getPassword()
                    )
            );
            Usuario usuario = usuarioRepository.findByEmail(loginDTO.getEmail())
                    .orElseThrow();

            return ResponseEntity.ok(new AuthRespuestaDTO(
                    jwtUtil.generarAccessToken(usuario.getEmail()),
                    jwtUtil.generarRefreshToken(usuario.getEmail()),
                    usuario.getEmail(),
                    usuario.getNombre(),
                    usuario.getRol()
            ));
        } catch (AuthenticationException e) {
            return ResponseEntity.status(401).body("Email o contraseña incorrectos");
        }
    }

    @Operation(summary = "Renovar tokens")
    @PostMapping("/refresh")
    public ResponseEntity<?> refresh(
            @Valid @RequestBody RefreshTokenRequestDTO request) {
        try {
            String email = jwtUtil.extraerEmail(request.getRefreshToken());
            if (!jwtUtil.esTokenValido(request.getRefreshToken())) {
                return ResponseEntity.status(401).body("Token inválido o expirado");
            }
            Usuario usuario = usuarioRepository.findByEmail(email).orElseThrow();

            return ResponseEntity.ok(new AuthRespuestaDTO(
                    jwtUtil.generarAccessToken(email),
                    jwtUtil.generarRefreshToken(email),
                    usuario.getEmail(),
                    usuario.getNombre(),
                    usuario.getRol()
            ));
        } catch (Exception e) {
            return ResponseEntity.status(401).body("Refresh token inválido");
        }
    }

    @Operation(summary = "Datos del usuario autenticado")
    @GetMapping("/me")
    public ResponseEntity<?> getCurrentUser(Authentication authentication) {
        if (authentication == null || !authentication.isAuthenticated()) {
            return ResponseEntity.status(401).body("No autenticado");
        }
        Usuario usuario = usuarioRepository.findByEmail(authentication.getName())
                .orElseThrow();

        return ResponseEntity.ok(new UsuarioRespuestaDTO(
                usuario.getIdUsuario(),
                usuario.getNombre(),
                usuario.getEmail(),
                usuario.getRol()
        ));
    }
}