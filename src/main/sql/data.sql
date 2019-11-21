INSERT INTO Category(id,name) VALUES (nextval('hibernate_sequence'), 'Work'); 
INSERT INTO Category(id,name) VALUES (nextval('hibernate_sequence'), 'Private');
INSERT INTO Category(id,name) VALUES (nextval('hibernate_sequence'), 'Family');

INSERT INTO Todo_User(id,firstname,surname,email) VALUES (nextval('hibernate_sequence'), 'Thomas','Qvarnstrom','no-reply@redhat.com');
INSERT INTO Todo_User(id,firstname,surname,email) VALUES (nextval('hibernate_sequence'), 'John','OHara','no-reply@redhat.com');

INSERT INTO Todo(id, title, completed, ordering, user_id, url) VALUES (nextval('hibernate_sequence'), 'Introduction to Quarkus', true, 0, 4, null);
INSERT INTO Todo(id, title, completed, ordering, user_id, url) VALUES (nextval('hibernate_sequence'), 'Write Evaluation Plan', true, 1, 4, null);
INSERT INTO Todo(id, title, completed, ordering, user_id, url) VALUES (nextval('hibernate_sequence'), 'Run Lab 1.1 - Startup memory', false, 2, 4, null);
INSERT INTO Todo(id, title, completed, ordering, user_id, url) VALUES (nextval('hibernate_sequence'), 'Run Lab 1.2 - Container density', false, 3, 4, null);
INSERT INTO Todo(id, title, completed, ordering, user_id, url) VALUES (nextval('hibernate_sequence'), 'Run Lab 1.3 - Memory usage under load', false, 3, 5, null);

INSERT INTO Todo_Categories(todo_id,category_id) VALUES (6,1);
INSERT INTO Todo_Categories(todo_id,category_id) VALUES (7,1);
INSERT INTO Todo_Categories(todo_id,category_id) VALUES (8,1);
INSERT INTO Todo_Categories(todo_id,category_id) VALUES (9,1);
INSERT INTO Todo_Categories(todo_id,category_id) VALUES (10,1);