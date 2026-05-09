package com.calonuria.backend.service.list;

import com.calonuria.backend.dto.list.ReadingListDTO;
import com.calonuria.backend.dto.list.ReadingListRequestDTO;
import com.calonuria.backend.features.list.model.ReadingList;
import com.calonuria.backend.features.user.model.User;
import com.calonuria.backend.repository.list.ReadingListRepository;
import com.calonuria.backend.features.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ReadingListService {

    private final ReadingListRepository readingListRepository;
    private final UserRepository userRepository;

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

    private ReadingListDTO convertToDTO(ReadingList list) {
        ReadingListDTO dto = new ReadingListDTO();
        dto.setId(list.getId());
        dto.setName(list.getName());
        dto.setDescription(list.getDescription());
        return dto;
    }
}