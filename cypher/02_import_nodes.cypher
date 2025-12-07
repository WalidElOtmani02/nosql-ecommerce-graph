// Loading CSV files and creating nodes.


// CUSTOMERS
LOAD CSV WITH HEADERS FROM 'file:///olist_customers_dataset.csv' AS row
CREATE (:Customer {
  customer_id: row.customer_id,
  customer_unique_id: row.customer_unique_id,
  customer_zip_code_prefix: row.customer_zip_code_prefix,
  customer_city: row.customer_city,
  customer_state: row.customer_state
});

// ORDERS
LOAD CSV WITH HEADERS FROM 'file:///olist_orders_dataset.csv' AS row
CREATE (:Order {
  order_id: row.order_id,
  customer_id: row.customer_id,
  order_status: row.order_status,
  order_purchase_timestamp: row.order_purchase_timestamp,
  order_approved_at: row.order_approved_at,
  order_delivered_carrier_date: row.order_delivered_carrier_date,
  order_delivered_customer_date: row.order_delivered_customer_date,
  order_estimated_delivery_date: row.order_estimated_delivery_date
});

// PRODUCTS
LOAD CSV WITH HEADERS FROM 'file:///olist_products_dataset.csv' AS row
CREATE (:Product {
  product_id: row.product_id,
  product_category_name: row.product_category_name,
  product_name_lenght: row.product_name_lenght,
  product_description_lenght: row.product_description_lenght,
  product_photos_qty: row.product_photos_qty,
  product_weight_g: row.product_weight_g,
  product_length_cm: row.product_length_cm,
  product_height_cm: row.product_height_cm,
  product_width_cm: row.product_width_cm
});

// SELLERS
LOAD CSV WITH HEADERS FROM 'file:///olist_sellers_dataset.csv' AS row
CREATE (:Seller {
  seller_id: row.seller_id,
  seller_zip_code_prefix: row.seller_zip_code_prefix,
  seller_city: row.seller_city,
  seller_state: row.seller_state
});

// ORDER ITEMS
LOAD CSV WITH HEADERS FROM 'file:///olist_order_items_dataset.csv' AS row
CREATE (:OrderItem {
  order_id: row.order_id,
  order_item_id: row.order_item_id,
  product_id: row.product_id,
  seller_id: row.seller_id,
  shipping_limit_date: row.shipping_limit_date,
  price: row.price,
  freight_value: row.freight_value
});

// PAYMENTS
LOAD CSV WITH HEADERS FROM 'file:///olist_order_payments_dataset.csv' AS row
CREATE (:Payment {
  order_id: row.order_id,
  payment_sequential: row.payment_sequential,
  payment_type: row.payment_type,
  payment_installments: row.payment_installments,
  payment_value: row.payment_value
});

// REVIEWS
LOAD CSV WITH HEADERS FROM 'file:///olist_order_reviews_dataset.csv' AS row
CREATE (:Review {
  review_id: row.review_id,
  order_id: row.order_id,
  review_score: row.review_score,
  review_comment_title: row.review_comment_title,
  review_comment_message: row.review_comment_message,
  review_creation_date: row.review_creation_date,
  review_answer_timestamp: row.review_answer_timestamp
});

// Geolocation
LOAD CSV WITH HEADERS FROM 'file:///olist_geolocation_dataset.csv' AS row
MERGE (z:ZipCode {zip_code_prefix: row.geolocation_zip_code_prefix})
ON CREATE SET
  z.city = row.geolocation_city,
  z.state = row.geolocation_state,
  z.lat = row.geolocation_lat,
  z.lng = row.geolocation_lng;

// Product Category 
LOAD CSV WITH HEADERS FROM 'file:///olist_products_dataset.csv' AS row
WITH row WHERE row.product_category_name IS NOT NULL AND row.product_category_name <> ''
MERGE (:Category {category_name: row.product_category_name});