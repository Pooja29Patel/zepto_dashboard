-- ==========================================================
-- 🛒 Zepto Dataset SQL Case Study
-- Objective: Explore, clean, and analyze product data
-- ==========================================================

-- ----------------------------------------------------------
-- 1. Drop & Recreate Table
-- ----------------------------------------------------------
DROP TABLE IF EXISTS zepto;

CREATE TABLE zepto (
    sku_id SERIAL PRIMARY KEY,
    category VARCHAR(120),
    name VARCHAR(150) NOT NULL,
    mrp NUMERIC(8,2),
    discountPercent NUMERIC(5,2),
    availableQuantity INTEGER,
    discountedSellingPrice NUMERIC(8,2),
    weightInGms INTEGER,
    outOfStock BOOLEAN,
    quantity INTEGER
);

-- (Data loading from your source)

-- ==========================================================
-- 📌 SECTION A: DATA EXPLORATION
-- ==========================================================

-- A1. Count total rows
SELECT COUNT(*) AS total_rows FROM zepto;

-- A2. Sample data (randomized)
SELECT * FROM zepto
ORDER BY RANDOM()
LIMIT 10;

-- A3. Null value counts per column
SELECT 
    COUNT(*) FILTER (WHERE category IS NULL) AS null_category,
    COUNT(*) FILTER (WHERE name IS NULL) AS null_name,
    COUNT(*) FILTER (WHERE mrp IS NULL) AS null_mrp,
    COUNT(*) FILTER (WHERE discountPercent IS NULL) AS null_discountPercent,
    COUNT(*) FILTER (WHERE discountedSellingPrice IS NULL) AS null_discountedSellingPrice,
    COUNT(*) FILTER (WHERE weightInGms IS NULL) AS null_weightInGms,
    COUNT(*) FILTER (WHERE availableQuantity IS NULL) AS null_availableQuantity,
    COUNT(*) FILTER (WHERE outOfStock IS NULL) AS null_outOfStock,
    COUNT(*) FILTER (WHERE quantity IS NULL) AS null_quantity
FROM zepto;

-- A4. Unique product categories
SELECT DISTINCT category
FROM zepto
ORDER BY category;

-- A5. Stock status summary
SELECT outOfStock, COUNT(*) AS product_count
FROM zepto
GROUP BY outOfStock;

-- A6. Duplicate product names (with category check)
SELECT name, category, COUNT(*) AS sku_count
FROM zepto
GROUP BY name, category
HAVING COUNT(*) > 1
ORDER BY sku_count DESC;

-- ==========================================================
-- 📌 SECTION B: DATA CLEANING
-- ==========================================================

-- B1. Identify invalid pricing (zero values)
SELECT * FROM zepto
WHERE mrp = 0 OR discountedSellingPrice = 0;

-- B2. Remove invalid rows (mrp = 0)
DELETE FROM zepto
WHERE mrp = 0;

-- B3. Convert paise → rupees (if data is in paise)
UPDATE zepto
SET mrp = mrp / 100.0,
    discountedSellingPrice = discountedSellingPrice / 100.0;

-- B4. Verify updated prices
SELECT sku_id, mrp, discountedSellingPrice
FROM zepto
LIMIT 10;

-- ==========================================================
-- 📌 SECTION C: DATA ANALYSIS
-- ==========================================================

-- Q1. Top 10 products with highest discount %
SELECT name, mrp, discountPercent
FROM zepto
ORDER BY discountPercent DESC
LIMIT 10;

-- Q2. Products with high MRP (> 300) but Out of Stock
SELECT name, mrp
FROM zepto
WHERE outOfStock = TRUE AND mrp > 300
ORDER BY mrp DESC;

-- Q3. Estimated revenue per category
SELECT category,
       SUM(discountedSellingPrice * availableQuantity) AS total_revenue
FROM zepto
GROUP BY category
ORDER BY total_revenue DESC;

-- Q4. Premium products (MRP > 500, low discount < 10%)
SELECT name, mrp, discountPercent
FROM zepto
WHERE mrp > 500 AND discountPercent < 10
ORDER BY mrp DESC, discountPercent DESC;

-- Q5. Top 5 categories by average discount
SELECT category,
       ROUND(AVG(discountPercent),2) AS avg_discount
FROM zepto
GROUP BY category
ORDER BY avg_discount DESC
LIMIT 5;

-- Q6. Price per gram (for items ≥ 100g)
SELECT name, weightInGms, discountedSellingPrice,
       ROUND(discountedSellingPrice/weightInGms,2) AS price_per_gram
FROM zepto
WHERE weightInGms >= 100
ORDER BY price_per_gram ASC;   -- Best value first

-- Q7. Weight category segmentation
SELECT name, weightInGms,
       CASE 
         WHEN weightInGms < 1000 THEN 'Low'
         WHEN weightInGms < 5000 THEN 'Medium'
         ELSE 'Bulk'
       END AS weight_category
FROM zepto;

-- Q8. Total inventory weight per category
SELECT category,
       SUM(weightInGms * availableQuantity) AS total_weight
FROM zepto
GROUP BY category
ORDER BY total_weight DESC;

-- ==========================================================
-- 📌 SECTION D: ADVANCED INSIGHTS
-- ==========================================================

-- D1. Margin % (how much customer saves vs MRP)
SELECT name, category,
       mrp, discountedSellingPrice,
       ROUND(((mrp - discountedSellingPrice)/mrp)*100,2) AS margin_percent
FROM zepto
ORDER BY margin_percent DESC
LIMIT 10;

-- D2. Stock value (total worth of available inventory)
SELECT category, name,
       availableQuantity,
       discountedSellingPrice,
       (availableQuantity * discountedSellingPrice) AS stock_value
FROM zepto
ORDER BY stock_value DESC
LIMIT 10;

-- D3. Category revenue contribution %
WITH revenue_cte AS (
    SELECT category,
           SUM(discountedSellingPrice * availableQuantity) AS revenue
    FROM zepto
    GROUP BY category
)
SELECT category, revenue,
       ROUND(100.0 * revenue / SUM(revenue) OVER (),2) AS pct_contribution
FROM revenue_cte
ORDER BY pct_contribution DESC;

-- D4. Lost revenue due to out-of-stock items
SELECT category,
       SUM(CASE WHEN outOfStock = FALSE THEN discountedSellingPrice * availableQuantity ELSE 0 END) AS in_stock_value,
       SUM(CASE WHEN outOfStock = TRUE THEN discountedSellingPrice * availableQuantity ELSE 0 END) AS lost_revenue
FROM zepto
GROUP BY category
ORDER BY lost_revenue DESC;

-- D5. Weight statistics per category
SELECT category,
       ROUND(AVG(weightInGms),2) AS avg_weight,
       MIN(weightInGms) AS min_weight,
       MAX(weightInGms) AS max_weight
FROM zepto
GROUP BY category
ORDER BY avg_weight DESC;

-- D6. Correlation between MRP and discount %
SELECT corr(mrp, discountPercent) AS corr_mrp_discount
FROM zepto;

-- ==========================================================
-- 📊 SECTION E: KPI SUMMARY DASHBOARD
-- ==========================================================
-- This gives one quick view of key business metrics.

WITH 
revenue_cte AS (
    SELECT SUM(discountedSellingPrice * availableQuantity) AS total_revenue
    FROM zepto
),
discount_cte AS (
    SELECT ROUND(AVG(discountPercent),2) AS avg_discount
    FROM zepto
),
stock_cte AS (
    SELECT 
      ROUND(100.0 * COUNT(*) FILTER (WHERE outOfStock = TRUE) / COUNT(*),2) AS pct_out_of_stock
    FROM zepto
),
top_category_cte AS (
    SELECT category, 
           SUM(discountedSellingPrice * availableQuantity) AS revenue,
           RANK() OVER (ORDER BY SUM(discountedSellingPrice * availableQuantity) DESC) AS rnk
    FROM zepto
    GROUP BY category
)
SELECT 
    r.total_revenue,
    d.avg_discount,
    s.pct_out_of_stock,
    t.category AS top_category,
    t.revenue AS top_category_revenue
FROM revenue_cte r
CROSS JOIN discount_cte d
CROSS JOIN stock_cte s
JOIN top_category_cte t ON t.rnk = 1;

-- ==========================================================
-- ✅ END OF ANALYSIS
-- ==========================================================
