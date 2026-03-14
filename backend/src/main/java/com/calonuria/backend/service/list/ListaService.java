package com.calonuria.backend.service.list;

import com.calonuria.backend.dto.list.ListaRegistroDTO;
import com.calonuria.backend.dto.list.ListaRespuestaDTO;
import com.calonuria.backend.model.list.Lista;
import com.calonuria.backend.model.user.Usuario;
import com.calonuria.backend.repository.list.ListaRepository;
import com.calonuria.backend.repository.user.UsuarioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class ListaService {

    @Autowired
    private ListaRepository listaRepository;

    @Autowired
    private UsuarioRepository usuarioRepository;

    public ListaRespuestaDTO crearLista(ListaRegistroDTO dto) {
        Usuario usuario = usuarioRepository.findById(dto.getIdUsuario())
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

        Lista lista = new Lista();
        lista.setUsuario(usuario);
        lista.setNombre(dto.getNombre());

        Lista guardada = listaRepository.save(lista);
        return new ListaRespuestaDTO(guardada.getIdLista(), guardada.getNombre());
    }

    public List<ListaRespuestaDTO> obtenerListasDeUsuario(Long idUsuario) {
        return listaRepository.findByUsuario_IdUsuario(idUsuario)
                .stream()
                .map(l -> new ListaRespuestaDTO(l.getIdLista(), l.getNombre()))
                .collect(Collectors.toList());
    }

    public void eliminarLista(Long idLista) {
        listaRepository.deleteById(idLista);
    }
}