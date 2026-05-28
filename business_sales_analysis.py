# ─────────────────────────────────────────────
# BUSINESS SALES INTELLIGENCE PROJECT
# Python Data Cleaning & Sales Analysis
# ─────────────────────────────────────────────

import pandas as pd

# ─────────────────────────────────────────────
# Step 1: Load Dataset
# ─────────────────────────────────────────────

df = pd.read_csv(
    r'C:\Junior Data Analyst Project\project_3\Business_Sales_Intelligence.csv'
)

print("\n──── DATA LOADED SUCCESSFULLY ────")
print(f"Total Records: {len(df)}")
print(f"Total Columns: {len(df.columns)}")

# ─────────────────────────────────────────────
# Step 2: Basic Data Cleaning
# ─────────────────────────────────────────────

print("\n──── NULL VALUES ────")
print(df.isnull().sum())

# Remove duplicates
df = df.drop_duplicates()

print(f"\nRecords After Removing Duplicates: {len(df)}")

# Convert date column
df['Order_date'] = pd.to_datetime(df['Order_date'])

# Convert numeric columns
df['Margin_pct'] = pd.to_numeric(
    df['Margin_pct'],
    errors='coerce'
)

df['Revenue'] = pd.to_numeric(
    df['Revenue'],
    errors='coerce'
)

df['Profit'] = pd.to_numeric(
    df['Profit'],
    errors='coerce'
)

# Remove remaining null values
df = df.dropna()

print(f"Clean Records: {len(df)}")

# ─────────────────────────────────────────────
# Step 3: Feature Engineering
# ─────────────────────────────────────────────

df['Month'] = df['Order_date'].dt.month

df['Month_Name'] = (
    df['Order_date']
    .dt.strftime('%B')
)

df['Quarter'] = (
    df['Order_date']
    .dt.quarter
)

df['Year'] = (
    df['Order_date']
    .dt.year
)

# Profit Category
df['Profit_Category'] = pd.cut(
    df['Margin_pct'],
    bins=[0, 20, 30, 100],
    labels=[
        'Low Margin',
        'Medium Margin',
        'High Margin'
    ]
)

# Order Size Category
df['Order_Size'] = pd.cut(
    df['Qty'],
    bins=[0, 10, 25, 50],
    labels=[
        'Small',
        'Medium',
        'Large'
    ]
)

print("\n──── FEATURE ENGINEERING COMPLETED ────")

# ─────────────────────────────────────────────
# Step 4: Delivered Orders Analysis
# ─────────────────────────────────────────────

delivered = df[
    df['Status'] == 'Delivered'
]

# Revenue by Category
print("\n──── REVENUE BY CATEGORY ────")

category_revenue = (
    delivered
    .groupby('Category')['Revenue']
    .sum()
    .sort_values(ascending=False)
    .round(2)
)

print(category_revenue)

# Top 5 Customers
print("\n──── TOP 5 CUSTOMERS ────")

top_customers = (
    delivered
    .groupby('Customer_name')['Revenue']
    .sum()
    .sort_values(ascending=False)
    .head(5)
    .round(2)
)

print(top_customers)

# Salesperson Performance
print("\n──── SALESPERSON PERFORMANCE ────")

salesperson_revenue = (
    delivered
    .groupby('Salesperson')['Revenue']
    .sum()
    .sort_values(ascending=False)
    .round(2)
)

print(salesperson_revenue)

# Region-wise Revenue
print("\n──── REGION-WISE REVENUE ────")

region_revenue = (
    delivered
    .groupby('Region')['Revenue']
    .sum()
    .sort_values(ascending=False)
    .round(2)
)

print(region_revenue)

# Monthly Revenue Trend
print("\n──── MONTHLY REVENUE TREND ────")

monthly_revenue = (
    delivered
    .groupby('Month_Name')['Revenue']
    .sum()
    .round(2)
)

print(monthly_revenue)

# ─────────────────────────────────────────────
# Step 5: Export Clean Data & Reports
# ─────────────────────────────────────────────

with pd.ExcelWriter(
    'Business_Sales_Analytics_Report.xlsx'
) as writer:

    df.to_excel(
        writer,
        sheet_name='Clean_Data',
        index=False
    )

    category_revenue.reset_index().to_excel(
        writer,
        sheet_name='Revenue_By_Category',
        index=False
    )

    top_customers.reset_index().to_excel(
        writer,
        sheet_name='Top_Customers',
        index=False
    )

    salesperson_revenue.reset_index().to_excel(
        writer,
        sheet_name='Salesperson_Performance',
        index=False
    )

    region_revenue.reset_index().to_excel(
        writer,
        sheet_name='Region_Revenue',
        index=False
    )

print(
    "\nBusiness_Sales_Analytics_Report.xlsx saved successfully."
)
