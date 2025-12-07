// Schema Definition for the E-comm graph database
// Please run Constraints before importing the data.

// Customers
CREATE CONSTRAINT customer_id_unique IF NOT EXISTS
FOR (c:Customer)
REQUIRE c.customer_id IS UNIQUE;


// Orders
CREATE CONSTRAINT order_id_unique IF NOT EXISTS
FOR (o:Order)
REQUIRE o.order_id IS UNIQUE;

// Products
CREATE CONSTRAINT product_id_unique IF NOT EXISTS
FOR (p:Product)
REQUIRE p.product_id IS UNIQUE;

// Sellers
CREATE CONSTRAINT seller_id_unique IF NOT EXISTS
FOR (s:Seller)
REQUIRE s.seller_id IS UNIQUE;

// Reviews
CREATE CONSTRAINT review_id_unique IF NOT EXISTS
FOR (r:Review)
REQUIRE r.review_id IS UNIQUE;

// Order items: composite key (order_id + order_item_id)
CREATE CONSTRAINT order_item_pk IF NOT EXISTS
FOR (oi:OrderItem)
REQUIRE (oi.order_id, oi.order_item_id) IS UNIQUE;

// Payments: composite key (order_id + payment_sequential)
CREATE CONSTRAINT payment_pk IF NOT EXISTS
FOR (p:Payment)
REQUIRE (p.order_id, p.payment_sequential) IS UNIQUE;

// Geolocation
CREATE CONSTRAINT zipcode_prefix_unique IF NOT EXISTS
FOR (z:ZipCode)
REQUIRE z.zip_code_prefix IS UNIQUE;

// Product Categories
CREATE CONSTRAINT category_name_unique IF NOT EXISTS
FOR (cat:Category)
REQUIRE cat.category_name IS UNIQUE;
