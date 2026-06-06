

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

select count(*) from Customer_Loyalty_History
where Cancellation_Year is null



