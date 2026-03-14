package com.calonuria.backend.model.list;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.io.Serializable;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ListaItemId implements Serializable {
    private Long lista;
    private Long fanfic;
}