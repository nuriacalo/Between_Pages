package com.calonuria.backend.features.notes.dto;

import lombok.Data;

@Data
public class NoteRequestDTO {
    
    private String itemType;
    private Long itemId;
    
    // Campos opcionales
    private String quote;
    private String note;
    private Integer page;
}