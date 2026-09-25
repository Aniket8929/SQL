-- =========================================================
-- APPLE RETAIL SALES — SQL PRACTICE SHEET
-- PostgreSQL | Beginner → Intermediate
-- =========================================================


-- =========================================================
-- SECTION 1: BASIC SQL
-- =========================================================

-- Q1. Total Sales Transactions
SELECT COUNT(*) AS total_transactions
FROM sales;


-- Q2. Total Units Sold
SELECT SUM(quantity) AS total_units_sold
FROM sales;


-- Q3. Total Products
SELECT COUNT(*) AS total_products
FROM products;


-- Q4. Total Categories
SELECT COUNT(*) AS total_categories
FROM category;


-- Q5. Total Stores
SELECT COUNT(*) AS total_stores
FROM stores;


-- Q6. Total Countries
SELECT COUNT(DISTINCT country) AS total_countries
FROM stores;


-- Q7. Total Cities
SELECT COUNT(DISTINCT city) AS total_cities
FROM stores;


-- Q8. List All Countries
SELECT DISTINCT country
FROM stores
ORDER BY country;


-- Q9. List All Repair Statuses
SELECT DISTINCT repair_status
FROM warranty
ORDER BY repair_status;


-- Q10. Highest Product Price
SELECT MAX(price) AS highest_product_price
FROM products;


-- Q11. Lowest Product Price
SELECT MIN(price) AS lowest_product_price
FROM products;


-- Q12. Average Product Price
SELECT ROUND(AVG(price), 2) AS average_product_price
FROM products;


-- Q13. Total Warranty Claims
SELECT COUNT(*) AS total_warranty_claims
FROM warranty;





-- Q18. Sales Transactions With More Than 5 Units
SELECT
    sale_id,
    sale_date,
    product_id,
    quantity
FROM sales
WHERE quantity > 5
ORDER BY quantity DESC;


-- =========================================================
-- SECTION 2: GROUP BY
-- =========================================================

-- Q19. Store Count by Country
SELECT
    country,
    COUNT(*) AS store_count
FROM stores
GROUP BY country
ORDER BY store_count DESC;


-- Q20. Store Count by City
SELECT
    city,
    COUNT(*) AS store_count
FROM stores
GROUP BY city
ORDER BY store_count DESC;


-- Q21. Warranty Claims by Repair Status
SELECT
    repair_status,
    COUNT(*) AS claim_count
FROM warranty
GROUP BY repair_status
ORDER BY claim_count DESC;


-- Q22. Product Count by Category
SELECT
    c.category_name,
    COUNT(p.product_id) AS product_count
FROM category c
INNER JOIN products p
    ON c.category_id = p.category_id
GROUP BY c.category_name
ORDER BY product_count DESC;


-- Q23. Units Sold by Product
SELECT
    p.product_id,
    p.product_name,
    SUM(s.quantity) AS total_units_sold
FROM sales s
INNER JOIN products p
    ON s.product_id = p.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_units_sold DESC;


-- Q24. Units Sold by Category
SELECT
    c.category_name,
    SUM(s.quantity) AS total_units_sold
FROM sales s
INNER JOIN products p
    ON s.product_id = p.product_id
INNER JOIN category c
    ON p.category_id = c.category_id
GROUP BY c.category_name
ORDER BY total_units_sold DESC;


-- =========================================================
-- SECTION 3: REVENUE ANALYSIS
-- =========================================================

-- Q25. Revenue by Product
SELECT
    p.product_id,
    p.product_name,
    ROUND(SUM(s.quantity * p.price), 2) AS total_revenue
FROM sales s
INNER JOIN products p
ON s.product_id = p.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_revenue DESC;


-- Q26. Revenue by Category
SELECT
    c.category_name,
    ROUND(SUM(s.quantity * p.price), 2) AS total_revenue
FROM sales s
INNER JOIN products p
    ON s.product_id = p.product_id
INNER JOIN category c
    ON p.category_id = c.category_id
GROUP BY c.category_name
ORDER BY total_revenue DESC;


-- Q27. Revenue by Store
SELECT
    st.store_id,
    st.store_name,
    ROUND(SUM(s.quantity * p.price), 2) AS total_revenue
FROM sales s
INNER JOIN products p
    ON s.product_id = p.product_id
INNER JOIN stores st
    ON s.store_id = st.store_id
GROUP BY st.store_id, st.store_name
ORDER BY total_revenue DESC;


-- Q28. Revenue by Country
SELECT
    st.country,
    ROUND(SUM(s.quantity * p.price), 2) AS total_revenue
FROM sales s
INNER JOIN products p
    ON s.product_id = p.product_id
INNER JOIN stores st
    ON s.store_id = st.store_id
GROUP BY st.country
ORDER BY total_revenue DESC;


-- Q29. Average Product Price by Category
SELECT
    c.category_name,
    ROUND(AVG(p.price), 2) AS average_product_price
FROM category c
INNER JOIN products p
    ON c.category_id = p.category_id
GROUP BY c.category_name
ORDER BY average_product_price DESC;


-- =========================================================
-- SECTION 4: BUSINESS ANALYSIS
-- =========================================================

-- Q30. Highest Revenue Product
SELECT
    p.product_id,
    p.product_name,
    ROUND(SUM(s.quantity * p.price), 2) AS total_revenue
FROM sales s
INNER JOIN products p
    ON s.product_id = p.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_revenue DESC
LIMIT 1;


-- Q31. Highest Selling Product by Units
SELECT
    p.product_id,
    p.product_name,
    SUM(s.quantity) AS total_units_sold
FROM sales s
INNER JOIN products p
    ON s.product_id = p.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_units_sold DESC
LIMIT 1;


-- Q32. Top 5 Most Expensive Products
SELECT
    product_id,
    product_name,
    price
FROM products
ORDER BY price DESC
LIMIT 5;


-- Q33. Sales by Year
SELECT
    EXTRACT(YEAR FROM sale_date) AS sale_year,
    COUNT(*) AS total_transactions
FROM sales
GROUP BY EXTRACT(YEAR FROM sale_date)
ORDER BY sale_year;


-- Q34. Revenue by Year
SELECT
    EXTRACT(YEAR FROM s.sale_date) AS sale_year,
    ROUND(SUM(s.quantity * p.price), 2) AS total_revenue
FROM sales s
INNER JOIN products p
    ON s.product_id = p.product_id
GROUP BY EXTRACT(YEAR FROM s.sale_date)
ORDER BY sale_year;


-- Q35. Revenue by Month
SELECT
    DATE_TRUNC('month', s.sale_date)::DATE AS sale_month,
    ROUND(SUM(s.quantity * p.price), 2) AS total_revenue
FROM sales s
INNER JOIN products p
    ON s.product_id = p.product_id
GROUP BY DATE_TRUNC('month', s.sale_date)
ORDER BY sale_month;


-- =========================================================
-- SECTION 5: INTERMEDIATE SQL
-- =========================================================

-- Q36. Stores With More Than 5 Sales Transactions
SELECT
    st.store_id,
    st.store_name,
    COUNT(s.sale_id) AS total_transactions
FROM stores st
INNER JOIN sales s
    ON st.store_id = s.store_id
GROUP BY st.store_id, st.store_name
HAVING COUNT(s.sale_id) > 5
ORDER BY total_transactions DESC;


-- Q37. Categories Selling More Than 1000 Units
SELECT
    c.category_name,
    SUM(s.quantity) AS total_units_sold
FROM sales s
INNER JOIN products p
    ON s.product_id = p.product_id
INNER JOIN category c
    ON p.category_id = c.category_id
GROUP BY c.category_name
HAVING SUM(s.quantity) > 1000
ORDER BY total_units_sold DESC;


-- Q38. Products Generating More Than 100,000 Revenue
SELECT
    p.product_id,
    p.product_name,
    ROUND(SUM(s.quantity * p.price), 2) AS total_revenue
FROM sales s
INNER JOIN products p
    ON s.product_id = p.product_id
GROUP BY p.product_id, p.product_name
HAVING SUM(s.quantity * p.price) > 100000
ORDER BY total_revenue DESC;


-- Q39. Products With No Sales
SELECT
    p.product_id,
    p.product_name
FROM products p
LEFT JOIN sales s
    ON p.product_id = s.product_id
WHERE s.sale_id IS NULL
ORDER BY p.product_id;


-- Q40. Products With More Than 50 Warranty Claims
SELECT
    p.product_id,
    p.product_name,
    COUNT(w.claim_id) AS warranty_claims
FROM products p
INNER JOIN sales s
    ON p.product_id = s.product_id
INNER JOIN warranty w
    ON s.sale_id = w.sale_id
GROUP BY p.product_id, p.product_name
HAVING COUNT(w.claim_id) > 50
ORDER BY warranty_claims DESC;


