# NoSQL - Graph Database for a Brazilian E-Commerce Store
## Project Overview
This project implements and end-to-end NoSQL E-commerce system using Neo4j as a graph database.
The goal is to import the data, model the nodes and relationships and build a practical recommendation engine for an e-commerce store based on co-purchased items.

## Technologies Used
- **Neo4j Graph Database** - used to store and query the nodes and relationships
- **Cypher Query Language** – for importing data, modeling the graph, performing analytics, and generating recommendations.
- **Docker Compose** – provides an isolated, reproducible Neo4j environment that runs on any machine.
- **Python (neo4j-driver)** – used for CRUD operations, data enrichment, and connecting the recommendation engine to the web interface.
- **Jupyter Notebooks** – for experimentation, analysis, and step-by-step implementation of queries.
- **Streamlit** – the frontend used to build a simple E-commerce interface that displays products and recommendations.
- **Git & GitHub** – for version control and sharing the project.

## Folder Structure
```
nosql-ecommerce-graph/
│
├── cypher/                          # All Cypher scripts (schema, imports, analytics)
│   ├── 01_schema.cypher             # Constraints and indexes
│   ├── 02_import_nodes.cypher       # Node creation (CSV → Neo4j)
│   ├── 03_import_relationships.cypher # Relationship creation
│   ├── 04_demo_setup.cypher         # Demo category filtering & enrichment flags
│   └── 05_analytics_queries.cypher  # Analytical queries used in the report
│
├── images/                          # Product images for Streamlit store
│   ├── aquariumset.jpg
│   ├── basketball.jpg
│   ├── facemask.jpg
│   ├── hairgrowth.jpg
│   ├── harddrive.jpg
│   ├── keyboard.jpg
│   ├── laptopstand.jpg
│   ├── lipbalm.jpg
│   ├── mouse.jpg
│   ├── oilscollection.jpg
│   ├── petbed.jpg
│   ├── skincare.jpg
│   ├── usbc.jpg
│   └── yogamat.jpg
│
├── import/                          # CSV dataset files (for Neo4j LOAD CSV)
│   ├── olist_customers_dataset.csv
│   ├── olist_geolocation_dataset.csv
│   ├── olist_order_items_dataset.csv
│   ├── olist_order_payments_dataset.csv
│   ├── olist_order_reviews_dataset.csv
│   ├── olist_orders_dataset.csv
│   ├── olist_products_dataset.csv
│   ├── olist_sellers_dataset.csv
│   └── product_category_name_translation.csv
│
├── notebooks/                       # Jupyter notebooks (CRUD, enrichment, recommendations)
│   ├── 01_neo4j_crud.ipynb
│   ├── 02_products_enrichment.ipynb
│   └── 03_recommendation_system.ipynb
│
├── app.py                           # Streamlit E-commerce demo (Frontend + Recommendations)
├── docker-compose.yml               # Local Neo4j instance (via Docker)
└── README.md                        # Project documentation
```

## How to Run the Project:
1. Start Neo4j with Docker: docker compose up -d
2. Opeb Neo4j Browser: http://localhost:7474; Login: neo4j / password
3. Run Cypher scripts in this order:
<ol>
 <li>01_schema.cypher</li>
 <li>02_import_nodes.cypher</li>
 <li>03_import_relationships.cypher</li>
 <li>04_demo_setup.cypher</li>
 <li>05_analytics_queries.cypher (optional, just for data explory)</li>
 </ol>
4. Start the streamlit app: streamlit run app.py

## How the Recommendation System Works
The recommendation engine is implemented using Cypher and identifies products frequently bought together based on shared order. For a given product, the system finds all orders containing it and counts how often other products co-occur in the same baskets. Those with the highest co-purchase counts are then recommended.
