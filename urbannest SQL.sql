select * from urbannest_data

CREATE TABLE customers (
    customer_id TEXT PRIMARY KEY,
    phone_number BIGINT,
    customer_name TEXT,
    gender TEXT,
    age_group TEXT,
    city TEXT,
    region TEXT,
    customer_segment TEXT
);

INSERT INTO customers (
    customer_id,
    phone_number,
    customer_name,
    gender,
    age_group,
    city,
    region,
    customer_segment
)
SELECT
    customer_id,
    phone_number,
    customer_name,
    gender,
    age_group,
    city,
    region,
    customer_segment
FROM urbannest_data;

CREATE TABLE products (
    product_key SERIAL PRIMARY KEY,
    product_id TEXT,
    product_name TEXT,
    product_category TEXT
);

INSERT INTO products (
    product_id,
    product_name,
    product_category
)
SELECT DISTINCT
    product_id,
    product_name,
    product_category
FROM urbannest_data;

CREATE TABLE orders (
    order_id TEXT PRIMARY KEY,
    customer_id TEXT,
    order_date TIMESTAMP,
    payment_method TEXT,
    sales_channel TEXT,
    order_status TEXT,

    FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
);

INSERT INTO orders (
    order_id,
    customer_id,
    order_date,
    payment_method,
    sales_channel,
    order_status
)
SELECT
    order_id,
    customer_id,
    order_date,
    payment_method,
    sales_channel,
    order_status
FROM urbannest_data;

CREATE TABLE order_items (
    order_id TEXT PRIMARY KEY,
    product_key INTEGER,
    quantity INTEGER,
    unit_price NUMERIC(12,2),
    discount_rate NUMERIC(5,2),
    order_revenue NUMERIC(14,2),
    delivery_fee NUMERIC(12,2),

    FOREIGN KEY (order_id)
        REFERENCES orders(order_id),

    FOREIGN KEY (product_key)
        REFERENCES products(product_key)
);

INSERT INTO order_items (
    order_id,
    product_key,
    quantity,
    unit_price,
    discount_rate,
    order_revenue,
    delivery_fee
)
SELECT
    s.order_id,
    p.product_key,
    s.quantity,
    s.unit_price,
    s.discount_rate,
    s.order_revenue,
    s.delivery_fee
FROM urbannest_data s
JOIN products p
    ON p.product_id = s.product_id
    AND p.product_name = s.product_name
    AND p.product_category = s.product_category;

CREATE TABLE deliveries (
    order_id TEXT PRIMARY KEY,
    delivery_status TEXT,
    delivery_days NUMERIC(5,1),
    customer_rating NUMERIC(2,1),
    return_flag TEXT,

    FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
);	

INSERT INTO deliveries (
    order_id,
    delivery_status,
    delivery_days,
    customer_rating,
    return_flag
)
SELECT
    order_id,
    delivery_status,
    NULLIF(delivery_days, '')::NUMERIC,
    NULLIF(customer_rating, '')::NUMERIC,
    return_flag
FROM urbannest_data;

SELECT COUNT(*) AS urbannest_data_count
FROM urbannest_data;

SELECT COUNT(*) AS customers_count
FROM customers;

SELECT COUNT(*) AS products_count
FROM products;

SELECT COUNT(*) AS orders_count
FROM orders;

SELECT COUNT(*) AS order_items_count
FROM order_items;

SELECT COUNT(*) AS deliveries_count
FROM deliveries;

SELECT
    o.order_id,
    c.customer_name,
    c.city,
    p.product_id,
    p.product_name,
    p.product_category,
    oi.quantity,
    oi.unit_price,
    oi.discount_rate,
    oi.order_revenue,
    o.payment_method,
    o.sales_channel,
    o.order_status,
    d.delivery_status,
    d.delivery_days,
    d.customer_rating,
    d.return_flag
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id

JOIN order_items oi
    ON o.order_id = oi.order_id

JOIN products p
    ON oi.product_key = p.product_key

JOIN deliveries d
    ON o.order_id = d.order_id

LIMIT 50;

SELECT
    COUNT(order_id) AS total_orders,
    SUM(order_revenue::NUMERIC) AS total_revenue
FROM urbannest_data;

CREATE TABLE sales_summary AS
SELECT
    COUNT(order_id) AS total_orders,
    SUM(order_revenue::NUMERIC) AS total_revenue
FROM urbannest_data;
