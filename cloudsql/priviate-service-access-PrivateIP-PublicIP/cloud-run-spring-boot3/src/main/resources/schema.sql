CREATE TABLE IF NOT EXISTS table1 (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50),
    age INT
);

CREATE TABLE IF NOT EXISTS table2 (
    id SERIAL PRIMARY KEY,
    city VARCHAR(50),
    country VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS table3 (
    id SERIAL PRIMARY KEY,
    product VARCHAR(50),
    price DECIMAL(10, 2)
);