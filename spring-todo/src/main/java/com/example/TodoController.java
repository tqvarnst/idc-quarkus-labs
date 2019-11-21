package com.example;

import lombok.Lombok;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import javax.transaction.Transactional;
import java.util.List;


@RestController
@RequestMapping("api")
public class TodoController {

    private final TodoRepository todoRepository;

    public TodoController(TodoRepository todoRepository) {
        this.todoRepository = todoRepository;
    }

    @GetMapping
    public Iterable<Todo> findAll() {
        return todoRepository.findAll();
    }

    @GetMapping("/sorted")
    public List<Todo> getAllSorted() {
        return todoRepository.findAllByOrderByOrder();
    }

    @PatchMapping("/{id}")
    public ResponseEntity<Todo> update(@RequestBody Todo todo, @PathVariable("id") Long id) {
        todoRepository.save(todo);
        return ResponseEntity.ok(todo);
    }

    @PostMapping
    @Transactional
    public ResponseEntity<Todo> createNew(@RequestBody Todo todo) {
        todoRepository.save(todo);
        return new ResponseEntity<>( todo, HttpStatus.CREATED );
    }

    @DeleteMapping("/{id}")
    @Transactional
    public ResponseEntity<?> delete(@PathVariable Long id) {
        todoRepository.deleteById(id);
        return ResponseEntity.ok().build();
    }

}
