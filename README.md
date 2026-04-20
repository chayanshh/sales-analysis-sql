# sales-analysis-sql

# 📊 Sales Performance & Profitability Analysis — SQL Project

## 🧩 Business Problem
A mid-sized US retail company generates $2.3M in sales across 4 regions
but has only a 12.47% profit margin. This project uses SQL to identify
profit leakage, discount impact, regional imbalance, and customer behaviour.

---

## 📁 Dataset
| Property      | Detail                        |
|---------------|-------------------------------|
| Records       | 9,993 order lines             |
| Period        | 2019 – 2022                   |
| Domain        | Retail / E-commerce           |
| Country       | United States                 |
| Categories    | Furniture, Office Supplies, Technology |
| Segments      | Consumer, Corporate, Home Office |

---

## ❓ Business Problems Solved
| # | Problem | Focus Area |
|---|---------|------------|
| P1 | Profit leakage from excessive discounting | Discount Analysis |
| P2 | Regional sales & profit imbalance | Regional Analysis |
| P3 | Customer segment profitability gap | Segment Analysis |
| P4 | Product category performance | Product Analysis |
| P5 | Shipping mode cost vs satisfaction | Logistics Analysis |
| P6 | Year-over-year growth & seasonality | Trend Analysis |

---

## 🗂️ SQL Questions (25 Total)

### 🟢 Basic Level (Q1–Q8)
- Q1: Total sales revenue and profit
- Q2: Sales, profit, orders by Category
- Q3: Top 10 products by revenue
- Q4: Unique customers, orders, products
- Q5: Sales and profit by Region
- Q6: Sales and profit by Customer Segment
- Q7: Orders placed each year (2019–2022)
- Q8: Distribution across Ship Modes

### 🟠 Intermediate Level (Q9–Q17)
- Q9:  Monthly sales trend by year
- Q10: Loss-making Sub-Categories
- Q11: Profit margin by discount bracket
- Q12: Top 10 customers by profit
- Q13: Average order value by Segment
- Q14: High sales but low profit States
- Q15: Year-over-Year growth by Category
- Q16: Average shipping time by Ship Mode
- Q17: Products sold at a loss most frequently

### 🔵 Advanced Level (Q18–Q25)
- Q18: Customer ranking by profit within Segment (RANK)
- Q19: Cumulative sales by month (Running Total)
- Q20: Top Sub-Category per Region (PARTITION BY)
- Q21: Category profit share (CTE)
- Q22: Customers active all 4 years (Loyal buyers)
- Q23: Discount > 40% with positive profit
- Q24: Sub-category margin health scorecard
- Q25: Top 3 products per Sub-Category (Window Function)

---

## 💡 Key Insights
| Area | Insight |
|------|---------|
| Discounting | Orders with >40% discount result in **100% loss rate** — no exceptions |
| Sub-Category | Tables and Bookcases are confirmed loss-making sub-categories |
| Region | West drives highest revenue; South has weakest margins |
| Customers | Top 20% customers generate ~80% of total profit (Pareto) |
| Seasonality | Q4 (Oct–Dec) is peak season; Q1 is the slowest quarter |
| Shipping | Standard Class dominates; Same Day has lowest profit margin |

---

## 🛠️ Tools Used
- **MySQL 8.0.44** — Query execution
- **MySQL Workbench** — IDE
- **SQL Concepts** — CTEs, Window Functions, Subqueries, CASE, Aggregations

---

## 👤 Author
**Chayansh  Jain**  
[www.linkedin.com/in/chayanshh05] | [https://github.com/chayanshh]
