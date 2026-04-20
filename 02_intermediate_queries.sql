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

-- 9 - What is the monthly sales trend for each year? (Month x Year matrix)
-- Seasonality & growth pattern detection 
select 
    YEAR(Order_Date)              AS Order_Year,
    MONTH(Order_Date)             AS Order_Month,
    MONTHNAME(Order_Date)         AS Month_Name,
    ROUND(SUM(Sales), 2)          AS Monthly_Sales,
    ROUND(SUM(Profit), 2)         AS Monthly_Profit,
    COUNT(DISTINCT Order_ID)      AS Total_Orders
FROM store_sales
GROUP BY
    YEAR(Order_Date),
    MONTH(Order_Date),
    MONTHNAME(Order_Date)
ORDER BY Order_Year, Order_Month;


-- 10 - Which Sub-Categories have a negative total profit (loss-making)?
-- Loss-leader product identification 
SELECT
    Category,
    Sub_Category,
    ROUND(SUM(Sales), 2)                  AS Total_Sales,
    ROUND(SUM(Profit), 2)                 AS Total_Profit,
    ROUND(SUM(Profit)/SUM(Sales)*100, 2)  AS Profit_Margin_Pct,
    COUNT(*)                              AS Order_Lines
FROM store_sales
GROUP BY Category, Sub_Category
HAVING SUM(Profit) < 0
ORDER BY Total_Profit ASC;


-- 11 - What is the average profit margin for each discount bracket (0%, 1–20%, 21–50%, 51–80%)?
-- Discount impact on profitability 
SELECT
    CASE
        WHEN Discount = 0      THEN '0%  — No Discount'
        WHEN Discount <= 0.20  THEN '1–20%  — Low'
        WHEN Discount <= 0.50  THEN '21–50% — Medium'
        ELSE                        '51–80% — High'
    END                                   AS Discount_Band,
    COUNT(*)                              AS Order_Lines,
    ROUND(AVG(Discount)*100, 1)           AS Avg_Discount_Pct,
    ROUND(AVG(Profit), 2)                 AS Avg_Profit,
    ROUND(SUM(Profit)/SUM(Sales)*100, 2)  AS Profit_Margin_Pct
FROM store_sales
GROUP BY Discount_Band
ORDER BY Profit_Margin_Pct DESC;


-- 12 - Who are the top 10 customers by total profit contributed?
-- High-value customer profiling 
SELECT
    Customer_ID,
    Customer_Name,
    Segment,
    Region,
    COUNT(DISTINCT Order_ID)              AS Total_Orders,
    ROUND(SUM(Sales), 2)                  AS Total_Sales,
    ROUND(SUM(Profit), 2)                 AS Total_Profit,
    ROUND(SUM(Profit)/SUM(Sales)*100, 2)  AS Profit_Margin_Pct
FROM store_sales
GROUP BY Customer_ID, Customer_Name, Segment, Region
ORDER BY Total_Profit DESC
LIMIT 10;


-- 13 - What is the average order value (AOV) and average profit per order by Segment?
-- Segment-level order economics
SELECT
    Segment,
    COUNT(DISTINCT Order_ID)                        AS Total_Orders,
    ROUND(SUM(Sales) / COUNT(DISTINCT Order_ID), 2) AS Avg_Order_Value,
    ROUND(SUM(Profit)/ COUNT(DISTINCT Order_ID), 2) AS Avg_Profit_Per_Order,
    ROUND(AVG(Discount)*100, 2)                     AS Avg_Discount_Pct
FROM store_sales
GROUP BY Segment
ORDER BY Avg_Order_Value DESC;

 
-- 14 - Which State generates the highest sales but lowest profit margin?
-- Underperforming geography detection
SELECT
    State,
    Region,
    ROUND(SUM(Sales), 2)                  AS Total_Sales,
    ROUND(SUM(Profit), 2)                 AS Total_Profit,
    ROUND(SUM(Profit)/SUM(Sales)*100, 2)  AS Profit_Margin_Pct,
    COUNT(DISTINCT Order_ID)              AS Total_Orders
FROM store_sales
GROUP BY State, Region
HAVING SUM(Sales) > 10000
ORDER BY Total_Sales DESC, Profit_Margin_Pct ASC
LIMIT 10;

 
-- 15 - What is the Year-over-Year sales growth rate for each Category?
-- Category growth trajectory analysis 
WITH yearly AS (
    SELECT
        Category,
        YEAR(Order_Date)      AS yr,
        ROUND(SUM(Sales), 2)  AS Total_Sales
    FROM store_sales
    GROUP BY Category, YEAR(Order_Date)
)
SELECT
    curr.Category,
    curr.yr                                         AS Current_Year,
    curr.Total_Sales                               AS Current_Sales,
    prev.Total_Sales                               AS Prev_Sales,
    ROUND((curr.Total_Sales - prev.Total_Sales)
          / prev.Total_Sales * 100, 2)             AS YoY_Growth_Pct
FROM yearly curr
LEFT JOIN yearly prev
    ON curr.Category = prev.Category
    AND curr.yr = prev.yr + 1
ORDER BY curr.Category, curr.yr;


-- 16 - What is the average shipping time (days) by Ship Mode?
-- Logistics efficiency benchmarking 
SELECT
    Ship_Mode,
    COUNT(DISTINCT Order_ID)                        AS Total_Orders,
    ROUND(AVG(DATEDIFF(Ship_Date, Order_Date)), 1)  AS Avg_Ship_Days,
    MIN(DATEDIFF(Ship_Date, Order_Date))            AS Min_Ship_Days,
    MAX(DATEDIFF(Ship_Date, Order_Date))            AS Max_Ship_Days
FROM store_sales
GROUP BY Ship_Mode
ORDER BY Avg_Ship_Days ASC;


-- Q17 - Which products are sold at a loss (Profit < 0) most frequently?
-- Chronic loss-making SKU flagging (MySQL Compatible)

SELECT
    Product_ID,
    Product_Name,
    Category,
    Sub_Category,
    SUM(CASE WHEN Profit < 0 THEN 1 ELSE 0 END)         AS Loss_Order_Count,
    COUNT(*)                                              AS Total_Order_Lines,
    ROUND(
        SUM(CASE WHEN Profit < 0 THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 1
    )                                                     AS Loss_Rate_Pct,
    ROUND(SUM(Profit), 2)                                 AS Net_Profit
FROM store_sales
GROUP BY Product_ID, Product_Name, Category, Sub_Category
HAVING SUM(CASE WHEN Profit < 0 THEN 1 ELSE 0 END) > 0
ORDER BY Loss_Order_Count DESC
LIMIT 15;