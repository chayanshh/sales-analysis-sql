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



-- -- Expected Insights for the Business

-- 1. Discounting: Impact of >40% Discounts
SELECT 
    CASE 
        WHEN Discount > 0.40 THEN 'Above 40%'
        WHEN Discount > 0.30 THEN '31% - 40%'
        ELSE '30% and Below'
    END AS Discount_Range,
    COUNT(*) AS Total_Orders,
    SUM(CASE WHEN Profit < 0 THEN 1 ELSE 0 END) AS Loss_Making_Orders,
    ROUND(SUM(Profit), 2) AS Total_Profit
FROM store_sales
GROUP BY Discount_Range
ORDER BY Discount_Range;


-- 2. Sub-Category: Analyzing Tables and Bookcases
SELECT 
    Sub_Category, 
    AVG(Discount) AS Avg_Discount,
    SUM(Sales) AS Total_Sales, 
    SUM(Profit) AS Total_Profit,
    ROUND((SUM(Profit) / SUM(Sales)) * 100, 2) AS Profit_Margin_Pct
FROM store_sales
WHERE Sub_Category IN ('Tables', 'Bookcases')
GROUP BY Sub_Category;

-- 3. Region: West Sales vs. South Margins
SELECT 
    Region, 
    SUM(Sales) AS Total_Sales, 
    SUM(Profit) AS Total_Profit,
    ROUND((SUM(Profit) / SUM(Sales)) * 100, 2) AS Profit_Margin_Pct
FROM store_sales
GROUP BY Region
ORDER BY Total_Sales DESC;


-- 4. Customer: Pareto Principle (80/20 Rule)
WITH Customer_Profits AS (
    SELECT 
        Customer_ID, 
        SUM(Profit) AS Total_Customer_Profit,
        PERCENT_RANK() OVER (ORDER BY SUM(Profit) DESC) AS Profit_Rank
    FROM store_sales
    GROUP BY Customer_ID
)
SELECT 
    CASE WHEN Profit_Rank <= 0.20 THEN 'Top 20% Customers' ELSE 'Bottom 80% Customers' END AS Customer_Group,
    COUNT(*) AS Customer_Count,
    SUM(Total_Customer_Profit) AS Combined_Profit
FROM Customer_Profits
GROUP BY Customer_Group;


-- 5. Seasonality: Q4 Peaks vs. Q1 Slumps
SELECT 
    QUARTER(Order_Date) AS Sales_Quarter,
    COUNT(DISTINCT Order_ID) AS Order_Count,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit
FROM store_sales
GROUP BY Sales_Quarter
ORDER BY Sales_Quarter;


-- 6. Shipping: Profit Margins by Ship Mode
SELECT 
    Ship_Mode, 
    COUNT(Order_ID) AS Order_Count,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit,
    ROUND((SUM(Profit) / SUM(Sales)) * 100, 2) AS Profit_Margin_Pct
FROM store_sales
GROUP BY Ship_Mode
ORDER BY Profit_Margin_Pct DESC;



-- -- Business Acton

-- 1. Action: Implement Tiered Approval for Discounts >30%
SELECT 
    Region, 
    Category, 
    Sub_Category, 
    COUNT(*) AS High_Discount_Instances,
    AVG(Discount) AS Avg_Discount_Rate
FROM store_sales
WHERE Discount > 0.30
GROUP BY Region, Category, Sub_Category
HAVING High_Discount_Instances > 5
ORDER BY High_Discount_Instances DESC;


-- 2. Action: Review/Discontinue Loss Leaders (Tables & Bookcases)
SELECT 
    Product_Name, 
    SUM(Sales) AS Total_Sales, 
    SUM(Profit) AS Total_Loss,
    AVG(Discount) AS Avg_Discount
FROM store_sales
WHERE Sub_Category IN ('Tables', 'Bookcases')
GROUP BY Product_Name
HAVING SUM(Profit) < 0
ORDER BY Total_Loss ASC; -- Shows biggest losers first


-- 3. Action: Reallocate Marketing Budget (West vs. South)
SELECT 
    State, 
    SUM(Sales) AS Total_Sales, 
    ROUND(SUM(Profit) / COUNT(Order_ID), 2) AS Profit_Per_Order
FROM store_sales
WHERE Region = 'South'
GROUP BY State
ORDER BY Profit_Per_Order ASC;


-- 4. Action: Identify Candidates for Loyalty Program (Pareto Top 20%)
SELECT 
    Customer_Name, 
    SUM(Sales) AS Lifetime_Value, 
    SUM(Profit) AS Total_Contribution,
    COUNT(DISTINCT Order_ID) AS Order_Frequency
FROM store_sales
GROUP BY Customer_ID, Customer_Name
ORDER BY Total_Contribution DESC
LIMIT 100; -- Adjust based on 20% of your total customer count


-- 5. Action: Pre-stock Q4 & Run Q1 Promotions
SELECT 
    Sub_Category,
    SUM(CASE WHEN QUARTER(Order_Date) = 4 THEN Sales ELSE 0 END) AS Q4_Sales,
    SUM(CASE WHEN QUARTER(Order_Date) = 1 THEN Sales ELSE 0 END) AS Q1_Sales,
    -- Calculate the "Drop-off" to prioritize Q1 promotions
    ROUND(SUM(CASE WHEN QUARTER(Order_Date) = 4 THEN Sales ELSE 0 END) - 
          SUM(CASE WHEN QUARTER(Order_Date) = 1 THEN Sales ELSE 0 END), 2) AS Demand_Gap
FROM store_sales
GROUP BY Sub_Category
ORDER BY Demand_Gap DESC;


-- 6. Action: Incentivize Standard Shipping
SELECT 
    Segment, 
    Category,
    COUNT(Order_ID) AS Same_Day_Orders,
    ROUND(AVG(Profit), 2) AS Avg_Profit_Same_Day
FROM store_sales
WHERE Ship_Mode = 'Same Day'
GROUP BY Segment, Category
HAVING Avg_Profit_Same_Day < 10 -- Target low-profit orders
ORDER BY Same_Day_Orders DESC;