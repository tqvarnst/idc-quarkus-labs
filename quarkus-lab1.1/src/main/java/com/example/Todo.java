package com.example;

import io.quarkus.hibernate.orm.panache.PanacheEntity;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.validation.constraints.NotBlank;

@Entity
public class Todo extends PanacheEntity {
    @NotBlank
    @Column(unique = true)
    public String title;
    public boolean completed;
    @Column(name = "ordering")
    public int order;
    public String url;
}
