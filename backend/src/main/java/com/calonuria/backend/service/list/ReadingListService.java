package com.calonuria.backend.service.list;

import com.calonuria.backend.dto.catalog.BookResponseDTO;
import com.calonuria.backend.dto.catalog.FanfictionResponseDTO;
import com.calonuria.backend.dto.catalog.MangaResponseDTO;
import com.calonuria.backend.dto.list.ReadingListDetailResponseDTO;
import com.calonuria.backend.dto.list.ReadingListRegistrationDTO;
import com.calonuria.backend.dto.list.ReadingListResponseDTO;
import com.calonuria.backend.model.list.ListItem;
import com.calonuria.backend.model.list.ReadingList;
import com.calonuria.backend.model.user.User;
import com.calonuria.backend.repository.list.ListItemRepository;
import com.calonuria.backend.repository.list.ReadingListRepository;
import com.calonuria.backend.repository.catalog.BookRepository;
import com.calonuria.backend.repository.catalog.FanfictionRepository;
import com.calonuria.backend.repository.catalog.MangaRepository;
import com.calonuria.backend.repository.user.UserRepository;
import com.calonuria.backend.service.catalog.BookService;
import com.calonuria.backend.service.catalog.FanfictionService;
import com.calonuria.backend.service.catalog.MangaService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Servicio para la gestión de listas de lectura.
 */
@Service
public class ReadingListService {

    @Autowired
    private ReadingListRepository readingListRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private ListItemRepository listItemRepository;

    @Autowired
    private BookRepository bookRepository;

    @Autowired
    private FanfictionRepository fanfictionRepository;

    @Autowired
    private MangaRepository mangaRepository;

    @Autowired
    private BookService bookService;

    @Autowired
    private FanfictionService fanfictionService;

    @Autowired
    private MangaService mangaService;

    /**
     * Crea una nueva lista de lectura.
     * @param dto datos de la lista
     * @return DTO con la información de la lista creada
     */
    public ReadingListResponseDTO createList(ReadingListRegistrationDTO dto) {
        User user = userRepository.findById(dto.getUserId())
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));
        ReadingList list = new ReadingList();
        list.setUser(user);
        list.setName(dto.getName());
        ReadingList saved = readingListRepository.save(list);
        return new ReadingListResponseDTO(saved.getId(), saved.getName(), saved.getDescription());
    }

    /**
     * Obtiene las listas de un usuario.
     * @param userId ID del usuario
     * @return lista de DTOs con la información de las listas
     */
    public List<ReadingListResponseDTO> getUserLists(Long userId) {
        return readingListRepository.findByUserId(userId)
                .stream()
                .map(l -> new ReadingListResponseDTO(l.getId(), l.getName(), l.getDescription()))
                .collect(Collectors.toList());
    }

    /**
     * Obtiene el detalle de una lista incluyendo sus items.
     * @param listId ID de la lista
     * @return DTO con el detalle de la lista
     */
    public ReadingListDetailResponseDTO getListDetail(Long listId) {
        ReadingList list = readingListRepository.findById(listId)
                .orElseThrow(() -> new RuntimeException("Lista no encontrada"));

        List<ListItem> items = listItemRepository.findByList(list);

        List<BookResponseDTO> books = items.stream()
                .filter(item -> item.getBook() != null)
                .map(item -> bookService.mapToDTO(item.getBook()))
                .collect(Collectors.toList());

        List<FanfictionResponseDTO> fanfics = items.stream()
                .filter(item -> item.getFanfic() != null)
                .map(item -> fanfictionService.mapToDTO(item.getFanfic()))
                .collect(Collectors.toList());

        List<MangaResponseDTO> mangas = items.stream()
                .filter(item -> item.getManga() != null)
                .map(item -> mangaService.mapToDTO(item.getManga()))
                .collect(Collectors.toList());

        return new ReadingListDetailResponseDTO(
                list.getId(),
                list.getName(),
                books, fanfics, mangas
        );
    }

    /**
     * Elimina una lista de lectura.
     * @param listId ID de la lista
     */
    public void deleteList(Long listId) {
        readingListRepository.deleteById(listId);
    }

    /**
     * Actualiza una lista de lectura.
     * @param listId ID de la lista
     * @param dto datos actualizados
     * @return DTO con la información actualizada
     */
    public ReadingListResponseDTO updateList(Long listId, ReadingListRegistrationDTO dto) {
        ReadingList list = readingListRepository.findById(listId)
                .orElseThrow(() -> new RuntimeException("Lista no encontrada"));
        list.setName(dto.getName());
        list.setDescription(dto.getDescription());
        ReadingList updated = readingListRepository.save(list);
        return new ReadingListResponseDTO(updated.getId(), updated.getName(), updated.getDescription());
    }

    /**
     * Añade un item a una lista.
     * @param listId ID de la lista
     * @param type tipo de item (book, fanfic, manga)
     * @param itemId ID del item
     */
    public void addItem(Long listId, String type, Long itemId) {
        ReadingList list = readingListRepository.findById(listId)
                .orElseThrow(() -> new RuntimeException("Lista no encontrada"));

        ListItem listItem = new ListItem();
        listItem.setList(list);
        listItem.setPosition(1); // Posición simple por ahora

        switch (type.toLowerCase()) {
            case "book":
                listItem.setBook(bookRepository.findById(itemId)
                        .orElseThrow(() -> new RuntimeException("Libro no encontrado")));
                break;
            case "fanfic":
                listItem.setFanfic(fanfictionRepository.findById(itemId)
                        .orElseThrow(() -> new RuntimeException("Fanfic no encontrado")));
                break;
            case "manga":
                listItem.setManga(mangaRepository.findById(itemId)
                        .orElseThrow(() -> new RuntimeException("Manga no encontrado")));
                break;
            default:
                throw new RuntimeException("Tipo de item no válido: " + type);
        }

        listItemRepository.save(listItem);
    }

    /**
     * Elimina un item de una lista.
     * @param listId ID de la lista
     * @param type tipo de item
     * @param itemId ID del item
     */
    public void removeItem(Long listId, String type, Long itemId) {
        ReadingList list = readingListRepository.findById(listId)
                .orElseThrow(() -> new RuntimeException("Lista no encontrada"));

        List<ListItem> items = listItemRepository.findByList(list);

        List<ListItem> toDelete = items.stream()
                .filter(item -> {
                    switch (type.toLowerCase()) {
                        case "book":
                            return item.getBook() != null && item.getBook().getId().equals(itemId);
                        case "fanfic":
                            return item.getFanfic() != null && item.getFanfic().getId().equals(itemId);
                        case "manga":
                            return item.getManga() != null && item.getManga().getId().equals(itemId);
                        default:
                            return false;
                    }
                })
                .collect(Collectors.toList());

        listItemRepository.deleteAll(toDelete);
    }
}
