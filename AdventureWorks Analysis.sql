USE AdventureWorks2019
GO

--Top 10 sellers by country
SELECT TOP 10 
	PS.Name, 
	st.Name, 
	SUM(SOD.OrderQty) AS salesquanitity
FROM sales.SalesOrderDetail SOD
JOIN Production.Product P
	ON SOD.ProductID = P.ProductID
JOIN Production.ProductSubcategory PS
	ON P.ProductSubcategoryID = PS.ProductSubcategoryID
JOIN sales.SalesOrderHeader SOH
	ON SOH.SalesOrderID = sod.SalesOrderID
JOIN sales.SalesTerritory ST
	ON ST.TerritoryID = SOH.TerritoryID
WHERE st.name NOT IN  ('central', 'southeast', 'southwest', 'northeast', 'northwest')
GROUP BY PS.Name, ST.Name
ORDER BY salesquanitity DESC


--Sales by demographics
WITH cte AS (
    SELECT 
        D.BusinessEntityID,
        CASE 
            WHEN DateDIFF(year,d.BirthDate,GETDATE()) BETWEEN 40 AND 50 THEN '40-50'
			WHEN DateDIFF(year,d.BirthDate,GETDATE()) BETWEEN 51 AND 60 THEN '51-60'
			WHEN DateDIFF(year,d.BirthDate,GETDATE()) BETWEEN 61 AND 70 THEN '61-70'
            ELSE '71+'
        END AS age_range
    FROM 
        sales.vPersonDemographics D
)
SELECT 
    age_range,
    D.MaritalStatus,
    D.Gender,
    SUM(SOD.linetotal) Sales
FROM 
    cte
JOIN sales.SalesOrderHeader SOH
    ON cte.BusinessEntityID = SOH.CustomerID
JOIN sales.salesorderdetail SOD
    ON SOH.salesorderID = SOD.salesorderID
JOIN sales.vPersonDemographics D
    ON SOH.CustomerID = d.BusinessEntityID
GROUP BY 
    age_range, D.MaritalStatus, D.Gender
ORDER BY Sales desc


