package com.example;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@SpringBootApplication
public class Application {

  public static void main(String[] args) {
    SpringApplication.run(Application.class, args);
  }

  @RestController
  @RequestMapping("/")
  public class ExampleController {

    public final String runtime;

    public ExampleController(@Value("${app.runtime}") String runtime) {
      this.runtime = runtime;
    }

    @GetMapping
    public String sayHello() {
      return String.format("Hello, World from Spring on %s!!!",runtime);
    }
    
  }

}
