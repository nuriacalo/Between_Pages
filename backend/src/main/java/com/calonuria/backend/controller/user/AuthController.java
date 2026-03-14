package com.calonuria.backend.controller.user;

import com.calonuria.backend.dto.user.LoginDTO;
import com.calonuria.backend.dto.user.LoginRespuestaDTO;
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
import org.springframework.security.core.AuthenticationException;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@Tag(name = "Autenticación", description = "Login y gestión de tokens JWT")
public class AuthController {

    @Autowired
    private AuthenticationManager authenticationManager;

    @Autowired
    private JwtUtil jwtUtil;

    @Autowired
    private UsuarioRepository usuarioRepository;

    @Operation(summary = "Login — devuelve un token JWT")
    @PostMapping("/login")
    public ResponseEntity<?> login(@Valid @RequestBody LoginDTO loginDTO) {
        try {
            authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(
                            loginDTO.getEmail(),
                            loginDTO.getPassword()
                    )
            );

            Usuario usuario = usuarioRepository.findByEmail(loginDTO.getEmail())
                    .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

            String token = jwtUtil.generarToken(usuario.getEmail(), usuario.getRol());

            return ResponseEntity.ok(new LoginRespuestaDTO(
                    token,
                    usuario.getEmail(),
                    usuario.getNombre(),
                    usuario.getRol()
            ));

        } catch (AuthenticationException e) {
            return ResponseEntity.status(401).body("Email o contraseña incorrectos");
        }
    }
}