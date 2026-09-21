# Financial-Performance-And-Business-Operations

An end-to-end data analytics project evaluating enterprise financial performance and operational efficiency. The analysis integrates a relational database of **200,000 transactions** across 9 relational tables, providing insights into revenue growth, profit margins, customer demographics, sales channel efficiency, and budget variances.
---
## 📌 Executive Summary

* **Total Revenue Analyzed:** ~$3.74 Billion across 200,000 transactions.
* **Average Order Value (AOV):** $18,707.47
* **Total Volume Sold:** 2,003,003 units.
* **Tech Stack:** Python (Pandas, NumPy, Matplotlib), SQL (MySQL/SQL Server), Advanced Excel, Power BI.

---
### Relational Model Setup
- **Fact Table**: `financial_transactions` (Primary key: `TransactionID`, foreign keys linked to all core dimension tables).
- **Dimension Tables**: `customers`, `products`, `employees`, `departments`, `business_units`, `regions`, `calendar`, and `budget`.
- **Integrity Constraints**: Primary and foreign key relationships enforced via `ALTER TABLE` DDL statements.

---
## 📊 Analytics Workflow & Key Queries

### 1. Exploratory Data Analysis (Python)
* **Data Integrity:** Verified zero missing values and zero duplicate records across all 9 datasets.
* **Metric Distribution:** Analyzed mean, standard deviation, and percentiles for `Revenue`, `Profit`, `COGS`, `OperatingExpense`, `Discount`, and `Tax`.

### 2. SQL Business Analysis (18 Curated Queries)
The SQL suite covers essential to advanced analytical techniques:
* **Single-Pass Aggregations:** Overall profit margins, total revenue, COGS, and operating expenses.
* **Multi-Table Joins & Variance Analysis:** Comparing actual revenue vs. department budgets to isolate high-performing units.
* **Demographic Bucketing (`CASE WHEN`):** Revenue breakdown by customer age brackets (`Under 25`, `25-34`, `35-44`, `45-54`, `55+`).
* **Advanced CTEs & Window Functions:**
  * `RANK()`: Identifying top 5 profit-generating customers.
  * `LAG()`: Computing Month-over-Month (MoM) revenue growth percentages.

---
## 🚀 Key Business Insights
1. **Financial Overview**: Single-pass aggregated KPIs measure total revenue against Cost of Goods Sold (COGS) and Operating Expenses (OpEx) to determine net enterprise profit margins.
2. **Regional Variance**: Uncovered instances where top revenue-generating regions did not align with top profit-generating regions, identifying areas of high operational expense.
3. **Customer Segmentation**: `CASE WHEN` age grouping identified key purchasing demographics, driving targeted marketing strategies.
4. **Budget vs. Actual Variance**: Evaluated departmental performance by comparing actual revenues against allocated target budgets using multi-table joins.
5. **Growth Trends**: Month-over-Month calculation via `LAG()` highlighted peak sales cycles and periodic growth drops.

---
