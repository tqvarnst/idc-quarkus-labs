package com.example;

import lombok.Getter;
import lombok.Setter;

import javax.persistence.*;
import javax.validation.constraints.NotBlank;
import javax.xml.bind.annotation.XmlElement;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

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

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name="user_id")
    public User user;

    @XmlElement
    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    @ManyToMany(fetch = FetchType.EAGER)
    @JoinTable(name = "Todo_Categories", joinColumns = @JoinColumn(name = "todo_id"),
            inverseJoinColumns = @JoinColumn(name = "category_id"))
    public Set<Category> categories;


    protected Set<Category> getCategoriesInternal() {
        if(this.categories==null) {
            this.categories = new HashSet<>();
        }
        return this.categories;
    }

    @XmlElement
    public List<Category> getCategories() {
        return new ArrayList<>(getCategoriesInternal());
    }

    public void addCategory(Category category) {
        getCategoriesInternal().add(category);
    }

    public Todo() {
    }

}
