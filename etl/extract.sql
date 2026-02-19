-- Run with psql from project root so relative paths resolve.
TRUNCATE TABLE staging.customers_raw;
TRUNCATE TABLE staging.orders_raw;
TRUNCATE TABLE staging.transactions_raw;

\copy staging.customers_raw FROM 'data/raw/customers.csv' WITH (FORMAT csv, HEADER true)
\copy staging.orders_raw FROM 'data/raw/orders.csv' WITH (FORMAT csv, HEADER true)
\copy staging.transactions_raw FROM 'data/raw/transactions.csv' WITH (FORMAT csv, HEADER true)
