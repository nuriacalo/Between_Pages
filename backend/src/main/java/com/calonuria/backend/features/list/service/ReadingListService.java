package com.calonuria.backend.features.list.service;

import com.calonuria.backend.features.catalog.model.Book;
import com.calonuria.backend.features.catalog.model.Fanfiction;
import com.calonuria.backend.features.catalog.model.Manga;
import com.calonuria.backend.features.catalog.repository.BookRepository;
import com.calonuria.backend.features.catalog.repository.FanfictionRepository;
import com.calonuria.backend.features.catalog.repository.MangaRepository;
import com.calonuria.backend.features.list.dto.AddContentToListRequestDTO;
import com.calonuria.backend.features.list.dto.ListItemResponseDTO;
import com.calonuria.backend.features.list.dto.ReadingListDTO;
import com.calonuria.backend.features.list.dto.ReadingListDetailResponseDTO;
import com.calonuria.backend.features.list.dto.ReadingListRequestDTO;
import com.calonuria.backend.features.catalog.service.BookService;
import com.calonuria.backend.features.catalog.service.FanfictionService;
import com.calonuria.backend.features.catalog.service.MangaService;
import com.calonuria.backend.features.list.model.ListItem;
import com.calonuria.backend.features.list.model.ReadingList;
import com.calonuria.backend.features.list.repository.ListItemRepository;
import com.calonuria.backend.features.list.repository.ReadingListRepository;
import com.calonuria.backend.features.user.model.User;
import com.calonuria.backend.features.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ReadingListService {

    private final ReadingListRepository readingListRepository;
    private final UserRepository userRepository;
    private final ListItemRepository listItemRepository;
    private final BookRepository bookRepository;
    private final MangaRepository mangaRepository;
    private final FanfictionRepository fanfictionRepository;
    private final BookService bookService;
    private final MangaService mangaService;
    private final FanfictionService fanfictionService;

    @Transactional(readOnly = true)
    public List<ReadingListDTO> getUserLists(Long userId) {
        return readingListRepository.findByUser_Id(userId).stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    @Transactional
    public ReadingListDTO createList(Long userId, ReadingListRequestDTO dto) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado con ID: " + userId));

        ReadingList list = new ReadingList();
        list.setName(dto.getName());
        list.setDescription(dto.getDescription());
        list.setUser(user);
        
        ReadingList savedList = readingListRepository.save(list);
        return convertToDTO(savedList);
    }

    @Transactional
    public void deleteList(Long listId) {
        if (!readingListRepository.existsById(listId)) {
            throw new RuntimeException("La lista no existe");
        }
        // Eliminará automáticamente los ListItems vinculados si hay 'cascade = CascadeType.ALL' u 'orphanRemoval'
        readingListRepository.deleteById(listId);
    }

    @Transactional
    public void addContentToList(Long listId, AddContentToListRequestDTO requestDTO) {
        ReadingList list = readingListRepository.findById(listId)
                .orElseThrow(() -> new RuntimeException("Lista no encontrada con ID: " + listId));

        String contentType = requestDTO.getContentType().toUpperCase();
        Long contentId = requestDTO.getContentId();

        ListItem listItem = new ListItem();
        listItem.setList(list);
        listItem.setItemType(contentType);
        
        // Obtener la posición actual
        long currentItemCount = listItemRepository.countByList(list);
        listItem.setPosition((int) currentItemCount + 1);

        switch (contentType) {
            case "BOOK":
                Optional<ListItem> existingBook = listItemRepository.findByListAndBookId(list, contentId);
                if (existingBook.isPresent()) {
                    throw new RuntimeException("El libro ya está en la lista");
                }
                Book book = bookRepository.findById(contentId)
                        .orElseThrow(() -> new RuntimeException("Libro no encontrado con ID: " + contentId));
                listItem.setBook(book);
                break;
            case "MANGA":
                Optional<ListItem> existingManga = listItemRepository.findByListAndMangaId(list, contentId);
                if (existingManga.isPresent()) {
                    throw new RuntimeException("El manga ya está en la lista");
                }
                Manga manga = mangaRepository.findById(contentId)
                        .orElseThrow(() -> new RuntimeException("Manga no encontrado con ID: " + contentId));
                listItem.setManga(manga);
                break;
            case "FANFIC":
                Optional<ListItem> existingFanfic = listItemRepository.findByListAndFanficId(list, contentId);
                if (existingFanfic.isPresent()) {
                    throw new RuntimeException("El fanfiction ya está en la lista");
                }
                Fanfiction fanfic = fanfictionRepository.findById(contentId)
                        .orElseThrow(() -> new RuntimeException("Fanfiction no encontrado con ID: " + contentId));
                listItem.setFanfic(fanfic);
                break;
            default:
                throw new IllegalArgumentException("Tipo de contenido no soportado: " + contentType);
        }

        listItemRepository.save(listItem);
    }

    @Transactional(readOnly = true)
    public ReadingListDetailResponseDTO getListDetail(Long listId) {
        ReadingList list = readingListRepository.findById(listId)
                .orElseThrow(() -> new RuntimeException("Lista no encontrada con ID: " + listId));


        List<ListItem> items = listItemRepository.findByList(list);
        // Aseguramos orden por posición para que el frontend no dependa del orden de BD.
        items = items.stream()
                .sorted((a, b) -> {
                    Integer pa = a.getPosition();
                    Integer pb = b.getPosition();
                    if (pa == null && pb == null) return 0;
                    if (pa == null) return 1;
                    if (pb == null) return -1;
                    return pa.compareTo(pb);
                })
                .collect(Collectors.toList());

        List<ListItemResponseDTO> mappedItems = items.stream().map(item -> {
            ListItemResponseDTO dto = new ListItemResponseDTO();
            dto.setId(item.getId());
            dto.setItemType(item.getItemType());
            dto.setPosition(item.getPosition());

            // La BD guarda el tipo (BOOK/MANGA/FANFIC) y la entidad correspondiente.
            String type = item.getItemType() != null ? item.getItemType().toUpperCase() : null;

            if ("BOOK".equals(type) && item.getBook() != null) {
                dto.setBook(bookService.mapToDTO(item.getBook()));
            } else if ("MANGA".equals(type) && item.getManga() != null) {
                dto.setManga(mangaService.mapToDTO(item.getManga()));
            } else if ("FANFIC".equals(type) && item.getFanfic() != null) {
                dto.setFanfic(fanfictionService.mapToDTO(item.getFanfic()));
            }



            return dto;
        }).collect(Collectors.toList());

        return new ReadingListDetailResponseDTO(
                list.getId(),
                list.getName(),
                list.getDescription(),
                mappedItems
        );
    }

    private ReadingListDTO convertToDTO(ReadingList list) {
        ReadingListDTO dto = new ReadingListDTO();
        dto.setId(list.getId());
        dto.setName(list.getName());
        dto.setDescription(list.getDescription());
        return dto;
    }
}
