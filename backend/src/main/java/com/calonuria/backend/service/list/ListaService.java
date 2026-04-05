package com.calonuria.backend.service.list;

import com.calonuria.backend.dto.catalog.FanfictionRespuestaDTO;
import com.calonuria.backend.dto.catalog.LibroRespuestaDTO;
import com.calonuria.backend.dto.catalog.MangaRespuestaDTO;
import com.calonuria.backend.dto.list.ListaDetalleRespuestaDTO;
import com.calonuria.backend.dto.list.ListaRegistroDTO;
import com.calonuria.backend.dto.list.ListaRespuestaDTO;
import com.calonuria.backend.model.list.Lista;
import com.calonuria.backend.model.user.Usuario;
import com.calonuria.backend.repository.list.*;
import com.calonuria.backend.repository.catalog.LibroRepository;
import com.calonuria.backend.repository.catalog.FanfictionRepository;
import com.calonuria.backend.repository.catalog.MangaRepository;
import com.calonuria.backend.repository.user.UsuarioRepository;
import com.calonuria.backend.service.catalog.FanfictionService;
import com.calonuria.backend.service.catalog.LibroService;
import com.calonuria.backend.service.catalog.MangaService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class ListaService {

    @Autowired private ListaRepository listaRepository;
    @Autowired private UsuarioRepository usuarioRepository;
    @Autowired private ListaLibroRepository listaLibroRepository;
    @Autowired private ListaFanficRepository listaFanficRepository;
    @Autowired private ListaMangaRepository listaMangaRepository;
    @Autowired private LibroRepository libroRepository;
    @Autowired private FanfictionRepository fanfictionRepository;
    @Autowired private MangaRepository mangaRepository;
    @Autowired private LibroService libroService;
    @Autowired private FanfictionService fanfictionService;
    @Autowired private MangaService mangaService;

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

    public ListaDetalleRespuestaDTO obtenerDetalle(Long idLista) {
        Lista lista = listaRepository.findById(idLista)
                .orElseThrow(() -> new RuntimeException("Lista no encontrada"));

        List<LibroRespuestaDTO> libros = listaLibroRepository
                .findByLista_IdListaOrderByOrden(idLista)
                .stream()
                .map(ll -> libroService.mapearADTO(ll.getLibro()))
                .collect(Collectors.toList());

        List<FanfictionRespuestaDTO> fanfics = listaFanficRepository
                .findByLista_IdListaOrderByOrden(idLista)
                .stream()
                .map(lf -> fanfictionService.mapearADTO(lf.getFanfic()))
                .collect(Collectors.toList());

        List<MangaRespuestaDTO> mangas = listaMangaRepository
                .findByLista_IdListaOrderByOrden(idLista)
                .stream()
                .map(lm -> mangaService.mapearADTO(lm.getManga()))
                .collect(Collectors.toList());

        return new ListaDetalleRespuestaDTO(
                lista.getIdLista(),
                lista.getNombre(),
                libros, fanfics, mangas
        );
    }

    public void eliminarLista(Long idLista) {
        listaRepository.deleteById(idLista);
    }

    public ListaRespuestaDTO actualizarLista(Long idLista, ListaRegistroDTO dto) {
        Lista lista = listaRepository.findById(idLista)
                .orElseThrow(() -> new RuntimeException("Lista no encontrada"));
        lista.setNombre(dto.getNombre());
        Lista actualizada = listaRepository.save(lista);
        return new ListaRespuestaDTO(actualizada.getIdLista(), actualizada.getNombre());
    }

    public void añadirItem(Long idLista, String tipo, Long idItem) {
        Lista lista = listaRepository.findById(idLista)
                .orElseThrow(() -> new RuntimeException("Lista no encontrada"));

        switch (tipo.toLowerCase()) {
            case "libro":
                com.calonuria.backend.model.catalog.Libro libro = libroRepository.findById(idItem)
                        .orElseThrow(() -> new RuntimeException("Libro no encontrado"));
                com.calonuria.backend.model.list.ListaLibro listaLibro = new com.calonuria.backend.model.list.ListaLibro();
                listaLibro.setLista(lista);
                listaLibro.setLibro(libro);
                listaLibro.setOrden(1); // Orden simple por ahora
                listaLibroRepository.save(listaLibro);
                break;
            case "fanfic":
                com.calonuria.backend.model.catalog.Fanfiction fanfic = fanfictionRepository.findById(idItem)
                        .orElseThrow(() -> new RuntimeException("Fanfic no encontrado"));
                com.calonuria.backend.model.list.ListaFanfic listaFanfic = new com.calonuria.backend.model.list.ListaFanfic();
                listaFanfic.setLista(lista);
                listaFanfic.setFanfic(fanfic);
                listaFanfic.setOrden(1); // Orden simple por ahora
                listaFanficRepository.save(listaFanfic);
                break;
            case "manga":
                com.calonuria.backend.model.catalog.Manga manga = mangaRepository.findById(idItem)
                        .orElseThrow(() -> new RuntimeException("Manga no encontrado"));
                com.calonuria.backend.model.list.ListaManga listaManga = new com.calonuria.backend.model.list.ListaManga();
                listaManga.setLista(lista);
                listaManga.setManga(manga);
                listaManga.setOrden(1); // Orden simple por ahora
                listaMangaRepository.save(listaManga);
                break;
            default:
                throw new RuntimeException("Tipo de item no válido: " + tipo);
        }
    }

    public void eliminarItem(Long idLista, String tipo, Long idItem) {
        Lista lista = listaRepository.findById(idLista)
                .orElseThrow(() -> new RuntimeException("Lista no encontrada"));

        switch (tipo.toLowerCase()) {
            case "libro":
                com.calonuria.backend.model.catalog.Libro libro = libroRepository.findById(idItem)
                        .orElseThrow(() -> new RuntimeException("Libro no encontrado"));
                // Eliminar todos los registros que coincidan
                listaLibroRepository.deleteAll(listaLibroRepository.findByLista_IdListaOrderByOrden(idLista)
                        .stream()
                        .filter(ll -> ll.getLibro().getIdLibro().equals(idItem))
                        .collect(java.util.stream.Collectors.toList()));
                break;
            case "fanfic":
                com.calonuria.backend.model.catalog.Fanfiction fanfic = fanfictionRepository.findById(idItem)
                        .orElseThrow(() -> new RuntimeException("Fanfic no encontrado"));
                listaFanficRepository.deleteAll(listaFanficRepository.findByLista_IdListaOrderByOrden(idLista)
                        .stream()
                        .filter(lf -> lf.getFanfic().getIdFanfic().equals(idItem))
                        .collect(java.util.stream.Collectors.toList()));
                break;
            case "manga":
                com.calonuria.backend.model.catalog.Manga manga = mangaRepository.findById(idItem)
                        .orElseThrow(() -> new RuntimeException("Manga no encontrado"));
                listaMangaRepository.deleteAll(listaMangaRepository.findByLista_IdListaOrderByOrden(idLista)
                        .stream()
                        .filter(lm -> lm.getManga().getIdManga().equals(idItem))
                        .collect(java.util.stream.Collectors.toList()));
                break;
            default:
                throw new RuntimeException("Tipo de item no válido: " + tipo);
        }
    }
}
