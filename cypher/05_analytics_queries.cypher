// To get familiar with Cypher and use it to analyse the data, these queries have been created and ran.
// The last query returns the products often bought together, given a product. It is the logic behind the recommendation system.

// 1. How many customers per state? (Basich Match + Aggregation)
MATCH
(c:Customer)
RETURN c.customer_state AS state, COUNT(*) AS customers
ORDER by customers DESC;


// 2. How many orders per status? (Filtering + Aggregation)
MATCH (o:Order)
RETURN o.order_status, COUNT(*) AS orders
ORDER BY orders DESC;

// 3. Average number of items per order: (Multi nodes + AVG function)
MATCH (o:Order)-[:HAS_ITEM]->(oi:OrderItem)
WITH o, COUNT(oi) AS items
RETURN AVG(items) AS average_items;

// 4. Total Revenue and items sold per Seller:
MATCH(oi:OrderItem)-[:SOLD_BY]->(s:Seller)
RETURN s.seller_id, SUM(toFloat(oi.price)) AS total_revenue, COUNT(oi) AS items_sold
ORDER BY total_revenue DESC;

// 5. Average review score per product category
MATCH(p:Product)<-[:CONTAINS_PRODUCT]-(oi:OrderItem)<-[:HAS_ITEM]-(o:Order)-[:HAS_REVIEW]->(r:Review)
WITH p.product_category_name AS category, r.review_score AS score
RETURN category, AVG(toFloat(score)) AS average_score;

// 6. Total amount spent by customer
MATCH (c:Customer)-[:PLACED]->(o:Order)-[:HAS_ITEM]->(oi:OrderItem)
WITH c.customer_id AS customer, oi.price AS price, oi.freight_value AS freight
RETURN customer, SUM(toFloat(price) + toFloat(freight)) AS total_price;

// 7. One-Time Buyers vs repeat customers
MATCH (c:Customer)-[:PLACED]->(o:Order)
WITH c.customer_unique_id AS shopper, COUNT(DISTINCT o) AS ordersCount
WITH
  CASE 
    WHEN ordersCount <= 1 THEN 'One-Time Buyer'
    WHEN ordersCount >= 2 AND ordersCount <= 4 THEN 'Repeat Customer'
    ELSE 'Loyal Customer'
  END AS segment
RETURN segment, COUNT(*) AS customersInSegment
ORDER BY customersInSegment DESC;

// 8. Products often bought together with a given product (Check /notebooks/03_recommendation_system.ipynb for implementation)
MATCH (p:Product {product_id: $productId})
MATCH (p)<-[:CONTAINS_PRODUCT]-(oi:OrderItem)
      <-[:HAS_ITEM]-(o:Order)
      -[:HAS_ITEM]->(otherOi:OrderItem)
      -[:CONTAINS_PRODUCT]->(otherP:Product)
WHERE otherP.product_id <> p.product_id
WITH otherP, COUNT(DISTINCT o) AS coPurchaseCount
RETURN 
    otherP.product_id AS recommendedProductID,
    otherP.product_category_name AS category,
    coPurchaseCount
ORDER BY coPurchaseCount DESC
LIMIT 10;