USE MutualFundAnalytics;
GO

CREATE TABLE dbo.Scheme_Dim (
    Scheme_Code NVARCHAR(50) PRIMARY KEY,
    Category NVARCHAR(100),
    Scheme_Name NVARCHAR(300),
    AMC_Name NVARCHAR(150)
);
GO

BULK INSERT dbo.Scheme_Dim
FROM 'C:\Users\hp\Desktop\Mutual_Fund_Project\Processed_Data\Scheme_Dim.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);
GO

SELECT COUNT(*) AS Total_Schemes FROM dbo.Scheme_Dim;

SELECT TOP 10 * FROM dbo.Scheme_Dim;