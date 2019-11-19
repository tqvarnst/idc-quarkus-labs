package com.example;

import io.quarkus.hibernate.orm.panache.PanacheEntity;

import javax.persistence.*;

@Entity
@Table(name="Todo_User")
public class User extends PanacheEntity {

    public String surname;

    public String firstname;

    public String email;


}
