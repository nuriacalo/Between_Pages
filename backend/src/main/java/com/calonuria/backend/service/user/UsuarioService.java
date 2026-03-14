package com.calonuria.backend.service.user;

import com.calonuria.backend.dto.user.UsuarioRegistroDTO;
import com.calonuria.backend.dto.user.UsuarioRespuestaDTO;
import com.calonuria.backend.model.user.Usuario;
import com.calonuria.backend.repository.user.UsuarioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import java.util.Optional;

@Service
public class UsuarioService {

    @Autowired
    private UsuarioRepository usuarioRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    public UsuarioRespuestaDTO registrarUsuario(UsuarioRegistroDTO registroDTO) {
        if (usuarioRepository.existsByEmail(registroDTO.getEmail())) {
            throw new RuntimeException("El email ya está registrado.");
        }

        Usuario nuevoUsuario = new Usuario();
        nuevoUsuario.setNombre(registroDTO.getNombre());
        nuevoUsuario.setEmail(registroDTO.getEmail());
        nuevoUsuario.setPasswordHash(passwordEncoder.encode(registroDTO.getPassword()));
        nuevoUsuario.setRol("USER");

        Usuario guardado = usuarioRepository.save(nuevoUsuario);
        return mapearADTO(guardado);
    }

    public Optional<UsuarioRespuestaDTO> obtenerUsuarioPorId(Long id) {
        return usuarioRepository.findById(id).map(this::mapearADTO);
    }

    public UsuarioRespuestaDTO mapearADTO(Usuario usuario) {
        return new UsuarioRespuestaDTO(
                usuario.getIdUsuario(),
                usuario.getNombre(),
                usuario.getEmail(),
                usuario.getRol()
        );
    }
}