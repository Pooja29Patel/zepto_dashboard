# ======================================================
# 🛒 Zepto Data Dashboard (Streamlit App)
# ======================================================

import streamlit as st
import pandas as pd
import psycopg2
import matplotlib.pyplot as plt

# ------------------------------------------------------
# 1. Page Setup
# ------------------------------------------------------
st.set_page_config(page_title="Zepto Dashboard", layout="wide")
st.title("🛒 Zepto Product Analytics Dashboard")

# ------------------------------------------------------
# 2. Load Data from Neon PostgreSQL
# ------------------------------------------------------
@st.cache_data
def load_data():
    conn = psycopg2.connect(
        host="ep-solitary-hall-adtofe8l-pooler.c-2.us-east-1.aws.neon.tech",        
        database="neondb", 
        user="neondb_owner",    
        password="npg_fK7GZVM3bBtq", 
        port="5432",
        sslmode="require"
    )
    query = "SELECT * FROM zepto;"
    df = pd.read_sql(query, conn)
    conn.close()

    # Fix column names to match your table
    df.columns = [c.lower() for c in df.columns]

    # Derived columns
    df['revenue'] = df['discountedsellingprice'] * df['availablequantity']
    df['price_per_gram'] = df['discountedsellingprice'] / df['weightingms']
    return df

df = load_data()

# ------------------------------------------------------
# 3. KPI Cards
# ------------------------------------------------------
total_revenue = df['revenue'].sum()
avg_discount = df['discountpercent'].mean()
pct_out_of_stock = round((df['outofstock'].sum() / len(df)) * 100, 2)
top_category = df.groupby('category')['revenue'].sum().sort_values(ascending=False).index[0]

col1, col2, col3, col4 = st.columns(4)
col1.metric("💰 Total Revenue", f"₹{total_revenue:,.0f}")
col2.metric("🏷️ Avg Discount", f"{avg_discount:.2f}%")
col3.metric("📦 Out of Stock %", f"{pct_out_of_stock}%")
col4.metric("⭐ Top Category", top_category)

st.markdown("---")

# ------------------------------------------------------
# 4. Filters
# ------------------------------------------------------
categories = st.multiselect("Filter by Category:", options=df['category'].dropna().unique(), default=None)
if categories:
    df = df[df['category'].isin(categories)]

# ------------------------------------------------------
# 5. Charts
# ------------------------------------------------------

# A. Revenue by Category
st.subheader("Revenue by Category")
cat_revenue = df.groupby('category')['revenue'].sum().sort_values(ascending=False)

fig, ax = plt.subplots(figsize=(8,4))
cat_revenue.plot(kind='bar', color='skyblue', edgecolor='black', ax=ax)
ax.set_ylabel("Revenue (₹)")
ax.set_xlabel("Category")
st.pyplot(fig)

# B. Average Discount by Category
st.subheader("Average Discount % by Category")
avg_discount_cat = df.groupby('category')['discountpercent'].mean().sort_values(ascending=False)

fig, ax = plt.subplots(figsize=(8,4))
avg_discount_cat.plot(kind='barh', color='orange', ax=ax)
ax.set_xlabel("Avg Discount %")
st.pyplot(fig)

# C. Stock Status
st.subheader("Stock Status Distribution")
stock_status = df['outofstock'].value_counts()

fig, ax = plt.subplots(figsize=(4,4))
stock_status.plot(kind='pie', autopct='%1.1f%%', startangle=90,
                  labels=['In Stock','Out of Stock'], colors=['green','red'], ax=ax)
ax.set_ylabel("")
st.pyplot(fig)

# D. Price per Gram Distribution
st.subheader("Price per Gram Distribution (for items ≥100g)")
df_filtered = df[df['weightingms'] >= 100]

fig, ax = plt.subplots(figsize=(8,4))
df_filtered['price_per_gram'].hist(bins=50, color='purple', edgecolor='white', ax=ax)
ax.set_xlabel("Price per Gram (₹)")
ax.set_ylabel("Number of Products")
st.pyplot(fig)

# E. Top 10 Best Discounted Products
st.subheader("Top 10 Products by Discount %")
top_discounts = df[['name','discountpercent']].drop_duplicates().nlargest(10, 'discountpercent')

fig, ax = plt.subplots(figsize=(8,4))
ax.barh(top_discounts['name'], top_discounts['discountpercent'], color='teal')
ax.invert_yaxis()
ax.set_xlabel("Discount %")
st.pyplot(fig)

st.markdown("✅ Dashboard built with Streamlit, Matplotlib, and Neon PostgreSQL.")
