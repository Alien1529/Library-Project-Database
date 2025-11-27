
-- DATA FOR THEMES
INSERT INTO Library.Theme (ThemeName) VALUES
('Literatura'),
('Técnicos'),
('Arte'),
('Viajes'),
('Cocina'),
('Biográficos');

-- DATA FOR BOOKS
INSERT INTO Library.Book (ISBN, Title, Author, Editorial, Year, ThemeId) VALUES
('978-12345', 'Cien años de soledad', 'Gabriel García Márquez', 'Sudamericana', 1967, 1),
('978-98765', 'Don Quijote de la Mancha', 'Miguel de Cervantes', 'EDAF', 1605, 1),
('978-11111', 'Programación en C# para principiantes', 'Juan Pérez', 'Anaya', 2020, 2),
('978-22222', 'Historia de Leonardo da Vinci', 'Anna Smith', 'Arte Press', 2018, 3),
('978-33333', 'Viajes por la Patagonia', 'Carlos Mendoza', 'Geo Libros', 2015, 4),
('978-44444', 'Recetas tradicionales de cocina italiana', 'María Rossi', 'Cocina Fácil', 2017, 5),
('978-55555', 'Inteligencia Artificial para todos', 'Alan Turing', 'Tech Books', 2021, 2),
('978-66666', 'Autobiografía de Nelson Mandela', 'Nelson Mandela', 'Biografía Plus', 1994, 6),
('978-77777', 'Manual de fotografía creativa', 'Laura Gómez', 'Arte Press', 2019, 3),
('978-88888', 'Explorando el Himalaya', 'Tenzing Norgay', 'Montaña Ed.', 2010, 4);

-- DATA FOR USERS
INSERT INTO Library.User (Email, FirstName, LastName) VALUES
('ana.gomez@example.com', 'Ana', 'Gómez'),
('luis.martinez@example.com', 'Luis', 'Martínez'),
('maria.fernandez@example.com', 'María', 'Fernández'),
('jose.rodriguez@example.com', 'José', 'Rodríguez'),
('carla.soto@example.com', 'Carla', 'Soto');