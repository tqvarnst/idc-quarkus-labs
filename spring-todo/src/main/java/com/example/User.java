package com.example;

import lombok.Getter;
import lombok.Setter;

import javax.persistence.*;

@Entity
@Table(name="Todo_User")
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    @Getter
    @Setter
    private Long id;

    @Getter @Setter
    public String surname;

    @Getter @Setter
    public String firstname;

    @Getter @Setter
    public String email;


}
