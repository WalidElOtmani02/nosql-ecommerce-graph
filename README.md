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
├── app/
│   ├── Dockerfile
│   ├── requirements.txt 
│   ├── streamlit_app.py
│   
│
├── cypher/
│   ├── 01_schema.cypher
│   ├── 02_import_nodes.cypher
│   ├── 03_import_relationships.cypher
│   ├── 04_demo_setup.cypher
│   └── 05_analytics_queries.cypher
│
├── images/
│   ├── aquariumset.jpg
│   ├── basketball.jpg
│   ├── boxinggloves.jpg
│   ├── catpost.jpg
│   ├── dogtoy.jpg
│   ├── dumbellset.jpg
│   ├── facemask.jpg
│   ├── hairgrowth.jpg
│   ├── harddrive.jpg
│   ├── keyboard.jpg
│   ├── laptopstand.jpg
│   ├── lipbalm.jpg
│   ├── mouse.jpg
│   ├── nirdaccessories.jpg
│   ├── oilscollection.jpg
│   ├── petbed.jpg
│   ├── petset.jpg
│   ├── resistancebands.jpg
│   ├── serum.jpg
│   ├── skincare.jpg
│   ├── treadmill.jpg
│   ├── usbc.jpg
│   ├── webcam.jpg
│   └── yogamat.jpg
│   
│
├── import/
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
├── notebooks/
│   ├── 01_neo4j_crud.ipynb
│   ├── 02_products_enrichment.ipynb
│   └── 03_recommendation_system.ipynb
│
├── docker-compose.yml
├── LICENSE
└── README.md
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
 <li>05_analytics_queries.cypher (optional, just for data exploration)</li>
 </ol>
4. Start the streamlit app: streamlit run streamlit_app.py (Make sure you're in /app folder)

## How the Recommendation System Works
The recommendation engine is implemented using Cypher and identifies products frequently bought together based on shared order. For a given product, the system finds all orders containing it and counts how often other products co-occur in the same baskets. Those with the highest co-purchase counts are then recommended.
