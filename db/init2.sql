-- CREATE DATABASE IF NOT EXISTS mydb2;
USE db2;

-- Users Table
CREATE TABLE
    users (
        id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(100) NOT NULL,
        email VARCHAR(100) UNIQUE NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

-- Products Table
CREATE TABLE
    products (
        id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(100) NOT NULL,
        price DECIMAL(10, 2) NOT NULL,
        stock INT NOT NULL DEFAULT 0
    );

-- Orders Table
CREATE TABLE
    orders (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT,
        product_id INT,
        quantity INT NOT NULL,
        order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE CASCADE
    );

-- Seed Users
INSERT INTO
    users (name, email)
VALUES
    ('Alice Johnson', 'alice@example.com'),
    ('Bob Smith', 'bob@example.com');

-- Seed Products
INSERT INTO
    products (name, price, stock)
VALUES
    ('Laptop', 1200.00, 10),
    ('Smartphone', 800.00, 20),
    ('Headphones', 150.00, 30);

-- Seed Orders
INSERT INTO
    orders (user_id, product_id, quantity)
VALUES
    (1, 1, 1), -- Alice buys a Laptop
    (2, 2, 2), -- Bob buys 2 Smartphones
    (1, 3, 1);

-- Alice buys Headphones