CREATE TABLE IF NOT EXISTS warehouse.dim_customer (
    customer_sk BIGSERIAL PRIMARY KEY,
    customer_id INT NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL,
    city VARCHAR(100),
    country VARCHAR(2) NOT NULL,
    signup_date DATE NOT NULL,
    valid_from DATE NOT NULL,
    valid_to DATE NOT NULL DEFAULT DATE '9999-12-31',
    is_current BOOLEAN NOT NULL DEFAULT TRUE,
    hash_diff TEXT NOT NULL,
    UNIQUE (customer_id, valid_from)
);

CREATE TABLE IF NOT EXISTS warehouse.dim_date (
    date_sk INT PRIMARY KEY,
    full_date DATE UNIQUE NOT NULL,
    day_number INT NOT NULL,
    month_number INT NOT NULL,
    month_name TEXT NOT NULL,
    quarter_number INT NOT NULL,
    year_number INT NOT NULL,
    is_weekend BOOLEAN NOT NULL
);

CREATE TABLE IF NOT EXISTS warehouse.dim_payment_method (
    payment_method_sk SERIAL PRIMARY KEY,
    payment_method VARCHAR(30) UNIQUE NOT NULL
);
