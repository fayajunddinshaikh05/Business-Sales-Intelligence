-- ─────────────────────────────────────────────
-- BUSINESS SALES INTELLIGENCE PROJECT
-- Advanced SQL Analysis Queries
-- Database: MySQL
-- ─────────────────────────────────────────────

USE sales_intelligence;

-- ─────────────────────────────────────────────
-- 1. View Sample Sales Records
-- ─────────────────────────────────────────────

SELECT *
FROM sales_data
LIMIT 10;

-- ─────────────────────────────────────────────
-- 2. Overall Revenue & Profit Summary
-- ─────────────────────────────────────────────

SELECT 
    ROUND(SUM(Revenue), 2) AS total_revenue,

    ROUND(SUM(Profit), 2) AS total_profit,

    ROUND(
        (SUM(Profit) / SUM(Revenue)) * 100,
        2
    ) AS profit_margin_percentage

FROM sales_data

WHERE Status = 'Delivered';

-- ─────────────────────────────────────────────
-- 3. Monthly Revenue Trends
-- ─────────────────────────────────────────────

SELECT
    MONTHNAME(Order_Date) AS month_name,

    MONTH(Order_Date) AS month_number,

    COUNT(*) AS total_orders,

    ROUND(
        SUM(Revenue),
        2
    ) AS total_revenue,

    ROUND(
        SUM(Profit),
        2
    ) AS total_profit,

    ROUND(
        AVG(Margin_Pct),
        1
    ) AS avg_margin_percentage

FROM sales_data

WHERE Status = 'Delivered'

GROUP BY month_name, month_number

ORDER BY month_number;

-- ─────────────────────────────────────────────
-- 4. Top 10 Customers by Revenue
-- ─────────────────────────────────────────────

SELECT
    Customer_Name,

    COUNT(*) AS total_orders,

    ROUND(
        SUM(Revenue),
        2
    ) AS total_revenue,

    ROUND(
        SUM(Profit),
        2
    ) AS total_profit,

    ROUND(
        AVG(Margin_Pct),
        1
    ) AS avg_margin_percentage

FROM sales_data

WHERE Status = 'Delivered'

GROUP BY Customer_Name

ORDER BY total_revenue DESC

LIMIT 10;

-- ─────────────────────────────────────────────
-- 5. Top Products by Revenue
-- ─────────────────────────────────────────────

SELECT 
    Product,

    SUM(Qty) AS total_quantity,

    ROUND(
        SUM(Revenue),
        2
    ) AS total_revenue,

    ROUND(
        SUM(Profit),
        2
    ) AS total_profit

FROM sales_data

WHERE Status = 'Delivered'

GROUP BY Product

ORDER BY total_revenue DESC

LIMIT 10;

-- ─────────────────────────────────────────────
-- 6. Category-wise Profit Margin
-- ─────────────────────────────────────────────

SELECT
    Category,

    COUNT(*) AS total_orders,

    ROUND(
        SUM(Revenue),
        2
    ) AS total_revenue,

    ROUND(
        SUM(Profit),
        2
    ) AS total_profit,

    ROUND(
        (SUM(Profit) / SUM(Revenue)) * 100,
        2
    ) AS profit_margin_percentage

FROM sales_data

WHERE Status = 'Delivered'

GROUP BY Category

ORDER BY total_revenue DESC;

-- ─────────────────────────────────────────────
-- 7. Region-wise Sales Performance
-- ─────────────────────────────────────────────

SELECT
    Region,

    COUNT(*) AS total_orders,

    ROUND(
        SUM(Revenue),
        2
    ) AS total_sales,

    ROUND(
        SUM(Profit),
        2
    ) AS total_profit,

    ROUND(
        AVG(Margin_Pct),
        1
    ) AS avg_margin_percentage

FROM sales_data

WHERE Status = 'Delivered'

GROUP BY Region

ORDER BY total_sales DESC;

-- ─────────────────────────────────────────────
-- 8. High Value vs Low Value Orders
-- ─────────────────────────────────────────────

SELECT 
    CASE 
        WHEN Revenue > 5000 THEN 'High Value'
        ELSE 'Low Value'
    END AS order_type,

    COUNT(*) AS total_orders,

    ROUND(
        SUM(Revenue),
        2
    ) AS total_revenue

FROM sales_data

WHERE Status = 'Delivered'

GROUP BY order_type;

-- ─────────────────────────────────────────────
-- 9. Salesperson Performance Ranking
-- ─────────────────────────────────────────────

SELECT
    Salesperson,

    COUNT(*) AS total_orders,

    ROUND(
        SUM(Revenue),
        2
    ) AS total_revenue,

    ROUND(
        SUM(Profit),
        2
    ) AS total_profit,

    ROUND(
        AVG(Margin_Pct),
        1
    ) AS avg_margin_percentage,

    RANK() OVER (
        ORDER BY SUM(Revenue) DESC
    ) AS revenue_rank

FROM sales_data

WHERE Status = 'Delivered'

GROUP BY Salesperson

ORDER BY total_revenue DESC;

-- ─────────────────────────────────────────────
-- 10. Top 3 Customers per Region
-- ─────────────────────────────────────────────

SELECT *

FROM
(
    SELECT 
        Region,

        Customer_Name,

        ROUND(
            SUM(Revenue),
            2
        ) AS total_revenue,

        RANK() OVER (
            PARTITION BY Region
            ORDER BY SUM(Revenue) DESC
        ) AS customer_rank

    FROM sales_data

    WHERE Status = 'Delivered'

    GROUP BY Region, Customer_Name

) ranked_customers

WHERE customer_rank <= 3

ORDER BY Region, customer_rank;

-- ─────────────────────────────────────────────
-- 11. CTE - Top Performing Regions
-- ─────────────────────────────────────────────

WITH region_stats AS
(
    SELECT
        Region,

        COUNT(*) AS total_orders,

        ROUND(
            SUM(Revenue),
            2
        ) AS total_revenue,

        ROUND(
            SUM(Profit),
            2
        ) AS total_profit,

        ROUND(
            AVG(Margin_Pct),
            1
        ) AS avg_margin_percentage

    FROM sales_data

    WHERE Status = 'Delivered'

    GROUP BY Region
),

ranked_regions AS
(
    SELECT *,

        RANK() OVER (
            ORDER BY total_revenue DESC
        ) AS revenue_rank

    FROM region_stats
)

SELECT *

FROM ranked_regions

ORDER BY revenue_rank;

-- ─────────────────────────────────────────────
-- 12. Running Revenue Trend
-- ─────────────────────────────────────────────

SELECT
    MONTHNAME(Order_Date) AS month_name,

    MONTH(Order_Date) AS month_number,

    ROUND(
        SUM(Revenue),
        2
    ) AS monthly_revenue,

    ROUND(
        SUM(SUM(Revenue)) OVER (
            ORDER BY MONTH(Order_Date)
        ),
        2
    ) AS running_total_revenue

FROM sales_data

WHERE Status = 'Delivered'

GROUP BY month_name, month_number

ORDER BY month_number;

-- ─────────────────────────────────────────────
-- 13. Daily Running Revenue
-- ─────────────────────────────────────────────

SELECT
    Order_Date,

    ROUND(
        Revenue,
        2
    ) AS revenue,

    ROUND(
        SUM(Revenue) OVER (
            ORDER BY Order_Date
        ),
        2
    ) AS running_total

FROM sales_data

WHERE Status = 'Delivered'

ORDER BY Order_Date;