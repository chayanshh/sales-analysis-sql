Create database store_sales;
use store_sales;

CREATE TABLE store_sales 
(
Order_ID        VARCHAR(255),
Order_Date      DATE,
Ship_Date       DATE,
Ship_Mode       VARCHAR(255),
Customer_ID     VARCHAR(255),
Customer_Name   VARCHAR(255),
Segment         VARCHAR(255),
Country         VARCHAR(255),
City            VARCHAR(255),
State           VARCHAR(255),
Postal_Code     VARCHAR(255),
Region          VARCHAR(255),
Product_ID      VARCHAR(255),
Category        VARCHAR(255),
Sub_Category    VARCHAR(255),
Product_Name    VARCHAR(500),
Sales           DECIMAL(10,4),
Quantity        INT,
Discount        DECIMAL(4,2),
Profit          DECIMAL(10,4)
);

truncate store_sales;
SET global local_infile = ON;

LOAD DATA LOCAL INFILE 'D:/cleaned_sales_dataset.csv'
into table store_sales
fields terminated by ','
OPTIONALLY ENCLOSED BY '"'
lines terminated by '\r\n'
ignore 1 rows;

select * from store_sales;

-- 18 - Rank customers by total profit within each Segment using window functions.
-- Intra-segment customer ranking 
WITH customer_profit AS (
    SELECT
        Customer_ID,
        Customer_Name,
        Segment,
        ROUND(SUM(Sales), 2)   AS Total_Sales,
        ROUND(SUM(Profit), 2)  AS Total_Profit,
        COUNT(DISTINCT Order_ID) AS Total_Orders
    FROM store_sales
    GROUP BY Customer_ID, Customer_Name, Segment
)
SELECT
    Segment,
    Customer_Name,
    Total_Sales,
    Total_Profit,
    Total_Orders,
    RANK() OVER (
        PARTITION BY Segment
        ORDER BY Total_Profit DESC
    )  AS Profit_Rank_In_Segment
FROM customer_profit
ORDER BY Segment, Profit_Rank_In_Segment;


-- 19 - Calculate the running cumulative sales total by month across all years.
-- Cumulative growth trend analysis
SELECT 
    a.Sales_Month, 
    a.Monthly_Sales, 
    ROUND(SUM(b.Monthly_Sales), 2) AS Cumulative_Sales
FROM (
    -- Subquery to get monthly totals first
    SELECT 
        DATE_FORMAT(Order_Date, '%Y-%m') AS Sales_Month, 
        SUM(Sales) AS Monthly_Sales 
    FROM store_sales 
    GROUP BY Sales_Month
) a
JOIN (
    -- Subquery repeated to compare dates for the running total
    SELECT 
        DATE_FORMAT(Order_Date, '%Y-%m') AS Sales_Month, 
        SUM(Sales) AS Monthly_Sales 
    FROM store_sales 
    GROUP BY Sales_Month
) b ON b.Sales_Month <= a.Sales_Month
GROUP BY a.Sales_Month, a.Monthly_Sales
ORDER BY a.Sales_Month;



-- 20 - Find the sub-category with the highest sales in each Region.
-- Regional product affinity mapping
WITH regional_sub AS (
    SELECT
        Region,
        Sub_Category,
        ROUND(SUM(Sales), 2)  AS Total_Sales,
        RANK() OVER (
            PARTITION BY Region
            ORDER BY SUM(Sales) DESC
        )  AS rnk
    FROM store_sales
    GROUP BY Region, Sub_Category
)
SELECT
    Region,
    Sub_Category      AS Top_Sub_Category,
    Total_Sales
FROM regional_sub
WHERE rnk = 1
ORDER BY Total_Sales DESC;


-- 21 - What percentage of total profit does each Category contribute? (using CTE)
-- Category profit share decomposition 
WITH category_profit AS (
    SELECT
        Category,
        ROUND(SUM(Profit), 2)  AS Cat_Profit
    FROM store_sales
    GROUP BY Category
),
total AS (
    SELECT SUM(Profit) AS Total_Profit FROM store_sales
)
SELECT
    cp.Category,
    cp.Cat_Profit                                    AS Category_Profit,
    ROUND(cp.Cat_Profit / t.Total_Profit * 100, 2)  AS Profit_Share_Pct
FROM category_profit cp
CROSS JOIN total t
ORDER BY Profit_Share_Pct DESC;


-- 22 - Identify customers who placed orders every year from 2019 to 2022.
-- Loyal / repeat customer identification 
SELECT
    Customer_ID,
    Customer_Name,
    Segment,
    COUNT(DISTINCT YEAR(Order_Date))  AS Active_Years,
    COUNT(DISTINCT Order_ID)          AS Total_Orders,
    ROUND(SUM(Sales), 2)              AS Total_Sales,
    ROUND(SUM(Profit), 2)             AS Total_Profit
FROM store_sales
GROUP BY Customer_ID, Customer_Name, Segment
HAVING COUNT(DISTINCT YEAR(Order_Date)) = 4
ORDER BY Total_Profit DESC;


-- 23 - Which orders have a Discount > 40% AND still generate a positive Profit?
-- Resilient high-discount profitable orders 
SELECT
    Order_ID,
    Product_Name,
    Category,
    Sub_Category,
    Segment,
    ROUND(Discount * 100, 0)  AS Discount_Pct,
    ROUND(Sales, 2)           AS Sales,
    ROUND(Profit, 2)          AS Profit,
    ROUND(Profit/Sales*100,2) AS Margin_Pct
FROM store_sales
WHERE Discount > 0.40
  AND Profit > 0
ORDER BY Discount DESC, Profit DESC;


-- 24 - Calculate the profit-to-sales ratio and rank all Sub-Categories. Flag those below 5% margin.
-- Margin health scorecard by sub-category 
WITH sub_margins AS (
    SELECT
        Category,
        Sub_Category,
        ROUND(SUM(Sales), 2)                  AS Total_Sales,
        ROUND(SUM(Profit), 2)                 AS Total_Profit,
        ROUND(SUM(Profit)/SUM(Sales)*100, 2)  AS Profit_Margin_Pct
    FROM store_sales
    GROUP BY Category, Sub_Category
)
SELECT
    Category,
    Sub_Category,
    Total_Sales,
    Total_Profit,
    Profit_Margin_Pct,
    RANK() OVER (ORDER BY Profit_Margin_Pct DESC)  AS Margin_Rank,
    CASE
        WHEN Profit_Margin_Pct < 0    THEN 'LOSS-MAKING'
        WHEN Profit_Margin_Pct < 5    THEN 'CRITICAL — Below 5%'
        WHEN Profit_Margin_Pct < 10   THEN 'LOW — 5-10%'
        ELSE                               'HEALTHY'
    END  AS Margin_Flag
FROM sub_margins
ORDER BY Profit_Margin_Pct ASC;


-- 25 - Using a CTE, find the top 3 products by profit within each Category and Sub-Category.
-- Nested best-performer product analysis
WITH ranked AS (
    SELECT
        Category,
        Sub_Category,
        Product_Name,
        ROUND(SUM(Sales), 2)   AS Total_Sales,
        ROUND(SUM(Profit), 2)  AS Total_Profit,
        SUM(Quantity)          AS Units_Sold,
        RANK() OVER (
            PARTITION BY Category, Sub_Category
            ORDER BY SUM(Profit) DESC
        )  AS Profit_Rank
    FROM store_sales
    GROUP BY Category, Sub_Category, Product_Name
)
SELECT
    Category,
    Sub_Category,
    Profit_Rank,
    Product_Name,
    Total_Sales,
    Total_Profit,
    Units_Sold
FROM ranked
WHERE Profit_Rank <= 3
ORDER BY Category, Sub_Category, Profit_Rank;