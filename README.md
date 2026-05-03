# sql-analytics-portfolio
Description: SQL analytics queries covering e-commerce, retention, and funnel analysis

# SQL Analytics Portfolio
A collection of SQL queries demonstrating analytics engineering skills across 
e-commerce, retention, and funnel analysis use cases.

## Dataset
Queries are written against the [Brazilian E-Commerce Dataset (Olist)](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) 
available on Kaggle. Download and load into your local SQL environment to run queries.

## Structure

### 01_basic
Foundational SQL patterns including joins, aggregations, and time series analysis.
- `01_joins_and_aggregations.sql` — Revenue and order analysis by customer segment and product category

### 02_intermediate
CTEs and subqueries for multi-step analytical problems.
- `01_cte_and_subqueries.sql` — High value customer identification and category analysis

### 03_advanced
Window functions for ranking, running totals, and period-over-period analysis.
- `01_window_functions.sql` — Customer spend ranking, running revenue, MoM growth, top products per category

### 04_analytics
End-to-end analytical use cases modeled after real business problems.
- `01_cohort_retention.sql` — Cohort-based retention analysis to track customer lifecycle
- `02_funnel_analysis.sql` — Purchase funnel conversion rates by stage, device, and weekly trend

## Skills Demonstrated
- Joins, aggregations, filtering
- CTEs and subqueries
- Window functions — RANK, LAG, running totals, PARTITION BY
- Cohort analysis and retention modeling
- Funnel analysis and conversion optimization
- Time series trending and MoM analysis

## Author
Yang Chen | [LinkedIn](https://linkedin.com/in/yang-chen-646780237)
