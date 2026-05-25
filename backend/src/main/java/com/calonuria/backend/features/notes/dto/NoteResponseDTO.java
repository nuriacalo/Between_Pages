package com.calonuria.backend.features.notes.dto;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class NoteResponseDTO {
    
    private Long id;
    private String itemType;
    private Long itemId;
    
    private String quote;
    private String note;
    private Integer page;
    
    private LocalDateTime createdAt;
}