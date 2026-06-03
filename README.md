# Airline-Case-Study

# ✈️ Airline Loyalty Program Data Analytics Case Study (SQL)

## 📌 Project Overview
This repository contains an end-to-end SQL case study evaluating customer behavior, promotional effectiveness, time-series flight trends, and regional retention rates for a commercial airline's loyalty program across **2017 and 2018**. 

The goal of this project is to simulate a real-world business environment where an analytics team must dive past basic reporting to extract data-driven, strategic insights that impact marketing budgets, product tiers, and customer lifecycle management.

---

## Data Cleaning & Preprocessing Pipeline (SQL)
Before running strategic business queries, the raw transactional logs and customer profiles required rigorous cleaning to ensure data quality, relational integrity, and standard data types. The preprocessing pipeline was executed using the following SQL commands:

### 1. Handling Missing Profiles & Null Value Transformation
Missing values in the `Salary` column were preserved as `NULL` to avoid biasing income aggregations. However, missing values in the cancellation timeline were explicitly managed using conditional handling to cleanly distinguish active accounts from churned ones.


CREATE TABLE customer_loyalty_history (
    loyalty_number BIGINT PRIMARY KEY,
    country VARCHAR(50),
    province VARCHAR(50),
    city VARCHAR(100),
    postal_code VARCHAR(20),
    gender VARCHAR(20),
    education VARCHAR(50),
    salary NUMERIC,
    marital_status VARCHAR(30),
    loyalty_card VARCHAR(30),
    clv NUMERIC,
    enrollment_type VARCHAR(30),
    enrollment_year INT,
    enrollment_month INT,
    cancellation_year INT,
    cancellation_month INT
);

CREATE TABLE customer_flight_activity (
    loyalty_number BIGINT,
    year INT,
    month INT,
    total_flights INT,
    distance INT,
    points_accumulated INT,
    points_reddemed NUMERIC,
    dollar_cost_points_redeemed NUMERIC
);


select * from customer_flight_activity;
select * from customer_loyalty_history;

--couting the number of rows.
select count(*) from customer_flight_activity;
select count(*) from customer_loyalty_history;


--identifying the null values
SELECT
    COUNT(*) AS Total_Records,
    COUNT(Salary) AS Salary_Not_Null,
    COUNT(*) - COUNT(Salary) AS Salary_Null,
    COUNT(Cancellation_Year) AS Cancellation_Year_Not_Null,
    COUNT(*) - COUNT(Cancellation_Year) AS Cancellation_Year_Null,
    COUNT(Cancellation_Month) AS Cancellation_Month_Not_Null,
    COUNT(*) - COUNT(Cancellation_Month) AS Cancellation_Month_Null
FROM Customer_Loyalty_History;

SELECT
    ROUND(
        COUNT(*) FILTER (WHERE Salary IS NULL) * 100.0 / COUNT(*),
        2
    ) AS Salary_Null_Percentage
FROM Customer_Loyalty_History

update Customer_Loyalty_History
set salary = (
select avg(salary) from Customer_Loyalty_History
)
where salary is null;

update Customer_Loyalty_History
set Cancellation_Month = COALESCE(Cancellation_Month,0)

update Customer_Loyalty_History
set Cancellation_Year = COALESCE(Cancellation_Month,0)


# Airline Loyalty Program Analysis using SQL

## Project Overview

This project analyzes customer behavior within an airline loyalty program using advanced SQL techniques. The objective is to generate business insights from customer enrollment, flight activity, loyalty card performance, reward redemption patterns, and customer value segmentation.

The analysis focuses on solving real-world business problems through SQL concepts such as:

* Joins and Aggregations
* Common Table Expressions (CTEs)
* Window Functions
* Percentile-Based Segmentation
* Rolling Calculations
* Time-Series Analysis
* Anomaly Detection

The project uses customer history and activity datasets to evaluate loyalty program effectiveness and identify opportunities for customer retention, revenue growth, and operational optimization.

---

## Key Findings from the Airline Case Study

### 1. Enrollment Campaign Performance Analysis

The project compares members who enrolled through the **2018 Promotion Campaign** against those who enrolled through **Standard Enrollment Methods**.

Insights generated include:

* Total members acquired through each enrollment channel.
* Average monthly flights per member.
* Average monthly points redeemed per member.

This analysis helps determine whether promotional acquisition campaigns attract more active and engaged customers.

---

### 2. Loyalty Card Growth Analysis

Year-over-Year growth between 2017 and 2018 was analyzed for the following loyalty card tiers:

* Star
* Nova
* Aurora

Metrics evaluated:

* Total Flights Growth %
* Points Accumulated Growth %

The analysis highlights which loyalty tier experienced the strongest customer engagement growth and whether premium tiers are outperforming entry-level memberships.

---

### 3. High-Value Customer Segmentation

Customers were ranked according to their total points accumulated during 2018.

Using percentile ranking:

* Top 5% highest point earners were classified as the **Elite Segment**
* Remaining 95% were classified as the **General Segment**

The following metrics were compared:

* Average annual points earned
* Average salary
* Average Customer Lifetime Value (CLV)

This profiling helps understand whether highly engaged customers also represent higher long-term business value.

---

### 4. Rolling Flight Density Analysis

A time-series analysis was performed to calculate:

* Monthly flights by loyalty card type
* Three-month rolling flight totals

The rolling window approach reduces short-term fluctuations and reveals underlying demand trends across different customer tiers.

---

### 5. Travel Activity Spike Detection

An anomaly detection query identified members who accumulated:

* More than 10,000 additional points compared to the immediately previous month.

This analysis helps identify:

* Sudden changes in customer travel behavior
* Potential fraud indicators
* High-value business travelers
* Customers experiencing major increases in travel frequency

---

## Actionable Recommendations

### 1. Optimize Promotional Enrollment Campaigns

If customers acquired through the 2018 Promotion demonstrate higher flight activity and redemption rates, future marketing investments should prioritize similar acquisition campaigns to maximize engagement.

### 2. Strengthen High-Performing Loyalty Tiers

Loyalty card tiers showing stronger Year-over-Year growth should receive additional investment through targeted benefits, upgrades, and retention programs.

### 3. Develop Elite Customer Retention Strategies

The Top 5% customer segment represents the most valuable travelers. Personalized rewards, premium services, and exclusive offers should be implemented to increase retention and lifetime value.

### 4. Leverage Rolling Demand Trends

Three-month rolling flight patterns can be used for better forecasting, capacity planning, and seasonal campaign execution.

### 5. Monitor Sudden Activity Surges

Customers exhibiting large month-over-month point increases should be tracked through automated monitoring systems to identify both business opportunities and unusual activity patterns.

---

## SQL Concepts Demonstrated

* INNER JOIN & LEFT JOIN
* GROUP BY & Aggregations
* CTEs (Common Table Expressions)
* Window Functions

  * LAG()
  * PERCENT_RANK()
  * SUM() OVER()
* Rolling Window Calculations
* Time-Series Analysis
* Customer Segmentation
* Anomaly Detection
* Business-Oriented Data Analytics

---

## Business Value

This project demonstrates how SQL can be used to transform raw airline loyalty data into actionable business insights that support:

* Customer Acquisition Strategy
* Loyalty Program Optimization
* Revenue Growth Initiatives
* Customer Retention Programs
* Demand Forecasting
* Fraud and Anomaly Detection

The analysis reflects practical scenarios commonly encountered in Data Analyst and Business Intelligence roles.
