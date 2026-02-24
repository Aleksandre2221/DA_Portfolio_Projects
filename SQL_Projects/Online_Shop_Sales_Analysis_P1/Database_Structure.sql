


                                                            	-- =====================================================
                                                                          -- E-Commerce Database Schema
                                                              -- =====================================================




-- ============================
-- DROP TABLES (child → parent)
-- ============================

DROP TABLE IF EXISTS reviews;
DROP TABLE IF EXISTS shipments;
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS suppliers;



-- =========================
-- Customers
-- =========================

CREATE TABLE customers (
	customer_id     INT PRIMARY KEY, 		
	first_name      VARCHAR(50) NOT NULL, 
	last_name       VARCHAR(50) NOT NULL, 
	address         VARCHAR(100),
	email           VARCHAR(100),
	phone_number    VARCHAR(15)
);



-- =========================
-- Suppliers
-- =========================

CREATE TABLE suppliers (
	supplier_id     INT PRIMARY KEY,   			
	supplier_name   VARCHAR(50) NOT NULL,
	contact_name    VARCHAR(50),
	address         VARCHAR(100),
	phone_number    VARCHAR(20), 
	email           VARCHAR(100)
);



-- =========================
-- Products
-- =========================

CREATE TABLE products (
	product_id      INT PRIMARY KEY, 			
	product_name    VARCHAR(100) NOT NULL, 
	category        VARCHAR(50), 
	price           NUMERIC(10, 2) NOT NULL,
	supplier_id     INT NOT NULL,

  CONSTRAINT fk_products_supplier
      FOREIGN KEY (supplier_id)
      REFERENCES suppliers(supplier_id)
); 



-- =========================
-- Orders
-- =========================

CREATE TABLE orders (
	order_id        INT PRIMARY KEY, 		
	order_date      DATE NOT NULL, 
	customer_id     INT NOT NULL,	
	total_price     NUMERIC(10, 2) NOT NULL,

  CONSTRAINT fk_orders_customer
      FOREIGN KEY (customer_id)
      REFERENCES customers(customer_id)
);



-- =========================
-- Order Items
-- =========================

CREATE TABLE order_items (
	order_item_id         INT PRIMARY KEY, 		
	order_id              INT NOT NULL,			
	product_id            INT NOT NULL, 		
	quantity              INT NOT NULL,
	price_at_purchase     NUMERIC(10, 2) NOT NULL,

  CONSTRAINT fk_order_items_order
      FOREIGN KEY (order_id)
      REFERENCES orders(order_id),

  CONSTRAINT fk_order_items_product
      FOREIGN KEY (product_id)
      REFERENCES products(product_id)
);



-- =========================
-- Payments
-- =========================

CREATE TABLE payments (
	payment_id           INT PRIMARY KEY, 		
	order_id             INT NOT NULL, 			
	payment_method       VARCHAR(50) NOT NULL,
	amount               NUMERIC(10, 2) NOT NULL, 
	transaction_status   VARCHAR(20),

  CONSTRAINT fk_payments_order
      FOREIGN KEY (order_id)
      REFERENCES orders(order_id)
);



-- =========================
-- Shipments
-- =========================

CREATE TABLE shipments (
	shipment_id         INT PRIMARY KEY,  	
	order_id            INT NOT NULL, 	  	
	shipment_date       DATE NOT NULL,
	carrier             VARCHAR(50), 
	tracking_number     VARCHAR(50), 
	delivery_date       DATE, 
	shipment_status     VARCHAR(20),
  
  CONSTRAINT fk_shipments_order
      FOREIGN KEY (order_id)
      REFERENCES orders(order_id)
);



-- =========================
-- Reviews
-- ========================= 

CREATE TABLE reviews (
	review_id      INT PRIMARY KEY,		
	product_id     INT NOT NULL,		
	customer_id    INT NOT NULL, 	
	rating         INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
	review_text    VARCHAR(500), 
	review_date    DATE,
  
  CONSTRAINT fk_reviews_product
      FOREIGN KEY (product_id)
      REFERENCES products(product_id),

  CONSTRAINT fk_reviews_customer
      FOREIGN KEY (customer_id)
      REFERENCES customers(customer_id)
);


