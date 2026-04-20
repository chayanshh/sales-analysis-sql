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

-- 1 - What is the total sales revenue and total profit for the entire dataset?
-- Baseline financial health check 
SELECT 
    SUM(Sales) AS Total_Sales_Revenue, 
    SUM(Profit) AS Total_Profit
FROM store_sales;

-- 2 -  What is the total sales, profit, and number of orders for each product Category?
-- Category-level performance overview 
SELECT
Category,
COUNT(DISTINCT Order_ID) AS Total_Orders,
SUM(Sales) AS Total_Sales,
SUM(Profit) AS Total_Profit,
ROUND(SUM(Profit)/SUM(Sales)*100, 2) AS Profit_Margin_Pct
FROM store_sales
GROUP BY Category
ORDER BY Total_Sales DESC;


-- 3 -  Which are the top 10 products by total sales revenue?
-- Best-selling SKU identification 
SELECT
    Product_ID,
    Product_Name,
    Category,
    Sub_Category,
    ROUND(SUM(Sales), 2)   AS Total_Sales,
    ROUND(SUM(Profit), 2)  AS Total_Profit,
    SUM(Quantity)          AS Units_Sold
FROM store_sales
GROUP BY Product_ID, Product_Name, Category, Sub_Category
ORDER BY Total_Sales DESC
limit 10;

-- 4 - How many unique customers, orders, and products exist in the dataset?
-- Dataset cardinality & scope 
SELECT
    COUNT(DISTINCT Customer_ID)  AS Unique_Customers,
    COUNT(DISTINCT Order_ID)     AS Unique_Orders,
    COUNT(DISTINCT Product_ID)   AS Unique_Products,
    COUNT(*)                     AS Total_Order_Lines
FROM store_sales;


-- 5 - What is the total sales and profit by Region? 
-- Regional revenue & profitability map 
SELECT
    Region,
    COUNT(DISTINCT Order_ID)              AS Total_Orders,
    ROUND(SUM(Sales), 2)                  AS Total_Sales,
    ROUND(SUM(Profit), 2)                 AS Total_Profit,
    ROUND(SUM(Profit)/SUM(Sales)*100, 2)  AS Profit_Margin_Pct
FROM store_sales
GROUP BY Region
ORDER BY Total_Sales DESC;


-- 6 - What is the total sales and profit for each Customer Segment?
-- Segment-level P&L overview 
SELECT
    Segment,
    COUNT(DISTINCT Customer_ID)           AS Unique_Customers,
    COUNT(DISTINCT Order_ID)              AS Total_Orders,
    ROUND(SUM(Sales), 2)                  AS Total_Sales,
    ROUND(SUM(Profit), 2)                 AS Total_Profit,
    ROUND(SUM(Profit)/SUM(Sales)*100, 2)  AS Profit_Margin_Pct
FROM store_sales
GROUP BY Segment
ORDER BY Total_Sales DESC;

-- 7 - How many orders were placed each year (2019–2022)?
-- YoY order volume trend 
SELECT
    YEAR(Order_Date)              AS Order_Year,
    COUNT(DISTINCT Order_ID)      AS Total_Orders,
    ROUND(SUM(Sales), 2)          AS Total_Sales,
    ROUND(SUM(Profit), 2)         AS Total_Profit
FROM store_sales
GROUP BY YEAR(Order_Date)
ORDER BY Order_Year ASC;

-- 8 - What is the distribution of orders across different Ship Modes?
-- Logistics preference analysis 
SELECT
    Ship_Mode,
    COUNT(DISTINCT Order_ID)              AS Total_Orders,
    ROUND(SUM(Sales), 2)                  AS Total_Sales,
    ROUND(SUM(Profit), 2)                 AS Total_Profit,
    ROUND(SUM(Profit)/SUM(Sales)*100, 2)  AS Profit_Margin_Pct,
    ROUND(COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM store_sales), 2)  AS Order_Share_Pct
FROM store_sales
GROUP BY Ship_Mode
ORDER BY Total_Orders DESC;