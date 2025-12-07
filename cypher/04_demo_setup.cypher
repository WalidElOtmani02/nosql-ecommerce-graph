// Since we have too many product categories, we will create a subset of categories that we will use to test the recommendation system. 
MATCH (p:Product)
WHERE p.product_category_name IN [
  'beleza_saude', // Beauty and Health
  'esporte_lazer', // Sport leisure
  'informatica_acessorios', // IT accessories
  'pet_shop' // pets accessories
]
SET p.in_demo = true;

// We chose the 4 categories because they are relevant examples of a real world Ecom Store. 
// When testing, we will use  WHERE p.in_demo = true as a condition so we can limit the dataset in the 4 chosen categories.