// Creating relationshipsbetween existing nodes.

// Customer -> Order
// (:Customer)-[:PLACED]->(:Order)
MATCH (c:Customer), (o:Order)
WHERE c.customer_id = o.customer_id
MERGE (c)-[:PLACED]->(o);



// Order -> OrderItem
// (:Order)-[:HAS_ITEM]->(:OrderItem)
MATCH (o:Order), (oi:OrderItem)
WHERE o.order_id = oi.order_id
MERGE (o)-[:HAS_ITEM]->(oi);



// OrderItem -> Product
// (:OrderItem)-[:CONTAINS_PRODUCT]->(:Product)
MATCH (oi:OrderItem), (p:Product)
WHERE oi.product_id = p.product_id
MERGE (oi)-[:CONTAINS_PRODUCT]->(p);



// OrderItem -> Seller
// (:OrderItem)-[:SOLD_BY]->(:Seller)
MATCH (oi:OrderItem), (s:Seller)
WHERE oi.seller_id = s.seller_id
MERGE (oi)-[:SOLD_BY]->(s);



// Order -> Payment
// (:Order)-[:HAS_PAYMENT]->(:Payment)
MATCH (o:Order), (pay:Payment)
WHERE o.order_id = pay.order_id
MERGE (o)-[:HAS_PAYMENT]->(pay);


// Order -> Review
// (:Order)-[:HAS_REVIEW]->(:Review)
MATCH (o:Order), (r:Review)
WHERE o.order_id = r.order_id
MERGE (o)-[:HAS_REVIEW]->(r);

// Seller -> Location
// (:Seller)-[:LOCATED_IN]->(:ZipCode)
MATCH (s:Seller), (z:ZipCode)
WHERE s.seller_zip_code_prefix = z.zip_code_prefix
MERGE (s)-[:LOCATED_IN]->(z);

// Customer -> Location
// (:Customer)-[:LOCATED_IN]->(:ZipCode)
MATCH (c:Customer), (z:ZipCode)
WHERE c.customer_zip_code_prefix = z.zip_code_prefix
MERGE (c)-[:LOCATED_IN]->(z);