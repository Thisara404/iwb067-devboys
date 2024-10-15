create database bal_comp;
use bal_comp;

CREATE TABLE users (
    userId INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL,
    password VARCHAR(255) NOT NULL,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE chats (
    chatId INT AUTO_INCREMENT PRIMARY KEY,
    userId INT,
    role ENUM('user', 'model') NOT NULL,
    text TEXT NOT NULL,
    img VARCHAR(255),
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (userId) REFERENCES users(userId)
);

CREATE TABLE user_chats (
    userChatId INT AUTO_INCREMENT PRIMARY KEY,
    userId INT,
    chatId INT,
    title VARCHAR(255),
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (userId) REFERENCES users(userId),
    FOREIGN KEY (chatId) REFERENCES chats(chatId)
);
