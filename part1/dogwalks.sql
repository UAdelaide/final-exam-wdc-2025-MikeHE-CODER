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
('emily123', 'emily@example.com', 'hashed123', 'owner'),
('davidwalker', 'david@example.com', 'hashed456', 'walker'),
('sophie456', 'sophie@example.com', 'hashed789', 'owner'),
('walkerleo', 'leo@example.com', 'hashed999', 'walker'),
('ownerkate', 'kate@example.com', 'hashed000', 'owner');

INSERT INTO Dogs (owner_id, name, size) VALUES
((SELECT user_id FROM Users WHERE username = 'emily123'), 'Shadow', 'medium'),
((SELECT user_id FROM Users WHERE username = 'sophie456'), 'Nina', 'small'),
((SELECT user_id FROM Users WHERE username = 'ownerkate'), 'Bolt', 'large'),
((SELECT user_id FROM Users WHERE username = 'emily123'), 'Lassie', 'small'),
((SELECT user_id FROM Users WHERE username = 'sophie456'), 'Charlie', 'medium');

INSERT INTO WalkRequests (dog_id, requested_time, duration_minutes, location, status) VALUES
((SELECT dog_id FROM Dogs WHERE name = 'Shadow'), '2025-06-15 08:30:00', 30, 'Greenfield Park', 'open'),
((SELECT dog_id FROM Dogs WHERE name = 'Nina'), '2025-06-15 10:00:00', 45, 'Sunrise Trail', 'accepted'),
((SELECT dog_id FROM Dogs WHERE name = 'Bolt'), '2025-06-15 11:15:00', 60, 'Central Square', 'open'),
((SELECT dog_id FROM Dogs WHERE name = 'Lassie'), '2025-06-16 13:00:00', 25, 'East Side Garden', 'completed'),
((SELECT dog_id FROM Dogs WHERE name = 'Charlie'), '2025-06-17 16:00:00', 20, 'Maple Street', 'cancelled');
