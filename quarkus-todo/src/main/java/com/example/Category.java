package com.example;

import io.quarkus.hibernate.orm.panache.PanacheEntity;

import javax.persistence.Entity;

@Entity
public class Category extends PanacheEntity {

    public String name;


}
