/*
==========================================================
Project : Financial Performance & Business Operations
Database: FinancialBusinessOperations

This is a curated 18-query version of the full analysis,
selected to show a broad, non-repetitive set of SQL skills:
aggregation, joins, subqueries, CASE WHEN, CTEs, and
window functions (RANK, LAG).
==========================================================
*/

CREATE DATABASE FinancialBusinessOperations;
USE FinancialBusinessOperations;

SHOW TABLES;

-- Primary Keys
ALTER TABLE customers MODIFY CustomerID INT NOT NULL, ADD PRIMARY KEY (CustomerID);
ALTER TABLE products MODIFY ProductID INT NOT NULL, ADD PRIMARY KEY (ProductID);
ALTER TABLE employees MODIFY EmployeeID INT NOT NULL, ADD PRIMARY KEY (EmployeeID);
ALTER TABLE departments MODIFY DepartmentID INT NOT NULL, ADD PRIMARY KEY (DepartmentID);
ALTER TABLE business_units MODIFY BusinessUnitID INT NOT NULL, ADD PRIMARY KEY (BusinessUnitID);
ALTER TABLE regions MODIFY RegionID INT NOT NULL, ADD PRIMARY KEY (RegionID);
ALTER TABLE calendar MODIFY Date DATE NOT NULL, ADD PRIMARY KEY (Date);
ALTER TABLE budget MODIFY BudgetID INT NOT NULL, ADD PRIMARY KEY (BudgetID);
ALTER TABLE financial_transactions MODIFY TransactionID INT NOT NULL, ADD PRIMARY KEY (TransactionID);
ALTER TABLE financial_transactions MODIFY COLUMN TransactionDate DATE;
ALTER TABLE customers MODIFY COLUMN JoinDate DATE;

-- Foreign Keys
ALTER TABLE financial_transactions ADD CONSTRAINT fk_customer FOREIGN KEY (CustomerID) REFERENCES customers(CustomerID);
ALTER TABLE financial_transactions ADD CONSTRAINT fk_product FOREIGN KEY (ProductID) REFERENCES products(ProductID);
ALTER TABLE financial_transactions ADD CONSTRAINT fk_employee FOREIGN KEY (EmployeeID) REFERENCES employees(EmployeeID);
ALTER TABLE financial_transactions ADD CONSTRAINT fk_department FOREIGN KEY (DepartmentID) REFERENCES departments(DepartmentID);
ALTER TABLE financial_transactions ADD CONSTRAINT fk_businessunit FOREIGN KEY (BusinessUnitID) REFERENCES business_units(BusinessUnitID);
ALTER TABLE financial_transactions ADD CONSTRAINT fk_region FOREIGN KEY (RegionID) REFERENCES regions(RegionID);
ALTER TABLE budget ADD CONSTRAINT fk_budget_department FOREIGN KEY (DepartmentID) REFERENCES departments(DepartmentID);

SELECT TABLE_NAME, COLUMN_NAME, CONSTRAINT_NAME, REFERENCED_TABLE_NAME, REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'financialbusinessoperations'
AND REFERENCED_TABLE_NAME IS NOT NULL;


/*
==========================================================
Section 1: Database Validation
==========================================================
*/

### Query 1: Total Transactions
-- Basic COUNT to validate row-level completeness.
SELECT COUNT(*) AS Total_Transactions
FROM financial_transactions;

### Query 2: Overall Financial Performance
-- Single-pass aggregation with a derived KPI (profit margin %).
SELECT
    ROUND(SUM(Revenue),2) AS Total_Revenue,
    ROUND(SUM(COGS),2) AS Total_COGS,
    ROUND(SUM(OperatingExpense),2) AS Total_Operating_Expense,
    ROUND(SUM(Profit),2) AS Total_Profit,
    ROUND((SUM(Profit) / SUM(Revenue))*100, 2) AS Profit_Margin_Percentage
FROM financial_transactions;

### Query 3: Order Status Distribution
-- GROUP BY combined with a correlated subquery to compute share %.
SELECT
    OrderStatus,
    COUNT(*) AS Total_Orders,
    ROUND(COUNT(*) * 100 / (SELECT COUNT(*) FROM financial_transactions), 2) AS Percentage
FROM financial_transactions
GROUP BY OrderStatus
ORDER BY Total_Orders DESC;


/*
==========================================================
Section 2: Financial Performance
==========================================================
*/

### Query 4: Monthly Revenue Trend
-- Date formatting + time-series aggregation.
SELECT
    DATE_FORMAT(TransactionDate,'%Y-%m') AS Month,
    ROUND(SUM(Revenue),2) AS Total_Revenue
FROM financial_transactions
GROUP BY DATE_FORMAT(TransactionDate,'%Y-%m')
ORDER BY Month;

### Query 5: Revenue by Region
-- Join + aggregation.
SELECT
    r.RegionName,
    ROUND(SUM(f.Revenue),2) AS Total_Revenue
FROM financial_transactions f
JOIN regions r ON f.RegionID = r.RegionID
GROUP BY r.RegionName
ORDER BY Total_Revenue DESC;

### Query 6: Profit by Region
-- Same join shape, different metric: shows revenue leaders aren't
-- always the most profitable regions.
SELECT
    r.RegionName,
    ROUND(SUM(f.Profit),2) AS Total_Profit
FROM financial_transactions f
JOIN regions r ON f.RegionID = r.RegionID
GROUP BY r.RegionName
ORDER BY Total_Profit DESC;

### Query 7: Revenue by Sales Channel
SELECT
    SalesChannel,
    ROUND(SUM(Revenue),2) AS Total_Revenue
FROM financial_transactions
GROUP BY SalesChannel
ORDER BY Total_Revenue DESC;


/*
==========================================================
Section 3: Customer Analysis
==========================================================
*/

### Query 8: Revenue by Customer Type
SELECT
    CustomerType,
    ROUND(SUM(Revenue),2) AS Total_Revenue,
    COUNT(*) AS Total_Transactions
FROM financial_transactions
GROUP BY CustomerType
ORDER BY Total_Revenue DESC;

### Query 9: Top 10 Customers by Revenue
-- Join + GROUP BY + LIMIT (Top-N pattern).
SELECT
    c.CustomerID,
    CONCAT(c.FirstName,' ',c.LastName) AS Customer_Name,
    ROUND(SUM(f.Revenue),2) AS Total_Revenue,
    ROUND(SUM(f.Profit),2) AS Total_Profit
FROM financial_transactions f
JOIN customers c ON f.CustomerID = c.CustomerID
GROUP BY c.CustomerID, Customer_Name
ORDER BY Total_Revenue DESC
LIMIT 10;

### Query 10: Revenue by Age Group
-- CASE WHEN bucketing.
SELECT
    CASE
        WHEN c.Age < 25 THEN 'Under 25'
        WHEN c.Age BETWEEN 25 AND 34 THEN '25-34'
        WHEN c.Age BETWEEN 35 AND 44 THEN '35-44'
        WHEN c.Age BETWEEN 45 AND 54 THEN '45-54'
        ELSE '55+'
    END AS Age_Group,
    ROUND(SUM(f.Revenue),2) AS Total_Revenue,
    ROUND(SUM(f.Profit),2) AS Total_Profit
FROM financial_transactions f
JOIN customers c ON f.CustomerID = c.CustomerID
GROUP BY Age_Group
ORDER BY Total_Revenue DESC;


/*
==========================================================
Section 4: Product Analysis
==========================================================
*/

### Query 11: Revenue by Product Category
SELECT
    p.Category,
    ROUND(SUM(f.Revenue),2) AS Total_Revenue,
    ROUND(SUM(f.Profit),2) AS Total_Profit
FROM financial_transactions f
JOIN products p ON f.ProductID = p.ProductID
GROUP BY p.Category
ORDER BY Total_Revenue DESC;

### Query 12: Top 10 Products by Revenue
SELECT
    p.ProductID,
    p.ProductName,
    p.Category,
    ROUND(SUM(f.Revenue),2) AS Total_Revenue,
    ROUND(SUM(f.Profit),2) AS Total_Profit
FROM financial_transactions f
JOIN products p ON f.ProductID = p.ProductID
GROUP BY p.ProductID, p.ProductName, p.Category
ORDER BY Total_Revenue DESC
LIMIT 10;

### Query 13: Category-wise Profit Margin
-- Derived ratio KPI at the category level.
SELECT
    p.Category,
    ROUND(SUM(f.Revenue),2) AS Total_Revenue,
    ROUND(SUM(f.Profit),2) AS Total_Profit,
    ROUND((SUM(f.Profit) / SUM(f.Revenue)) * 100, 2) AS Profit_Margin_Percentage
FROM financial_transactions f
JOIN products p ON f.ProductID = p.ProductID
GROUP BY p.Category
ORDER BY Profit_Margin_Percentage DESC;


/*
==========================================================
Section 5: Employee & Department Analysis
==========================================================
*/

### Query 14: Top 10 Employees by Profit
SELECT
    e.EmployeeID,
    e.EmployeeName,
    ROUND(SUM(f.Profit),2) AS Total_Profit
FROM financial_transactions f
JOIN employees e ON f.EmployeeID = e.EmployeeID
GROUP BY e.EmployeeID, e.EmployeeName
ORDER BY Total_Profit DESC
LIMIT 10;

### Query 15: Department-wise Financial Performance
SELECT
    d.DepartmentName,
    ROUND(SUM(f.Revenue),2) AS Total_Revenue,
    ROUND(SUM(f.Profit),2) AS Total_Profit
FROM financial_transactions f
JOIN departments d ON f.DepartmentID = d.DepartmentID
GROUP BY d.DepartmentName
ORDER BY Total_Revenue DESC;

### Query 16: Budget vs Actual Revenue
-- Three-table join to compute a real business variance metric.
SELECT
    d.DepartmentName,
    ROUND(SUM(b.BudgetRevenue),2) AS Budget_Revenue,
    ROUND(SUM(f.Revenue),2) AS Actual_Revenue,
    ROUND(SUM(f.Revenue) - SUM(b.BudgetRevenue), 2) AS Revenue_Variance
FROM budget b
JOIN departments d ON b.DepartmentID = d.DepartmentID
JOIN financial_transactions f ON d.DepartmentID = f.DepartmentID
GROUP BY d.DepartmentName
ORDER BY Revenue_Variance DESC;


/*
==========================================================
Section 6: Advanced SQL (CTEs & Window Functions)
==========================================================
*/

### Query 17: Top 5 Customers by Profit (RANK)
WITH CustomerProfit AS (
    SELECT
        c.CustomerID,
        CONCAT(c.FirstName,' ',c.LastName) AS Customer_Name,
        ROUND(SUM(f.Profit),2) AS Total_Profit
    FROM financial_transactions f
    JOIN customers c ON f.CustomerID = c.CustomerID
    GROUP BY c.CustomerID, Customer_Name
)
SELECT *,
       RANK() OVER(ORDER BY Total_Profit DESC) AS Customer_Rank
FROM CustomerProfit
LIMIT 5;



### Query 18: Monthly Revenue Growth (LAG)
WITH MonthlyRevenue AS (
    SELECT
        DATE_FORMAT(TransactionDate,'%Y-%m') AS Month,
        SUM(Revenue) AS Revenue
    FROM financial_transactions
    GROUP BY DATE_FORMAT(TransactionDate,'%Y-%m')
)
SELECT
    Month,
    ROUND(Revenue,2) AS Revenue,
    ROUND(LAG(Revenue) OVER(ORDER BY Month), 2) AS Previous_Month_Revenue,
    ROUND(
        ((Revenue - LAG(Revenue) OVER(ORDER BY Month)) / LAG(Revenue) OVER(ORDER BY Month)) * 100,
        2
    ) AS Growth_Percentage
FROM MonthlyRevenue;


/*
==========================================================
Conclusion
==========================================================
This curated set of 18 queries covers: aggregation, correlated
subqueries, multi-table joins, CASE WHEN bucketing, Top-N filtering,
derived ratio KPIs, three-way joins for variance analysis, and
window functions (RANK, LAG) inside CTEs — the core SQL skill set
expected of an entry-level data analyst.
*/