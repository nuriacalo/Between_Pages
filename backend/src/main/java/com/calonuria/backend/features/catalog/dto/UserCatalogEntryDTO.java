package com.calonuria.backend.features.catalog.dto;

import lombok.Data;
import jakarta.validation.constraints.NotNull;

@Data
public class UserCatalogEntryDTO {

    @NotNull
    private Long userId;

    @NotNull
    private String itemType;

    private Long bookId;
    private Long mangaId;
    private Long fanficId;
}
