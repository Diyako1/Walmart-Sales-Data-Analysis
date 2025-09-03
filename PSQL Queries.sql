--------------------------------------------------------------
-- Walmart Business Intelligence Analysis - PostgreSQL Queries
-- Original Author: [Original Author]
-- Maintainer: Diyako Gilibagu
-- Purpose: PostgreSQL queries for Walmart sales analysis
--------------------------------------------------------------

-- Basic exploration queries
SELECT * FROM walmart;

-- DROP TABLE walmart;

-- ================================================
-- 1. Basic Data Checks
--    Record counts and structure
-- ================================================

-- total record count for dataset overview
SELECT COUNT(*) FROM walmart;

-- payment method distribution - customer payment preferences
SELECT 
    payment_method,
    COUNT(*) AS transaction_count
FROM walmart
GROUP BY payment_method;

-- branch count - how many locations we're analyzing
SELECT COUNT(DISTINCT branch) FROM walmart;

-- data quality check - minimum quantity
SELECT MIN(quantity) FROM walmart;

-- ================================================
-- 2. Business Analysis
--    Payment, rating, and performance queries
-- ================================================

-- Payment method breakdown
-- transaction count and item volume by payment type
SELECT 
    payment_method,
    COUNT(*) AS no_payments,
    SUM(quantity) AS no_qty_sold
FROM walmart
GROUP BY payment_method;

-- Items sold by payment method
-- just the quantities, no transaction counts
SELECT 
    payment_method,
    SUM(quantity) AS no_qty_sold
FROM walmart
GROUP BY payment_method;

-- Top payment method per branch
-- which payment type wins at each location
WITH payment_preferences AS (
    SELECT 
        branch,
        payment_method,
        COUNT(*) AS total_trans,
        RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS rank
    FROM walmart
    GROUP BY branch, payment_method
)
SELECT 
    branch,
    payment_method AS preferred_payment_method
FROM payment_preferences
WHERE rank = 1;

-- Ratings by city and category
-- customer satisfaction breakdown
SELECT 
    city,
    category,
    MIN(rating) AS min_rating,
    MAX(rating) AS max_rating,
    AVG(rating) AS avg_rating
FROM walmart
GROUP BY city, category;

-- Best category per branch
-- highest rated products by location
SELECT branch, category, avg_rating
FROM (
    SELECT 
        branch,
        category,
        AVG(rating) AS avg_rating,
        RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) AS rank
    FROM walmart
    GROUP BY branch, category
) AS ranked_categories
WHERE rank = 1;

-- Sales by time of day
-- morning vs afternoon vs evening
SELECT
    branch,
    CASE 
        WHEN EXTRACT(HOUR FROM(time::time)) < 12 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM(time::time)) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS day_time,
    COUNT(*) AS invoice_count
FROM walmart
GROUP BY branch, day_time
ORDER BY branch, invoice_count DESC;

-- Busiest day per branch
-- peak days for each location
SELECT branch, day_name, no_transactions
FROM (
    SELECT 
        branch,
        TO_CHAR(TO_DATE(date, 'DD/MM/YY'), 'Day') AS day_name,
        COUNT(*) AS no_transactions,
        RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS rank
    FROM walmart
    GROUP BY branch, TO_CHAR(TO_DATE(date, 'DD/MM/YY'), 'Day')
) AS daily_activity
WHERE rank = 1;

-- Profit by category
-- which products make the most money
SELECT 
    category,
    SUM(total) AS total_revenue,
    SUM(total * profit_margin) AS profit
FROM walmart
GROUP BY category
ORDER BY profit DESC;

-- ================================================
-- 3. Revenue Trends
--    Year-over-year comparison to find declining branches
-- ================================================

-- date format verification for year extraction
SELECT 
    date,
    EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) AS formatted_year
FROM walmart
LIMIT 5;

-- Top 5 branches with biggest revenue drops (2022 vs 2023)
-- find struggling locations
WITH revenue_2022 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2022
    GROUP BY branch
),
revenue_2023 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2023
    GROUP BY branch
)
SELECT 
    r2022.branch,
    r2022.revenue AS last_year_revenue,
    r2023.revenue AS current_year_revenue,
    ROUND(
        ((r2022.revenue - r2023.revenue)::numeric / r2022.revenue::numeric) * 100, 
        2
    ) AS revenue_decrease_ratio
FROM revenue_2022 AS r2022
JOIN revenue_2023 AS r2023 ON r2022.branch = r2023.branch
WHERE r2022.revenue > r2023.revenue
ORDER BY revenue_decrease_ratio DESC
LIMIT 5;