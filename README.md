# 🛒 Zepto SQL Case Study

## 📌 Project Overview
This project analyzes a sample **product dataset from Zepto** using SQL (PostgreSQL).  
The goal is to demonstrate **end-to-end SQL skills** — from **data exploration** and **cleaning** to **business-focused analysis** and **KPI reporting**.

---

## 🗂️ Dataset Structure
The dataset represents an e-commerce catalog with the following fields:

| Column                | Description |
|------------------------|-------------|
| `sku_id`              | Unique product identifier |
| `category`            | Product category (e.g., Dairy, Snacks) |
| `name`                | Product name |
| `mrp`                 | Maximum Retail Price |
| `discountPercent`     | Discount percentage offered |
| `availableQuantity`   | Current stock available |
| `discountedSellingPrice` | Final selling price after discount |
| `weightInGms`         | Product weight in grams |
| `outOfStock`          | Stock status (TRUE/FALSE) |
| `quantity`            | Units sold / movement (if available) |

---

## 🔍 Steps Performed

### 1. **Data Exploration**
- Checked total rows, sample data, and null values.  
- Identified unique categories.  
- Analyzed duplicates and stock status.

### 2. **Data Cleaning**
- Removed invalid rows (`mrp = 0`).  
- Converted prices from **paise → rupees**.  
- Verified data consistency.

### 3. **Business Analysis**
- **Discount Analysis**: Top 10 products with the highest discounts.  
- **Premium Products**: High MRP but low discount items.  
- **Revenue Estimation**: Revenue per category based on available stock.  
- **Weight Categories**: Grouped into Low / Medium / Bulk.  
- **Price per Gram**: Identified best-value products by weight.

### 4. **Advanced Insights**
- **Margin %**: Difference between MRP and selling price.  
- **Stock Value**: Inventory worth by product.  
- **Category Contribution**: % revenue contribution of each category.  
- **Lost Revenue**: Potential loss due to out-of-stock items.  
- **Correlation Check**: MRP vs Discount %.  
- **Category Weight Stats**: Average / min / max product weights.

### 5. **KPI Summary Dashboard**
At the end of the script, a single query outputs:
- **Total Revenue**  
- **Average Discount %**  
- **% of Products Out of Stock**  
- **Top Revenue-Generating Category**  
- **Revenue of that Category**

---

## 📊 Example Insights (Hypothetical)
- **Snacks** contributed **35% of total revenue**.  
- **10% of products are out of stock**, leading to potential lost sales.  
- Average discount across all categories is **12.4%**.  
- Bulk items (> 5kg) offer the **best price per gram**.  
- High MRP items (> ₹500) usually have **lower discounts (<10%)**, suggesting premium positioning.  

---

## 🚀 Skills Demonstrated
- **Data Exploration** (profiling, duplicates, nulls, distributions).  
- **Data Cleaning** (removing anomalies, currency conversion).  
- **Business-Oriented SQL Queries** (revenue, discounts, stock value).  
- **Analytical Thinking** (margin analysis, lost revenue).  
- **SQL Window Functions & CTEs** (ranking, contribution %).  
- **KPI Reporting** for decision-making.  

---

## 📂 Files in This Project
- `SQL_Queries.sql` → Complete SQL script (exploration → cleaning → analysis → dashboard).   
- `README.md` → This documentation file with methodology and insights.  
- `zepto_dataset.csv` → Complete Datset downloaded from kaggle.
- `zepto_dashboard.py` → python script for streamlit app
---

## ✅ Conclusion
This project showcases how SQL can be used not just for **data handling**, but also for **business insights**.  
It highlights product pricing, discounts, revenue potential, and inventory health — all of which are **critical KPIs for an e-commerce platform like Zepto**.

---
