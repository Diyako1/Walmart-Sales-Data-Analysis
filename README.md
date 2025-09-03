# Walmart Business Intelligence Project
*SQL-based analysis pipeline for retail sales data*

## Overview

I analyze Walmart sales data using SQL and Python. The pipeline cleans CSV files, loads them into PostgreSQL, and runs queries to find payment patterns, branch performance, and revenue trends. Built this to answer common retail questions quickly.

## Features

- **Data Pipeline** - Cleans CSV files and loads into PostgreSQL
- **Business Queries** - SQL for payments, branch performance, ratings, profits
- **Revenue Tracking** - Find branches losing money year-over-year
- **Time Analysis** - Sales by hour, day, season
- **Clean Export** - Processed CSV for other tools

## How It Works

1. **Clean Data** - Remove duplicates, fix missing values, standardize formats
2. **Load Database** - Insert clean data into PostgreSQL
3. **Run Queries** - Use SQL to analyze payments, ratings, profits
4. **Track Performance** - Monitor branch performance and revenue changes

## Usage

### Setup

```bash
# Install dependencies
pip install -r requirements.txt

# Create PostgreSQL database
CREATE DATABASE walmart_db;
```

### Run Data Pipeline

```bash
# Open and run the Jupyter notebook
jupyter notebook project.ipynb
```

Update database connection string in the notebook with your credentials:
```python
# PostgreSQL  
engine = create_engine("postgresql+psycopg2://user:password@localhost:5432/walmart_db")
```

### Example Queries

**Payment method analysis:**
```sql
SELECT payment_method, COUNT(*) AS transactions, SUM(quantity) AS items_sold
FROM walmart 
GROUP BY payment_method;
```

**Top-rated categories by branch:**
```sql
SELECT branch, category, AVG(rating) as avg_rating
FROM walmart 
GROUP BY branch, category
ORDER BY avg_rating DESC;
```

**Revenue decline detection:**
```sql
-- See PSQL Queries.sql for full year-over-year analysis
```

## Technical Overview

**Languages & Libraries:**
- Python 3.8+
- pandas (data manipulation)
- SQLAlchemy (database connections)
- psycopg2 (PostgreSQL adapter)

**Database:**
- PostgreSQL 12+

**Data Processing:**
- Jupyter Notebook for interactive development
- CSV input/output for data portability

## Database Schema

The `walmart` table contains these columns:

```sql
invoice_id      INT
branch          VARCHAR
city            VARCHAR  
category        VARCHAR
unit_price      DECIMAL
quantity        INT
date            VARCHAR
time            VARCHAR
payment_method  VARCHAR
rating          DECIMAL
profit_margin   DECIMAL
total           DECIMAL (calculated: unit_price * quantity)
```

Sample data covers multiple branches across different cities with transactions from 2019-2023.

## Key Decisions / Notes

**PostgreSQL Choice** - Used PostgreSQL for its advanced analytics functions and JSON support. Good for complex queries.

**Data Cleaning** - I drop incomplete records instead of guessing missing values. Financial data needs to be accurate.

**Query Order** - Start with basic stats, build up to complex analysis. Organized by business area.

**Performance** - Queries run fast on 10K records. Use window functions where needed but keep it simple.

## Contact & Support

**Maintainer:** Diyako Gilibagu

For questions about setup, queries, or extending the analysis, reach out through GitHub issues or email.
