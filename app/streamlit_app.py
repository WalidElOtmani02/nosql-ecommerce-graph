import streamlit as st
from neo4j import GraphDatabase
import pandas as pd
import os

# --- Neo4j connection setup ---
URI = "bolt://localhost:7687"
USER = "neo4j"
PASSWORD = "password"

# inside streamlit_app.py
driver = GraphDatabase.driver(
    os.environ.get("NEO4J_URI", "bolt://neo4j:7687"),
    auth=(
        os.environ.get("NEO4J_USER", "neo4j"),
        os.environ.get("NEO4J_PASSWORD", "password"),
    ),
)

# --- Helper functions to query---

def run_query(query, params=None):
    """Run a Cypher query and return list of dicts."""
    with driver.session() as session:
        result = session.run(query, params or {})
        return [record.data() for record in result]

def run_query_df(query, params=None):
    """Run a Cypher query and return a pandas DataFrame."""
    return pd.DataFrame(run_query(query, params))


# --- Category mapping (Portuguese -> English labels) ---

CATEGORY_LABELS = {
    "beleza_saude": "Health & Beauty",
    "esporte_lazer": "Sports & Leisure",
    "informatica_acessorios": "Electronics & Accessories",
    "pet_shop": "Pet Shop",
}

def pretty_category(cat: str) -> str:
    """Map internal category name to a readable English label."""
    return CATEGORY_LABELS.get(cat, cat)


# --- Placeholder images per category (fallback only, in case the category isn't included in the subset) ---

CATEGORY_IMAGES = {
    "beleza_saude": "https://placehold.co/600x400?text=Health+%26+Beauty",
    "esporte_lazer": "https://placehold.co/600x400?text=Sports+%26+Leisure",
    "informatica_acessorios": "https://placehold.co/600x400?text=Electronics",
    "pet_shop": "https://placehold.co/600x400?text=Pet+Shop",
}

# --- mapping images to the products names ---

PRODUCT_IMAGES_BY_NAME = {
    # beleza_saude
    "Aloe Vera Skincare Set": "images/skincare.jpg",
    "Vitamin C Serum": "images/serum.jpg",
    "Herbal Hair Growth Oil": "images/hairgrowth.jpg",
    "Natural Lip Balm": "images/lipbalm.jpg",
    "Organic Face Mask": "images/facemask.jpg",
    "Essential Oils Collection": "images/oilscollection.jpg",

    # esporte_lazer
    "Dumbell Set": "images/dumbellset.jpg",
    "Treadmill": "images/treadmill.jpg",
    "Yoga Mat": "images/yogamat.jpg",
    "Basketball": "images/basketball.jpg",
    "Boxing Gloves": "images/boxinggloves.jpg",
    "Resistance Band": "images/resistancebands.jpg",

    # informatica_acessorios
    "Wireless Mouse": "images/mouse.jpg",
    "Mechanical Keyboard": "images/keyboard.jpg",
    "USB-C Hub": "images/usbc.jpg",
    "Laptop Stand": "images/laptopstand.jpg",
    "External Hard Drive": "images/harddrive.jpg",
    "Webcam": "images/webcam.jpg",

    # pet_shop
    "Dog Chew Toy": "images/dogtoy.jpg",
    "Cat Scratching Post": "images/catpost.jpg",
    "Pet Grooming Kit": "images/petset.jpg",
    "Aquarium Decor Set": "images/aquariumset.jpg",
    "Bird Cage Accessories": "images/nirdaccessories.jpg",
    "Pet Bed": "images/petbed.jpg",
}

def get_product_image(name: str, category: str) -> str:
    """
    Return the local product image if we have one for this name,
    otherwise fall back to a category placeholder, then generic.
    """
    if name in PRODUCT_IMAGES_BY_NAME:
        return PRODUCT_IMAGES_BY_NAME[name]
    return CATEGORY_IMAGES.get(category, "https://placehold.co/600x400?text=Product")


# --- Function to get the recommandable products  ---

def get_recommendable_products(limit: int = 200) -> pd.DataFrame:
    """
    Return products that belong to the demo subset (in_demo = true)
    AND have at least one co-purchased product (i.e. real recommendations).
    """
    query = """
    MATCH (p:Product)
    WHERE p.in_demo = true

    MATCH (p)<-[:CONTAINS_PRODUCT]-(oi:OrderItem)
          <-[:HAS_ITEM]-(o:Order)
    MATCH (o)-[:HAS_ITEM]->(otherOi:OrderItem)
          -[:CONTAINS_PRODUCT]->(other:Product)
    WHERE other.product_id <> p.product_id
      AND other.in_demo = true

    WITH p, COUNT(DISTINCT other) AS numRecommended
    WHERE numRecommended > 0
    RETURN 
      p.product_id AS id,
      p.display_name AS name,
      p.product_category_name AS category,
      p.demo_price AS price,
      numRecommended
    ORDER BY numRecommended DESC
    LIMIT $limit
    """
    return run_query_df(query, {"limit": limit})


def get_product_details(product_id: str):
    """Return a single product's details as a dict (or None)."""
    query = """
    MATCH (p:Product {product_id: $id})
    RETURN 
      p.product_id AS id,
      p.display_name AS name,
      p.product_category_name AS category,
      p.demo_price AS price
    """
    rows = run_query(query, {"id": product_id})
    return rows[0] if rows else None

# --- Function to get recommended products based on co-purchase patterns ---
def recommend_products(product_id: str, limit: int = 3) -> pd.DataFrame:
    """
    Given a product_id, return up to 'limit' products that are most frequently
    bought together with it (co-purchases), restricted to the demo subset.
    """
    query = """
    MATCH (p:Product {product_id: $productId})
    WHERE p.in_demo = true
    
    MATCH (p)<-[:CONTAINS_PRODUCT]-(oi:OrderItem)
          <-[:HAS_ITEM]-(o:Order)
    MATCH (o)-[:HAS_ITEM]->(otherOi:OrderItem)
          -[:CONTAINS_PRODUCT]->(other:Product)
    WHERE other.product_id <> p.product_id
      AND other.in_demo = true

    WITH other, COUNT(DISTINCT o) AS coPurchaseCount
    RETURN 
      other.product_id AS id,
      other.display_name AS name,
      other.product_category_name AS category,
      other.demo_price AS price,
      coPurchaseCount
    ORDER BY coPurchaseCount DESC
    LIMIT $limit
    """
    return run_query_df(query, {"productId": product_id, "limit": limit})


# --- Session state setup (selected product + cart) ---

if "selected_product_id" not in st.session_state:
    st.session_state.selected_product_id = None

if "cart" not in st.session_state:
    st.session_state.cart = []  # list of dicts: {id, name, price, category}


def add_to_cart(product: dict):
    """Add a product dict to the cart if not already there."""
    if not any(item["id"] == product["id"] for item in st.session_state.cart):
        st.session_state.cart.append(product)


def cart_total_price() -> float:
    return sum(item["price"] for item in st.session_state.cart)

# User Interface with Streamlit
# --- Streamlit UI ---

st.set_page_config(page_title="NoSQL E-Commerce Store", layout="wide")

st.title("NoSQL Graph-based E-commerce Store")
st.write(
    "Browse products, add them to your cart, and see graph-based recommendations "
    "for items frequently bought together."
)

# Layout: left = catalog, right = details + recommendations + cart
left_col, right_col = st.columns([2, 1], gap="large")

# --- LEFT: Product catalog ---

with left_col:
    st.subheader("Product Catalog")

    products_df = get_recommendable_products(limit=200)

    # keep only one row per product name (e.g. a single 'External Hard Drive')
    if not products_df.empty:
        products_df = (
            products_df
            .sort_values("numRecommended", ascending=False)  # prioritize popular
            .drop_duplicates(subset=["name"])                # dedupe by name
        )

    if products_df.empty:
        st.error("No recommendable products found. Check your data or in_demo flag.")
    else:
        for _, row in products_df.iterrows():
            with st.container():
                cols = st.columns([1, 3, 1])
                with cols[0]:
                    st.image(
                        get_product_image(row["name"], row["category"]),
                        use_container_width=True,
                    )
                with cols[1]:
                    st.markdown(f"**{row['name']}**")
                    st.caption(pretty_category(row["category"]))
                    st.write(f"{row['price']} €")
                    st.write(f"Recommended with {row['numRecommended']} other products")
                with cols[2]:
                    if st.button("View", key=f"view_{row['id']}"):
                        st.session_state.selected_product_id = row["id"]


# --- RIGHT: Product details, recommendations, cart ---

with right_col:
    st.subheader("Product Details & Recommendations")

    selected = None
    if st.session_state.selected_product_id:
        selected = get_product_details(st.session_state.selected_product_id)

    if not selected:
        st.info("Select a product from the catalog to see details and recommendations.")
    else:
        # Product detail card
        st.markdown("### Selected product")
        st.image(
            get_product_image(selected["name"], selected["category"]),
            use_container_width=True,
        )
        st.markdown(f"**{selected['name']}**")
        st.caption(pretty_category(selected["category"]))
        st.write(f"**Price:** {selected['price']} €")

        if st.button("Add to cart", key=f"cart_{selected['id']}"):
            add_to_cart(selected)
            st.success("Added to cart!")

        # Recommendations
        st.markdown("### Recommended together")
        recs = recommend_products(selected["id"], limit=3)
        if recs.empty:
            st.write("No recommendations found for this product.")
        else:
            rec_cols = st.columns(len(recs))
            for col, (_, rec) in zip(rec_cols, recs.iterrows()):
                with col:
                    st.image(
                        get_product_image(rec["name"], rec["category"]),
                        use_container_width=True,
                    )
                    st.markdown(f"**{rec['name']}**")
                    st.caption(pretty_category(rec["category"]))
                    st.write(f"{rec['price']} €")
                    if st.button("Add to cart", key=f"rec_cart_{rec['id']}"):
                        add_to_cart(
                            {
                                "id": rec["id"],
                                "name": rec["name"],
                                "category": rec["category"],
                                "price": rec["price"],
                            }
                        )
                        st.success("Added to cart!")

    # Cart summary
    st.markdown("### Cart")
    if not st.session_state.cart:
        st.write("Your cart is empty.")
    else:
        for item in st.session_state.cart:
            st.write(
                f"- {item['name']} ({pretty_category(item['category'])}) – {item['price']} €"
            )
        st.write(f"**Total:** {cart_total_price():.2f} €")