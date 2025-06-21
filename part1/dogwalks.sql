DROP DATABASE IF EXISTS DogWalkService;
CREATE DATABASE DogWalkService;
USE DogWalkService;
CREATE TABLE Users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('owner', 'walker') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Dogs (
    dog_id INT AUTO_INCREMENT PRIMARY KEY,
    owner_id INT NOT NULL,
    name VARCHAR(50) NOT NULL,
    size ENUM('small', 'medium', 'large') NOT NULL,
    FOREIGN KEY (owner_id) REFERENCES Users(user_id)
);

CREATE TABLE WalkRequests (
    request_id INT AUTO_INCREMENT PRIMARY KEY,
    dog_id INT NOT NULL,
    requested_time DATETIME NOT NULL,
    duration_minutes INT NOT NULL,
    location VARCHAR(255) NOT NULL,
    status ENUM('open', 'accepted', 'completed', 'cancelled') DEFAULT 'open',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (dog_id) REFERENCES Dogs(dog_id)
);

CREATE TABLE WalkApplications (
    application_id INT AUTO_INCREMENT PRIMARY KEY,
    request_id INT NOT NULL,
    walker_id INT NOT NULL,
    applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('pending', 'accepted', 'rejected') DEFAULT 'pending',
    FOREIGN KEY (request_id) REFERENCES WalkRequests(request_id),
    FOREIGN KEY (walker_id) REFERENCES Users(user_id),
    CONSTRAINT unique_application UNIQUE (request_id, walker_id)
);

CREATE TABLE WalkRatings (
    rating_id INT AUTO_INCREMENT PRIMARY KEY,
    request_id INT NOT NULL,
    walker_id INT NOT NULL,
    owner_id INT NOT NULL,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    comments TEXT,
    rated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (request_id) REFERENCES WalkRequests(request_id),
    FOREIGN KEY (walker_id) REFERENCES Users(user_id),
    FOREIGN KEY (owner_id) REFERENCES Users(user_id),
    CONSTRAINT unique_rating_per_walk UNIQUE (request_id)
);


INSERT INTO Users (username, email, password_hash, role) VALUES
('mike001', 'mike001@example.com', 'hashed001', 'owner'),
('mike002', 'mike002@example.com', 'hashed002', 'walker'),
('mike003', 'mike003@example.com', 'hashed003', 'owner'),
('mike004', 'mike004@example.com', 'hashed004', 'walker'),
('mike005', 'mike005@example.com', 'hashed005', 'owner');

INSERT INTO Dogs (owner_id, name, size) VALUES
((SELECT user_id FROM Users WHERE username = 'mike001'), 'Rex', 'medium'),
((SELECT user_id FROM Users WHERE username = 'mike003'), 'Zoe', 'small'),
((SELECT user_id FROM Users WHERE username = 'mike005'), 'Toby', 'large'),
((SELECT user_id FROM Users WHERE username = 'mike001'), 'Milo', 'small'),
((SELECT user_id FROM Users WHERE username = 'mike003'), 'Luna', 'medium');

INSERT INTO WalkRequests (dog_id, requested_time, duration_minutes, location, status) VALUES
((SELECT dog_id FROM Dogs WHERE name = 'Rex'), '2025-04-06 09:00:00', 30, 'Hilltop Trail', 'open'),
((SELECT dog_id FROM Dogs WHERE name = 'Zoe'), '2025-04-07 14:00:00', 45, 'Civic Park', 'accepted'),
((SELECT dog_id FROM Dogs WHERE name = 'Toby'), '2025-04-08 11:30:00', 60, 'Lakeside Walk', 'completed'),
((SELECT dog_id FROM Dogs WHERE name = 'Milo'), '2025-04-09 13:15:00', 25, 'Botanic Path', 'cancelled'),
((SELECT dog_id FROM Dogs WHERE name = 'Luna'), '2025-04-10 17:00:00', 20, 'Downtown Plaza', 'open');
