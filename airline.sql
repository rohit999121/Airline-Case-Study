-- Problem Statement: The marketing team launched a special "2018 Promotion" campaign. Compare the flight frequencies and point redemptions of members who enrolled via the 2018 Promotion against those who enrolled via Standard methods during the year 2018. Provide the total member counts, average monthly flights, and average monthly points redeemed. 

select
clh.Enrollment_Type,
    COUNT(DISTINCT clh.Loyalty_Number) AS Total_Members,
    ROUND(AVG(cfa.`Total Flights`), 2) AS Avg_Monthly_Flights,
    ROUND(AVG(cfa.`Points Redeemed`), 2) AS Avg_Monthly_Points_Redeemed
from `dream11.cst_history` as clh
left join `dream11.cst_activity` as cfa
on clh.loyalty_number = cfa.`Loyalty Number` and clh.enrollment_year = 2018
group by enrollment_type




-- Question 3 (Difficulty: Medium-Hard) — Year-over-Year (YoY) Growth Metrics per Tier
-- Problem Statement: Calculate the Year-over-Year (YoY) percentage growth in Total Flights and Points Accumulated for each tier of Loyalty Card (Star, Nova, Aurora) from 2017 to 2018. The result should display the growth figures using a pivoted format.

-- Business Value: Understands whether the high-tier cards (Aurora) are outperforming or growing faster than entry-level tiers (Star).

WITH Tier_Yearly_Agg AS (
    SELECT 
        clh.Loyalty_Card,
        cfa.Year,
        SUM(cfa.`Total Flights`) AS Total_Flights,
        SUM(cfa.`Points Accumulated`) AS Total_Points
    FROM dream11.cst_activity cfa
    JOIN `dream11.cst_history` clh ON cfa.`Loyalty Number` = clh.Loyalty_Number
    WHERE cfa.Year IN (2017, 2018)
    GROUP BY clh.Loyalty_Card, cfa.Year
)
SELECT 
    t17.Loyalty_Card,
    t17.Total_Flights AS Flights_2017,
    t18.Total_Flights AS Flights_2018,
    ROUND(((t18.Total_Flights - t17.Total_Flights) * 100.0) / t17.Total_Flights, 2) AS Flight_Growth_Pct,
    ROUND(((t18.Total_Points - t17.Total_Points) * 100.0) / t17.Total_Points, 2) AS Points_Growth_Pct
FROM Tier_Yearly_Agg t17
JOIN Tier_Yearly_Agg t18 
    ON t17.Loyalty_Card = t18.Loyalty_Card AND t17.Year = 2017 AND t18.Year = 2018;


-- Question 4 (Difficulty: Hard) — High-Value Customer Profiling
-- Problem Statement: Segment the 2018 customer base based on their total annual Points Accumulated. Isolate the Top 5% highest point earners using window percentiles (PERCENT_RANK or NTILE). Compare this Elite segment to the Remaining 95% in terms of average points earned, average annual Salary, and average Customer Lifetime Value (CLV).

-- Note: Since some salary numbers are missing, exclude missing values from the salary calculation.

-- Business Value: Profiles user demographics to test whether high earning velocity aligns with higher real-world incomes.

WITH Member_Points_2018 AS (
    SELECT 
        `Loyalty Number`,
        SUM(`Points Accumulated`) AS Total_Points_2018
    FROM `dream11.cst_activity`
    WHERE Year = 2018
    GROUP BY `Loyalty Number`
),
Ranked_Members AS (
    SELECT 
        mp.*,
        PERCENT_RANK() OVER (ORDER BY mp.Total_Points_2018 DESC) as Pct_Rank
    FROM Member_Points_2018 mp
)
SELECT 
    CASE WHEN rm.Pct_Rank <= 0.05 THEN 'Top 5% Elite' ELSE 'Remaining 95%' END AS Customer_Segment,
    COUNT(rm.`Loyalty Number`) AS Total_Members,
    ROUND(AVG(rm.Total_Points_2018), 2) AS Avg_Points,
    ROUND(AVG(clh.Salary), 2) AS Avg_Salary,
    ROUND(AVG(clh.CLV), 2) AS Avg_CLV
FROM Ranked_Members rm
JOIN `dream11.cst_history` clh ON rm.`Loyalty Number` = clh.Loyalty_Number
GROUP BY CASE WHEN rm.Pct_Rank <= 0.05 THEN 'Top 5% Elite' ELSE 'Remaining 95%' END;


-- Question 5 (Difficulty: Hard) — Time-Series Rolling Flight Density
-- Problem Statement: For the year 2018, calculate the monthly total flights taken by each Loyalty Card status. Then, calculate a 3-month rolling sum of flights (consisting of the current month and the previous two months) for each card type using window frames. Show the output for the first six months of the year.

-- Business Value: Smooths out random monthly variance to identify genuine demand/seasonal ramps per card category.

WITH Monthly_Card_Activity AS (
    SELECT 
        clh.Loyalty_Card,
        cfa.Month,
        SUM(cfa.Total_Flights) AS Monthly_Flights
    FROM `dream11.cst_activity` cfa
    JOIN `dream11.cst_history` clh ON cfa.Loyalty_Number = clh.Loyalty_Number
    WHERE cfa.Year = 2018
    GROUP BY clh.Loyalty_Card, cfa.Month
)
SELECT 
    Loyalty_Card,
    Month,
    Monthly_Flights,
    SUM(Monthly_Flights) OVER (
        PARTITION BY Loyalty_Card 
        ORDER BY Month 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS Rolling_3_Month_Flights
FROM Monthly_Card_Activity
WHERE Month <= 6
ORDER BY Loyalty_Card, Month;

-- Question 6 (Difficulty: Hard) — Identifying Sudden Activity Spikes (Anomalies)
-- Problem Statement: Find individual cases where a loyalty member experienced an extreme surge in travel. Write a query to flag all instances where a member accumulated over 10,000 more points than they did in the immediate previous calendar month (accounting for chronological order across years). Return the total instance count and an example snippet.

-- Business Value: Helps fraud and marketing engines capture rapid changes in client status (e.g., sudden travel requirements or commercial re-selling behavior).
WITH Chronological_Activity AS (
    SELECT 
        `Loyalty Number`,
        Year,
        Month,
        `Points Accumulated`,
        LAG(Points_Accumulated, 1) OVER (
            PARTITION BY `Loyalty Number` 
            ORDER BY Year, Month
        ) AS Prev_Month_Points
    FROM dream11.cst_activity
)
SELECT 
    Loyalty_Number,
    Year,
    Month,
    Points_Accumulated,
    Prev_Month_Points,
    (Points_Accumulated - Prev_Month_Points) AS Points_Spike
FROM Chronological_Activity
WHERE (Points_Accumulated - Prev_Month_Points) > 10000
ORDER BY Points_Spike DESC;


WITH City_Point_Metrics AS (
    SELECT 
        h.City,
        SUM(a.Points_Accumulated) AS Total_Accumulated,
        SUM(a.Points_Redeemed) AS Total_Redeemed
    FROM dream11.cst_history h
    JOIN dream11.cst_activity a ON h.Loyalty_Number = a.Loyalty_Number
    WHERE a.Year = 2018
    GROUP BY h.City
    HAVING SUM(a.Points_Accumulated) >= 50000
)
SELECT 
    City,
    Total_Accumulated,
    Total_Redeemed,
    ROUND((Total_Redeemed * 100.0) / Total_Accumulated, 2) AS Point_Burn_Percentage
FROM City_Point_Metrics
ORDER BY Point_Burn_Percentage DESC
LIMIT 10;


-- Problem Statement: Perform a cohort analysis for members who enrolled between 2013 and 2017. For each enrollment year cohort, calculate the total number of members acquired, how many of those members remained active by taking at least one flight in 2018, and the resulting cohort retention rate percentage.

-- Business Value: Helps lifecycle marketing teams understand which historical signup years produced the most loyal long-term customers and where engagement curves begin to decay.

SELECT 
    h.Enrollment_Year,
    COUNT(DISTINCT h.Loyalty_Number) AS Total_Enrolled_Members,
    COUNT(DISTINCT CASE WHEN a.`Total Flights` > 0 AND a.Year = 2018 THEN h.Loyalty_Number END) AS Active_Members_2018,
    ROUND(
        COUNT(DISTINCT CASE WHEN a.`Total Flights` > 0 AND a.Year = 2018 THEN h.Loyalty_Number END) * 100.0 
        / COUNT(DISTINCT h.Loyalty_Number), 2
    ) AS Cohort_Retention_Percentage
FROM dream11.cst_history h
LEFT JOIN dream11.cst_activity a ON h.Loyalty_Number = a.`Loyalty Number`
WHERE h.Enrollment_Year BETWEEN 2013 AND 2017
GROUP BY h.Enrollment_Year
ORDER BY h.Enrollment_Year ASC;

-- Regional Point Burn-Rate IndexProblem Statement: The finance department tracks the "Point Burn Rate" (Total Points Redeemed divided by Total Points Accumulated). Find the Top 10 Cities with the highest point burn-rate percentage during the year 2018. To eliminate outliers, only include cities that accumulated a cumulative total of at least $50,000$ points in 2018.Business Value: Identifies high-liability geographic zones where customers are rapidly converting loyalty points into financial costs for the airline.

WITH City_Point_Metrics AS (
    SELECT 
        h.City,
        SUM(a.`Points Accumulated`) AS Total_Accumulated,
        SUM(a.`Points Redeemed`) AS Total_Redeemed
    FROM dream11.cst_history h
    JOIN dream11.cst_activity a ON h.Loyalty_Number = a.`Loyalty Number`
    WHERE a.Year = 2018
    GROUP BY h.City
    HAVING SUM(a.`Points Accumulated`) >= 50000
)
SELECT 
    City,
    Total_Accumulated,
    Total_Redeemed,
    ROUND((Total_Redeemed * 100.0) / Total_Accumulated, 2) AS Point_Burn_Percentage
FROM City_Point_Metrics
ORDER BY Point_Burn_Percentage DESC
LIMIT 10;


-- Segment Efficiency & Demographic Profiling
-- Problem Statement: Analyze user travel efficiency based on demographic segments. For each Education level tier, calculate the total unique customer count, their average Customer Lifetime Value (CLV), and the average distance traveled per flight across their entire activity history. Sort the output by average CLV in descending order.

-- Business Value: Determines if specific demographic groups yield a higher return on flight distance or carry higher overall lifetime equity, optimizing customer persona targeting.

SELECT 
    h.Education,
    COUNT(DISTINCT h.Loyalty_Number) AS Total_Unique_Members,
    ROUND(AVG(h.CLV), 2) AS Avg_Customer_Lifetime_Value,
    ROUND(SUM(a.Distance) * 1.0 / NULLIF(SUM(a.`Total Flights`), 0), 2) AS Avg_Km_Per_Flight
FROM dream11.cst_history h
JOIN dream11.cst_activity a ON h.Loyalty_Number = a.`Loyalty Number`
GROUP BY h.Education
ORDER BY Avg_Customer_Lifetime_Value DESC;

-- Consistent High-Frequency Flyer Detection
-- Problem Statement: Identify highly consistent customer behaviors. Write a query to count how many unique loyalty members flew at least one flight for 3 consecutive months within the calendar year 2018.

-- Business Value: Pinpoints the hyper-active core segment of customers. This core metric can be used to isolate users for premium subscription upgrades or executive club invitations.

WITH Monthly_Active_Flags AS (
    SELECT DISTINCT
        `Loyalty Number`,
        Month
    FROM dream11.cst_activity
    WHERE Year = 2018 AND `Total Flights` > 0
),
Consecutive_Timeline AS (
    SELECT 
        `Loyalty Number`,
        Month,
        LAG(Month, 1) OVER (PARTITION BY `Loyalty Number` ORDER BY Month) AS Prev_Month_1,
        LAG(Month, 2) OVER (PARTITION BY `Loyalty Number` ORDER BY Month) AS Prev_Month_2
    FROM Monthly_Active_Flags
)
SELECT 
    COUNT(DISTINCT `Loyalty Number`) AS Consistent_3Month_Flyers_Count
FROM Consecutive_Timeline
WHERE Month = Prev_Month_1 + 1 
  AND Prev_Month_1 = Prev_Month_2 + 1;



-- Financial Exposure Ratio per Loyalty Tier
-- Problem Statement: Evaluate the program’s financial impact. For the year 2018, calculate the total financial liability generated from point cash-outs (Dollar_Cost_Points_Redeemed) for each Loyalty_Card tier. Then, calculate what percentage this 2018 redemption cost represents against that tier's collective total Customer Lifetime Value (CLV).

-- Business Value: Monitors financial margins to check if lower-tier point redemptions are disproportional to their total historical invoice equity.

WITH Tier_2018_Redemptions AS (
    SELECT 
        h.Loyalty_Card,
        SUM(a.`Dollar Cost Points Redeemed`) AS Total_Redemption_Cost_2018
    FROM dream11.cst_history h
    JOIN dream11.cst_activity a ON h.Loyalty_Number = a.`Loyalty Number`
    WHERE a.Year = 2018
    GROUP BY h.Loyalty_Card
),
Tier_Total_Equity AS (
    SELECT 
        Loyalty_Card,
        SUM(CLV) AS Total_Historical_CLV
    FROM dream11.cst_history
    GROUP BY Loyalty_Card
)
SELECT 
    r.Loyalty_Card,
    r.Total_Redemption_Cost_2018,
    e.Total_Historical_CLV,
    ROUND((r.Total_Redemption_Cost_2018 * 100.0) / e.Total_Historical_CLV, 4) AS Liability_To_CLV_Ratio_Pct
FROM Tier_2018_Redemptions r
JOIN Tier_Total_Equity e ON r.Loyalty_Card = e.Loyalty_Card
ORDER BY Liability_To_CLV_Ratio_Pct DESC;

