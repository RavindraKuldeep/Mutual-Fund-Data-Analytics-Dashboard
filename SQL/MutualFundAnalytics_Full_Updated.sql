/*
===============================================================================
MUTUAL FUND ANALYTICS - UPDATED MASTER SQL SCRIPT
===============================================================================

Update included:
1. One-Year Total Return
2. Three-Year Total Return
3. Five-Year Total Return
4. Three-Year CAGR
5. Five-Year CAGR
6. Existing Weighted Performance Score and Category Rank retained
7. Total-return columns exposed in final Power BI scheme and category views

Analysis Period:
15-06-2021 to 15-06-2026
===============================================================================
*/

CREATE DATABASE MutualFundAnalytics;
GO

USE MutualFundAnalytics;
GO


CREATE TABLE NAV_Data (
    Category NVARCHAR(100),
    Scheme_Code NVARCHAR(50),
    Scheme_Name NVARCHAR(300),
    NAV_Date DATE,
    NAV DECIMAL(18,4)
);


BULK INSERT NAV_data
FROM 'C:\Users\hp\Desktop\Mutual_Fund_Project\Processed_Data\Processed_NAV_Data_SQL.csv'
WITH (
FIRSTROW = 2,
FIELDTERMINATOR = ',' ,
ROWTERMINATOR = '0x0a' ,
TABLOCK
    );


SELECT COUNT(*) AS Total_Rows
FROM NAV_Data;


SELECT COUNT(DISTINCT Scheme_Code) AS Total_Schemes
FROM NAV_Data;


SELECT Scheme_Code, Scheme_Name, COUNT(*) AS Row_Count
FROM NAV_Data
GROUP BY Scheme_Code, Scheme_Name
ORDER BY Row_Count;

SELECT COUNT(DISTINCT Category) AS Total_Categories
FROM NAV_Data;

SELECT 
    MIN(NAV_Date) AS Start_Date,
    MAX(NAV_Date) AS End_Date
FROM NAV_Data;


SELECT TOP 10 *
FROM NAV_Data;

-- MAIN QUERY 01: Category-wise Unique Schemes Count

-- English: This query shows the number of unique mutual fund schemes in each category.
-- Hinglish: Ye query har category me kitni unique mutual fund schemes hain wo dikhati hai.

SELECT 
    Category,
    COUNT(DISTINCT Scheme_Code) AS Total_Schemes
FROM NAV_Data
GROUP BY Category
ORDER BY Total_Schemes DESC;


-- MAIN QUERY 02: Category-wise NAV Records Count

-- English: This query shows the number of NAV records available in each category.
-- Hinglish: Ye query har category me kitne NAV records available hain wo dikhati hai.

SELECT 
    Category,
    COUNT(*) AS Total_NAV_Records
FROM NAV_Data
GROUP BY Category
ORDER BY Total_NAV_Records DESC;

-- MAIN QUERY 03: Overall Dataset Summary

-- English: This query shows the overall summary of the dataset including total rows,
                -- schemes, categories, and analysis period.
-- Hinglish: Ye query dataset ka overall summary dikhati hai jisme total rows, schemes,
                -- categories aur analysis period shamil hai.

SELECT
    COUNT(*) AS Total_Rows,
    COUNT(DISTINCT Scheme_Code) AS Total_Schemes,
    COUNT(DISTINCT Category) AS Total_Categories,
    MIN(NAV_Date) AS Start_Date,
    MAX(NAV_Date) AS End_Date
FROM NAV_Data;

/*
MAIN QUERY 04: Scheme-wise NAV Records Count

English: This query shows the number of NAV records available for each mutual fund
scheme.

Hinglish: Ye query har mutual fund scheme ke liye available NAV records ki sankhya
dikhati hai.
*/

SELECT
    Scheme_Code,
    Scheme_Name,
    COUNT(*) AS Total_NAV_Records
FROM NAV_Data
GROUP BY Scheme_Code, Scheme_Name
ORDER BY Total_NAV_Records DESC;

/*
MAIN QUERY 05: Top 10 Schemes by Latest NAV

English: This query shows the top 10 mutual fund schemes having the highest NAV value.

Hinglish: Ye query sabse zyada NAV value wali top 10 mutual fund schemes dikhati hai.
*/

SELECT TOP 10
    Scheme_Code,
    Scheme_Name,
    NAV
FROM NAV_Data
ORDER BY NAV DESC;

/*
MAIN QUERY 06: Top 10 Schemes by Latest NAV

English: This query shows the top 10 mutual fund schemes based on their NAV value
on the latest analysis date.

Hinglish: Ye query latest analysis date ke NAV ke basis par top 10 mutual fund 
schemes dikhati hai.
*/

SELECT TOP 10
    Scheme_Code,
    Scheme_Name,
    NAV_Date,
    NAV
FROM NAV_Data
WHERE NAV_Date = (
    SELECT MAX(NAV_Date)
    FROM NAV_Data
)
ORDER BY NAV DESC;


/*
==========================================================
IMPORTANT ANALYTICS NOTE
==========================================================

English:
High NAV does not mean a better mutual fund.
NAV is influenced by fund age, growth history, and fund structure.

For actual mutual fund performance analysis, Return and CAGR
are more important than NAV.

Hinglish:
High NAV ka matlab ye nahi hota ki fund better hai.
NAV fund ki age, growth history aur structure par depend karta hai.

Actual mutual fund analysis ke liye NAV se zyada
Return aur CAGR important hote hain.

==========================================================
NEXT ANALYTICS PHASE
==========================================================

1. Latest NAV Analysis
2. Return Analysis
3. CAGR Analysis
4. Category Comparison
5. Risk Analysis
6. Performance Ranking

==========================================================
*/

/*
MAIN QUERY 07: Latest NAV of Each Scheme

English:
This query shows the latest available NAV for each mutual fund scheme.

Hinglish:
Ye query har mutual fund scheme ka latest available NAV dikhati hai.

Purpose:
This query creates the foundation for Return, CAGR, Ranking,
and Power BI performance analysis.
*/

SELECT
    Scheme_Code,
    Scheme_Name,
    MAX(NAV_Date) AS Latest_Date,
    MAX(NAV) AS Latest_NAV
FROM NAV_Data
GROUP BY Scheme_Code, Scheme_Name
ORDER BY Latest_NAV DESC;


/*
MAIN QUERY 08: Exact Latest NAV per Scheme

English:
This query returns the exact NAV value available on the latest NAV date for
each mutual fund scheme.

Hinglish:
Ye query har mutual fund scheme ke latest NAV date par available exact NAV value
dikhati hai.

Purpose:
This is more accurate than using MAX(NAV), because the highest NAV is not
always the latest NAV.
*/

SELECT
    n.Scheme_Code,
    n.Scheme_Name,
    n.NAV_Date AS Latest_Date,
    n.NAV AS Latest_NAV
FROM NAV_Data n
INNER JOIN (
    SELECT
        Scheme_Code,
        MAX(NAV_Date) AS Latest_Date
    FROM NAV_Data
    GROUP BY Scheme_Code
) latest
    ON n.Scheme_Code = latest.Scheme_Code
   AND n.NAV_Date = latest.Latest_Date
ORDER BY n.NAV DESC;

/*
MAIN QUERY 09: Five-Year Return per Scheme

English:
This query calculates the 5-year return percentage for each mutual fund
scheme using start NAV and end NAV.

Hinglish:
Ye query har mutual fund scheme ka start NAV aur end NAV use karke 5-year
return percentage calculate karti hai.

Formula:
Return % = ((End NAV - Start NAV) / Start NAV) * 100
*/

SELECT
    Scheme_Code,
    Scheme_Name,
    MIN(NAV_Date) AS Start_Date,
    MAX(NAV_Date) AS End_Date,
    MIN(NAV) AS Start_NAV,
    MAX(NAV) AS End_NAV,
    ((MAX(NAV) - MIN(NAV)) / MIN(NAV)) * 100 AS Five_Year_Return_Percent
FROM NAV_Data
GROUP BY Scheme_Code, Scheme_Name
ORDER BY Five_Year_Return_Percent DESC;


/*
MAIN QUERY 10: Five-Year Return per Scheme - Professional Version

English:
This query calculates 5-year return using exact start-date NAV and exact 
end-date NAV for each scheme.

Hinglish:
Ye query har scheme ka exact start-date NAV aur exact end-date NAV use karke
5-year return calculate karti hai.
*/

SELECT
    start_nav.Scheme_Code,
    start_nav.Scheme_Name,
    start_nav.NAV_Date AS Start_Date,
    start_nav.NAV AS Start_NAV,
    end_nav.NAV_Date AS End_Date,
    end_nav.NAV AS End_NAV,
    ((end_nav.NAV - start_nav.NAV) / start_nav.NAV) * 100 AS Five_Year_Return_Percent
FROM NAV_Data start_nav
INNER JOIN NAV_Data end_nav
    ON start_nav.Scheme_Code = end_nav.Scheme_Code
WHERE start_nav.NAV_Date = '2021-06-15'
  AND end_nav.NAV_Date = '2026-06-15'
ORDER BY Five_Year_Return_Percent DESC;



/*
NAV ADJUSTMENT TABLE

English:
This table stores adjustment details for schemes affected
by unit splits or face-value changes.

Hinglish:
Ye table un schemes ki adjustment details store karegi
jinme unit split ya face-value change hua hai.
*/

CREATE TABLE NAV_Adjustments
(
    Scheme_Code NVARCHAR(50) PRIMARY KEY,
    Apply_Before_Date DATE NOT NULL,
    Adjustment_Factor DECIMAL(18,6) NOT NULL,
    Adjustment_Reason NVARCHAR(300)
);

select * from NAV_Adjustments


/*
NAV ADJUSTMENT RECORDS

English:
This query inserts adjustment factors for schemes affected
by face-value changes.

Hinglish:
Ye query face-value change wali schemes ke adjustment
factors table me insert karti hai.
*/

INSERT INTO NAV_Adjustments
(
    Scheme_Code,
    Apply_Before_Date,
    Adjustment_Factor,
    Adjustment_Reason
)
VALUES
(
    '112368',
    '2026-05-01',
    0.01,
    'Invesco India Gold ETF face value changed from Rs.100 to Re.1'
),
(
    '145536',
    '2022-08-16',
    10.00,
    'ICICI Prudential Overnight Fund face value changed from Rs.100 to Rs.1000'
);


/*
CREATE VIEW: Adjusted NAV Data

English:
This view keeps the original NAV unchanged and calculates adjusted NAV
for schemes affected by face-value changes.

Hinglish:
Ye view original NAV ko change nahi karti aur face-value change wali
schemes ke liye adjusted NAV calculate karti hai.
*/

GO

CREATE OR ALTER VIEW dbo.vw_NAV_Data_Adjusted
AS

SELECT
    n.Category,
    n.Scheme_Code,
    n.Scheme_Name,
    n.NAV_Date,
    n.NAV AS Raw_NAV,

    CASE
        WHEN a.Scheme_Code IS NOT NULL
             AND n.NAV_Date < a.Apply_Before_Date
        THEN n.NAV * a.Adjustment_Factor

        ELSE n.NAV
    END AS Adjusted_NAV

FROM dbo.NAV_Data n

LEFT JOIN dbo.NAV_Adjustments a
    ON n.Scheme_Code = a.Scheme_Code;
GO


/*
VERIFY ADJUSTED NAV VIEW

English:
This query compares raw and adjusted NAV values for the two affected schemes.

Hinglish:
Ye query dono affected schemes ka raw NAV aur adjusted NAV compare karti hai.
*/

SELECT
    Scheme_Code,
    Scheme_Name,
    NAV_Date,
    Raw_NAV,
    Adjusted_NAV
FROM dbo.vw_NAV_Data_Adjusted
WHERE Scheme_Code IN ('112368', '145536')
  AND NAV_Date IN ('2021-06-15', '2026-06-15')
ORDER BY Scheme_Code, NAV_Date;


/*
MAIN QUERY 10: Adjusted Five-Year Return and CAGR

English:
This query calculates the correct five-year total return and CAGR
using corporate-action-adjusted NAV values.

Hinglish:
Ye query corporate-action-adjusted NAV values use karke correct
5-year total return aur CAGR calculate karti hai.
*/

SELECT
    start_nav.Category,
    start_nav.Scheme_Code,
    start_nav.Scheme_Name,

    start_nav.NAV_Date AS Start_Date,
    start_nav.Adjusted_NAV AS Start_NAV,

    end_nav.NAV_Date AS End_Date,
    end_nav.Adjusted_NAV AS End_NAV,

    ROUND(
        (
            (end_nav.Adjusted_NAV - start_nav.Adjusted_NAV)
            / NULLIF(start_nav.Adjusted_NAV, 0)
        ) * 100,
        2
    ) AS Five_Year_Total_Return_Percent,

    ROUND(
        (
            POWER(
                end_nav.Adjusted_NAV
                / NULLIF(start_nav.Adjusted_NAV, 0),
                1.0 / 5
            ) - 1
        ) * 100,
        2
    ) AS Five_Year_CAGR_Percent

FROM dbo.vw_NAV_Data_Adjusted start_nav

INNER JOIN dbo.vw_NAV_Data_Adjusted end_nav
    ON start_nav.Scheme_Code = end_nav.Scheme_Code

WHERE start_nav.NAV_Date = '2021-06-15'
  AND end_nav.NAV_Date = '2026-06-15'

ORDER BY Five_Year_CAGR_Percent DESC;



/*
MAIN QUERY 11: Create Five-Year Scheme Performance View

English:
This view stores scheme-wise five-year total return and CAGR
for the fixed analysis period.

Hinglish:
Ye view fixed analysis period ke liye har scheme ka
5-year total return aur CAGR calculate karke rakhegi.
*/

GO

CREATE OR ALTER VIEW dbo.vw_Scheme_Five_Year_Performance
AS

SELECT
    start_nav.Category,
    start_nav.Scheme_Code,
    start_nav.Scheme_Name,

    start_nav.NAV_Date AS Start_Date,
    start_nav.Adjusted_NAV AS Start_NAV,

    end_nav.NAV_Date AS End_Date,
    end_nav.Adjusted_NAV AS End_NAV,

    (
        (end_nav.Adjusted_NAV - start_nav.Adjusted_NAV)
        / NULLIF(start_nav.Adjusted_NAV, 0)
    ) * 100 AS Five_Year_Total_Return_Percent,

    (
        POWER(
            CAST(
                end_nav.Adjusted_NAV
                / NULLIF(start_nav.Adjusted_NAV, 0)
                AS FLOAT
            ),
            1.0 / 5
        ) - 1
    ) * 100 AS Five_Year_CAGR_Percent

FROM dbo.vw_NAV_Data_Adjusted start_nav

INNER JOIN dbo.vw_NAV_Data_Adjusted end_nav
    ON start_nav.Scheme_Code = end_nav.Scheme_Code

WHERE start_nav.NAV_Date = '2021-06-15'
  AND end_nav.NAV_Date = '2026-06-15';
GO


SELECT *
FROM dbo.vw_Scheme_Five_Year_Performance;



/*
VERIFY FIVE-YEAR PERFORMANCE VIEW

English:
This query displays the top 10 schemes based on five-year CAGR.

Hinglish:
Ye query 5-year CAGR ke basis par top 10 schemes dikhati hai.
*/

SELECT TOP 10
    Category,
    Scheme_Code,
    Scheme_Name,
    Start_NAV,
    End_NAV,
    ROUND(Five_Year_Total_Return_Percent, 2)
        AS Five_Year_Total_Return_Percent,
    ROUND(Five_Year_CAGR_Percent, 2)
        AS Five_Year_CAGR_Percent
FROM dbo.vw_Scheme_Five_Year_Performance
ORDER BY Five_Year_CAGR_Percent DESC;



/*
MAIN QUERY 12: Category-wise Five-Year Performance Summary

English:
This query summarizes five-year performance for every mutual fund
category using scheme count, average return, average CAGR,
minimum CAGR, and maximum CAGR.

Hinglish:
Ye query har mutual fund category ke schemes ka count,
average return, average CAGR, minimum CAGR aur maximum CAGR dikhati hai.
*/

SELECT
    Category,

    COUNT(DISTINCT Scheme_Code) AS Total_Schemes,

    ROUND(
        AVG(Five_Year_Total_Return_Percent),
        2
    ) AS Average_Five_Year_Total_Return_Percent,

    ROUND(
        AVG(Five_Year_CAGR_Percent),
        2
    ) AS Average_Five_Year_CAGR_Percent,

    ROUND(
        MIN(Five_Year_CAGR_Percent),
        2
    ) AS Minimum_Five_Year_CAGR_Percent,

    ROUND(
        MAX(Five_Year_CAGR_Percent),
        2
    ) AS Maximum_Five_Year_CAGR_Percent

FROM dbo.vw_Scheme_Five_Year_Performance

GROUP BY Category

ORDER BY Average_Five_Year_CAGR_Percent DESC;



/*
MAIN QUERY 13: Top Three Schemes in Each Category

English:
This query ranks schemes within their respective categories
and displays the top three schemes based on five-year CAGR.

Hinglish:
Ye query har category ke andar schemes ko 5-year CAGR ke basis
par rank karti hai aur top 3 schemes dikhati hai.
*/

WITH Ranked_Schemes AS
(
    SELECT
        Category,
        Scheme_Code,
        Scheme_Name,

        ROUND(
            Five_Year_Total_Return_Percent,
            2
        ) AS Five_Year_Total_Return_Percent,

        ROUND(
            Five_Year_CAGR_Percent,
            2
        ) AS Five_Year_CAGR_Percent,

        ROW_NUMBER() OVER
        (
            PARTITION BY Category
            ORDER BY Five_Year_CAGR_Percent DESC
        ) AS Category_Rank

    FROM dbo.vw_Scheme_Five_Year_Performance
)

SELECT
    Category,
    Category_Rank,
    Scheme_Code,
    Scheme_Name,
    Five_Year_Total_Return_Percent,
    Five_Year_CAGR_Percent

FROM Ranked_Schemes

WHERE Category_Rank <= 3

ORDER BY
    Category,
    Category_Rank;


/*
MAIN QUERY 14: Scheme Performance Compared with Category Average

English:
This query compares every scheme's five-year CAGR with the
average CAGR of its respective category.

Hinglish:
Ye query har scheme ke 5-year CAGR ko uski category ke
average CAGR ke saath compare karti hai.
*/

WITH Category_Average AS
(
    SELECT
        Category,
        AVG(Five_Year_CAGR_Percent) AS Category_Average_CAGR
    FROM dbo.vw_Scheme_Five_Year_Performance
    GROUP BY Category
)

SELECT
    s.Category,
    s.Scheme_Code,
    s.Scheme_Name,

    ROUND(
        s.Five_Year_CAGR_Percent,
        2
    ) AS Scheme_CAGR_Percent,

    ROUND(
        c.Category_Average_CAGR,
        2
    ) AS Category_Average_CAGR_Percent,

    ROUND(
        s.Five_Year_CAGR_Percent
        - c.Category_Average_CAGR,
        2
    ) AS Difference_From_Category_Average,

    CASE
        WHEN s.Five_Year_CAGR_Percent > c.Category_Average_CAGR
            THEN 'Above Category Average'

        WHEN s.Five_Year_CAGR_Percent < c.Category_Average_CAGR
            THEN 'Below Category Average'

        ELSE 'Equal to Category Average'
    END AS Performance_Status

FROM dbo.vw_Scheme_Five_Year_Performance s

INNER JOIN Category_Average c
    ON s.Category = c.Category

ORDER BY
    s.Category,
    Difference_From_Category_Average DESC;


/*
MAIN QUERY 15: Multi-Period Scheme Performance View

English:
This view calculates one-year, three-year, and five-year total return,
along with three-year and five-year CAGR, using the nearest available
NAV on or before each target date.

Hinglish:
Ye view har scheme ka 1-year, 3-year aur 5-year total return,
saath hi 3-year aur 5-year CAGR calculate karti hai.
Agar target date holiday ya Sunday ho, to usse pehle ki
nearest available NAV date use hoti hai.

Important:
For a one-year period, one-year total return and one-year annualized
return are numerically the same. The existing
One_Year_Return_Percent column is retained for backward compatibility.
*/

GO

CREATE OR ALTER VIEW dbo.vw_Scheme_Multi_Period_Performance
AS

WITH Scheme_List AS
(
    SELECT DISTINCT
        Category,
        Scheme_Code,
        Scheme_Name
    FROM dbo.vw_NAV_Data_Adjusted
)

SELECT
    s.Category,
    s.Scheme_Code,
    s.Scheme_Name,

    one_year.NAV_Date AS One_Year_Start_Date,
    one_year.Adjusted_NAV AS One_Year_Start_NAV,

    three_year.NAV_Date AS Three_Year_Start_Date,
    three_year.Adjusted_NAV AS Three_Year_Start_NAV,

    five_year.NAV_Date AS Five_Year_Start_Date,
    five_year.Adjusted_NAV AS Five_Year_Start_NAV,

    end_nav.NAV_Date AS End_Date,
    end_nav.Adjusted_NAV AS End_NAV,

    ROUND(
        (
            (end_nav.Adjusted_NAV - one_year.Adjusted_NAV)
            / NULLIF(one_year.Adjusted_NAV, 0)
        ) * 100,
        2
    ) AS One_Year_Return_Percent,

    ROUND(
        (
            (end_nav.Adjusted_NAV - one_year.Adjusted_NAV)
            / NULLIF(one_year.Adjusted_NAV, 0)
        ) * 100,
        2
    ) AS One_Year_Total_Return_Percent,

    ROUND(
        (
            (end_nav.Adjusted_NAV - three_year.Adjusted_NAV)
            / NULLIF(three_year.Adjusted_NAV, 0)
        ) * 100,
        2
    ) AS Three_Year_Total_Return_Percent,

    ROUND(
        (
            (end_nav.Adjusted_NAV - five_year.Adjusted_NAV)
            / NULLIF(five_year.Adjusted_NAV, 0)
        ) * 100,
        2
    ) AS Five_Year_Total_Return_Percent,

    ROUND(
        (
            POWER(
                CAST(
                    end_nav.Adjusted_NAV
                    / NULLIF(three_year.Adjusted_NAV, 0)
                    AS FLOAT
                ),
                1.0 / 3
            ) - 1
        ) * 100,
        2
    ) AS Three_Year_CAGR_Percent,

    ROUND(
        (
            POWER(
                CAST(
                    end_nav.Adjusted_NAV
                    / NULLIF(five_year.Adjusted_NAV, 0)
                    AS FLOAT
                ),
                1.0 / 5
            ) - 1
        ) * 100,
        2
    ) AS Five_Year_CAGR_Percent

FROM Scheme_List s

OUTER APPLY
(
    SELECT TOP 1
        n.NAV_Date,
        n.Adjusted_NAV
    FROM dbo.vw_NAV_Data_Adjusted n
    WHERE n.Scheme_Code = s.Scheme_Code
      AND n.NAV_Date <= '2025-06-15'
    ORDER BY n.NAV_Date DESC
) one_year

OUTER APPLY
(
    SELECT TOP 1
        n.NAV_Date,
        n.Adjusted_NAV
    FROM dbo.vw_NAV_Data_Adjusted n
    WHERE n.Scheme_Code = s.Scheme_Code
      AND n.NAV_Date <= '2023-06-15'
    ORDER BY n.NAV_Date DESC
) three_year

OUTER APPLY
(
    SELECT TOP 1
        n.NAV_Date,
        n.Adjusted_NAV
    FROM dbo.vw_NAV_Data_Adjusted n
    WHERE n.Scheme_Code = s.Scheme_Code
      AND n.NAV_Date <= '2021-06-15'
    ORDER BY n.NAV_Date DESC
) five_year

OUTER APPLY
(
    SELECT TOP 1
        n.NAV_Date,
        n.Adjusted_NAV
    FROM dbo.vw_NAV_Data_Adjusted n
    WHERE n.Scheme_Code = s.Scheme_Code
      AND n.NAV_Date <= '2026-06-15'
    ORDER BY n.NAV_Date DESC
) end_nav;
GO


/*
VERIFY MULTI-PERIOD PERFORMANCE VIEW

English:
This query displays scheme-wise one-year, three-year,
and five-year total return together with three-year
and five-year CAGR.

Hinglish:
Ye query har scheme ka 1-year, 3-year aur 5-year total return,
saath hi 3-year aur 5-year CAGR dikhati hai.
*/

SELECT
    Category,
    Scheme_Code,
    Scheme_Name,

    One_Year_Start_Date,
    One_Year_Start_NAV,

    Three_Year_Start_Date,
    Three_Year_Start_NAV,

    Five_Year_Start_Date,
    Five_Year_Start_NAV,

    End_Date,
    End_NAV,

    One_Year_Total_Return_Percent,
    Three_Year_Total_Return_Percent,
    Five_Year_Total_Return_Percent,

    Three_Year_CAGR_Percent,
    Five_Year_CAGR_Percent

FROM dbo.vw_Scheme_Multi_Period_Performance

ORDER BY Five_Year_CAGR_Percent DESC;


/*
MAIN QUERY 16: Weighted Performance Score and Category Rank

English:
This view carries forward one-year, three-year, and five-year
total return, together with three-year CAGR and five-year CAGR.
It calculates a weighted performance score using:
20% one-year return, 30% three-year CAGR, and 50% five-year CAGR.
It also ranks schemes within their respective categories.

Hinglish:
Ye view 1-year, 3-year aur 5-year total return ke saath
3-year CAGR aur 5-year CAGR ko carry forward karti hai.
Final weighted score 1-year return ko 20%, 3-year CAGR ko 30%
aur 5-year CAGR ko 50% weight dekar calculate hota hai.
Saath hi har category ke andar schemes ko rank kiya jata hai.
*/

GO

CREATE OR ALTER VIEW dbo.vw_Scheme_Weighted_Performance
AS

WITH Performance_Score AS
(
    SELECT
        Category,
        Scheme_Code,
        Scheme_Name,

        One_Year_Return_Percent,
        One_Year_Total_Return_Percent,
        Three_Year_Total_Return_Percent,
        Five_Year_Total_Return_Percent,

        Three_Year_CAGR_Percent,
        Five_Year_CAGR_Percent,

        (
            One_Year_Return_Percent * 0.20
            +
            Three_Year_CAGR_Percent * 0.30
            +
            Five_Year_CAGR_Percent * 0.50
        ) AS Weighted_Performance_Score

    FROM dbo.vw_Scheme_Multi_Period_Performance

    WHERE One_Year_Return_Percent IS NOT NULL
      AND One_Year_Total_Return_Percent IS NOT NULL
      AND Three_Year_Total_Return_Percent IS NOT NULL
      AND Five_Year_Total_Return_Percent IS NOT NULL
      AND Three_Year_CAGR_Percent IS NOT NULL
      AND Five_Year_CAGR_Percent IS NOT NULL
)

SELECT
    Category,
    Scheme_Code,
    Scheme_Name,

    One_Year_Return_Percent,
    One_Year_Total_Return_Percent,
    Three_Year_Total_Return_Percent,
    Five_Year_Total_Return_Percent,

    Three_Year_CAGR_Percent,
    Five_Year_CAGR_Percent,

    Weighted_Performance_Score,

    DENSE_RANK() OVER
    (
        PARTITION BY Category
        ORDER BY Weighted_Performance_Score DESC
    ) AS Category_Rank

FROM Performance_Score;
GO


/*
VERIFY WEIGHTED PERFORMANCE VIEW

English:
This query displays schemes ranked within each category
and includes total return, CAGR, and weighted score metrics.

Hinglish:
Ye query category-wise ranked schemes ke saath total return,
CAGR aur weighted score metrics dikhati hai.
*/

SELECT
    Category,
    Category_Rank,
    Scheme_Code,
    Scheme_Name,

    ROUND(One_Year_Total_Return_Percent, 2)
        AS One_Year_Total_Return_Percent,

    ROUND(Three_Year_Total_Return_Percent, 2)
        AS Three_Year_Total_Return_Percent,

    ROUND(Five_Year_Total_Return_Percent, 2)
        AS Five_Year_Total_Return_Percent,

    ROUND(Three_Year_CAGR_Percent, 2)
        AS Three_Year_CAGR_Percent,

    ROUND(Five_Year_CAGR_Percent, 2)
        AS Five_Year_CAGR_Percent,

    ROUND(Weighted_Performance_Score, 2)
        AS Weighted_Performance_Score

FROM dbo.vw_Scheme_Weighted_Performance

ORDER BY
    Category,
    Category_Rank;


/*
MAIN QUERY 17: Category-wise Weighted Performance Summary

English:
This query summarizes average one-year, three-year, and five-year
total return, average three-year and five-year CAGR, and average
weighted performance score for each mutual fund category.

Hinglish:
Ye query har category ka average 1-year, 3-year aur 5-year total return,
average 3-year CAGR, average 5-year CAGR aur weighted score dikhati hai.
*/

SELECT
    Category,

    COUNT(DISTINCT Scheme_Code) AS Total_Schemes,

    ROUND(
        AVG(One_Year_Total_Return_Percent),
        2
    ) AS Average_One_Year_Total_Return_Percent,

    ROUND(
        AVG(Three_Year_Total_Return_Percent),
        2
    ) AS Average_Three_Year_Total_Return_Percent,

    ROUND(
        AVG(Five_Year_Total_Return_Percent),
        2
    ) AS Average_Five_Year_Total_Return_Percent,

    ROUND(
        AVG(Three_Year_CAGR_Percent),
        2
    ) AS Average_Three_Year_CAGR_Percent,

    ROUND(
        AVG(Five_Year_CAGR_Percent),
        2
    ) AS Average_Five_Year_CAGR_Percent,

    ROUND(
        AVG(Weighted_Performance_Score),
        2
    ) AS Average_Weighted_Performance_Score

FROM dbo.vw_Scheme_Weighted_Performance

GROUP BY Category

ORDER BY Average_Weighted_Performance_Score DESC;


/*
MAIN QUERY 18: Fix ELSS Category Name

English:
This query replaces the incorrectly encoded ELSS category name
with a clean and consistent category name.

Hinglish:
Ye query galat encoding wale ELSS category naam ko
clean aur proper category naam se replace karti hai.
*/

UPDATE NAV_Data
SET Category = 'ELSS - Tax Saver Fund'
WHERE Category LIKE 'ELSS%';


SELECT DISTINCT Category
FROM NAV_Data
WHERE Category LIKE 'ELSS%';


/*
MAIN QUERY 19: Final Scheme Performance Dataset for Power BI

English:
This view prepares a clean scheme-level performance dataset
for importing into Power BI. It includes one-year, three-year,
and five-year total return, CAGR, weighted score, and category rank.

Hinglish:
Ye view Power BI ke liye scheme-level final dataset taiyar karti hai.
Isme 1-year, 3-year aur 5-year total return, CAGR,
weighted score aur category rank shamil hain.
*/

GO

CREATE OR ALTER VIEW dbo.vw_PowerBI_Scheme_Performance
AS

SELECT
    Category,
    Scheme_Code,
    Scheme_Name,

    One_Year_Return_Percent,
    One_Year_Total_Return_Percent,
    Three_Year_Total_Return_Percent,
    Five_Year_Total_Return_Percent,

    Three_Year_CAGR_Percent,
    Five_Year_CAGR_Percent,

    Weighted_Performance_Score,
    Category_Rank

FROM dbo.vw_Scheme_Weighted_Performance;
GO


/*
VERIFY FINAL SCHEME PERFORMANCE DATASET

English:
This query checks the final scheme-level dataset
prepared for Power BI.

Hinglish:
Ye query Power BI ke liye banaye gaye final
scheme-level dataset ko check karti hai.
*/

SELECT
    Category,
    Category_Rank,
    Scheme_Code,
    Scheme_Name,

    ROUND(One_Year_Total_Return_Percent, 2)
        AS One_Year_Total_Return_Percent,

    ROUND(Three_Year_Total_Return_Percent, 2)
        AS Three_Year_Total_Return_Percent,

    ROUND(Five_Year_Total_Return_Percent, 2)
        AS Five_Year_Total_Return_Percent,

    ROUND(Three_Year_CAGR_Percent, 2)
        AS Three_Year_CAGR_Percent,

    ROUND(Five_Year_CAGR_Percent, 2)
        AS Five_Year_CAGR_Percent,

    ROUND(Weighted_Performance_Score, 2)
        AS Weighted_Performance_Score

FROM dbo.vw_PowerBI_Scheme_Performance

ORDER BY
    Category,
    Category_Rank;





    /*
MAIN QUERY 20: Final Category Performance Dataset for Power BI

English:
This view prepares a clean category-level performance dataset
for importing into Power BI. It includes average one-year,
three-year, and five-year total return, average CAGR,
average weighted score, and category performance rank.

Hinglish:
Ye view Power BI ke liye category-wise final performance summary
taiyar karti hai. Isme average 1-year, 3-year aur 5-year total return,
average CAGR, weighted score aur category rank shamil hain.
*/

GO

CREATE OR ALTER VIEW dbo.vw_PowerBI_Category_Performance
AS

WITH Category_Summary AS
(
    SELECT
        Category,

        COUNT(DISTINCT Scheme_Code)
            AS Total_Schemes,

        AVG(
            CAST(One_Year_Return_Percent AS FLOAT)
        ) AS Average_One_Year_Return_Percent,

        AVG(
            CAST(One_Year_Total_Return_Percent AS FLOAT)
        ) AS Average_One_Year_Total_Return_Percent,

        AVG(
            CAST(Three_Year_Total_Return_Percent AS FLOAT)
        ) AS Average_Three_Year_Total_Return_Percent,

        AVG(
            CAST(Five_Year_Total_Return_Percent AS FLOAT)
        ) AS Average_Five_Year_Total_Return_Percent,

        AVG(
            CAST(Three_Year_CAGR_Percent AS FLOAT)
        ) AS Average_Three_Year_CAGR_Percent,

        AVG(
            CAST(Five_Year_CAGR_Percent AS FLOAT)
        ) AS Average_Five_Year_CAGR_Percent,

        AVG(
            CAST(Weighted_Performance_Score AS FLOAT)
        ) AS Average_Weighted_Performance_Score

    FROM dbo.vw_Scheme_Weighted_Performance

    GROUP BY Category
)

SELECT
    Category,
    Total_Schemes,

    Average_One_Year_Return_Percent,
    Average_One_Year_Total_Return_Percent,
    Average_Three_Year_Total_Return_Percent,
    Average_Five_Year_Total_Return_Percent,

    Average_Three_Year_CAGR_Percent,
    Average_Five_Year_CAGR_Percent,
    Average_Weighted_Performance_Score,

    DENSE_RANK() OVER
    (
        ORDER BY Average_Weighted_Performance_Score DESC
    ) AS Category_Performance_Rank

FROM Category_Summary;
GO


/*
VERIFY FINAL CATEGORY PERFORMANCE DATASET

English:
This query checks the final category-level dataset
prepared for Power BI.

Hinglish:
Ye query Power BI ke liye banaye gaye final
category-level dataset ko check karti hai.
*/

SELECT
    Category_Performance_Rank,
    Category,
    Total_Schemes,

    ROUND(
        Average_One_Year_Total_Return_Percent,
        2
    ) AS Average_One_Year_Total_Return_Percent,

    ROUND(
        Average_Three_Year_Total_Return_Percent,
        2
    ) AS Average_Three_Year_Total_Return_Percent,

    ROUND(
        Average_Five_Year_Total_Return_Percent,
        2
    ) AS Average_Five_Year_Total_Return_Percent,

    ROUND(
        Average_Three_Year_CAGR_Percent,
        2
    ) AS Average_Three_Year_CAGR_Percent,

    ROUND(
        Average_Five_Year_CAGR_Percent,
        2
    ) AS Average_Five_Year_CAGR_Percent,

    ROUND(
        Average_Weighted_Performance_Score,
        2
    ) AS Average_Weighted_Performance_Score

FROM dbo.vw_PowerBI_Category_Performance

ORDER BY Category_Performance_Rank;
