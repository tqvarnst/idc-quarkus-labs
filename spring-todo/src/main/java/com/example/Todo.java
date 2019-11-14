package com.example;

import lombok.Getter;
import lombok.Setter;

import javax.persistence.*;
import javax.validation.constraints.NotBlank;

@Entity
public class Todo {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    @Getter @Setter
    private Long id;

    @NotBlank
    @Column(unique = true)
    @Getter @Setter
    private String title;

    @Getter @Setter
    private boolean completed;

    @Column(name = "ordering")
    @Getter @Setter
    private int order;

    @Getter @Setter
    private String url;

    public Todo() {
    }

}
