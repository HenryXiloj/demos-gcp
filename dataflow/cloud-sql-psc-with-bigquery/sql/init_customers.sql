CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    address TEXT,
    registration_date DATE DEFAULT CURRENT_DATE,
    loyalty_points INTEGER DEFAULT 0
);

INSERT INTO customers (first_name, last_name, email, phone, address) VALUES
('John', 'Doe', 'john.doe@example.com', '555-123-4567', '123 Main St, Anytown, USA'),
('Jane', 'Smith', 'jane.smith@example.com', '555-987-6543', '456 Oak Ave, Somewhere, USA'),
('Robert', 'Johnson', 'robert.j@example.com', '555-456-7890', '789 Pine Rd, Nowhere, USA'),
('Emily', 'Williams', 'emily.w@example.com', NULL, '321 Elm Blvd, Anywhere, USA'),
('Michael', 'Brown', 'michael.b@example.com', '555-111-2222', '654 Cedar Ln, Everywhere, USA');