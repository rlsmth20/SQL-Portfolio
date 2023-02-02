USE AdventureWorks2019
GO

--Top 10 sellers by country
SELECT TOP 10
	PSub.Name AS Product, 
	st.Name AS Country, 
	SUM(SOD.OrderQty) AS salesquanitity
FROM sales.SalesOrderDetail SOD
JOIN Production.Product Prod
	ON SOD.ProductID = Prod.ProductID
JOIN Production.ProductSubcategory PSub
	ON Prod.ProductSubcategoryID = PSub.ProductSubcategoryID
JOIN sales.SalesOrderHeader SOH
	ON SOH.SalesOrderID = sod.SalesOrderID
JOIN sales.SalesTerritory ST
	ON ST.TerritoryID = SOH.TerritoryID
WHERE st.name NOT IN  ('central', 'southeast', 'southwest', 'northeast', 'northwest')
GROUP BY PSub.Name, ST.Name
ORDER BY salesquanitity DESC

--Top 10 selling products
SELECT TOP 10
	PSub.Name AS Product, 
	SUM(SOD.OrderQty) AS salesquanitity
FROM sales.SalesOrderDetail SOD
JOIN Production.Product Prod
	ON SOD.ProductID = Prod.ProductID
JOIN Production.ProductSubcategory PSub
	ON Prod.ProductSubcategoryID = PSub.ProductSubcategoryID
JOIN sales.SalesOrderHeader SOH
	ON SOH.SalesOrderID = sod.SalesOrderID
JOIN sales.SalesTerritory ST
	ON ST.TerritoryID = SOH.TerritoryID
GROUP BY PSub.Name
ORDER BY salesquanitity DESC


--Sales by demographics
WITH cte AS (
    SELECT 
        Demo.BusinessEntityID,
        CASE 
            WHEN DateDIFF(year,Demo.BirthDate,GETDATE()) BETWEEN 40 AND 50 THEN '40-50'
			WHEN DateDIFF(year,Demo.BirthDate,GETDATE()) BETWEEN 51 AND 60 THEN '51-60'
			WHEN DateDIFF(year,Demo.BirthDate,GETDATE()) BETWEEN 61 AND 70 THEN '61-70'
            ELSE '71+'
        END AS age_range
    FROM 
        sales.vPersonDemographics Demo
)
SELECT 
    age_range,
    Demo.MaritalStatus,
    Demo.Gender,
    SUM(SOD.linetotal) Sales
FROM 
    cte
JOIN sales.SalesOrderHeader SOH
    ON cte.BusinessEntityID = SOH.CustomerID
JOIN sales.salesorderdetail SOD
    ON SOH.salesorderID = SOD.salesorderID
JOIN sales.vPersonDemographics Demo
    ON SOH.CustomerID = Demo.BusinessEntityID
GROUP BY age_range, Demo.MaritalStatus, Demo.Gender
ORDER BY Sales desc

--
SELECT *
FROM AdventureWorks2019.Sales.SalesPersonQuotaHistory

--Employee Sales Performance
USE AdventureWorks2019
GO
SELECT 
	SPers.BusinessEntityID, 
	E.JobTitle, 
	SPers.SalesQuota, 
	SPers.SalesYTD, 
	(SPers.SalesYTD/SPers.SalesQuota)*100 AS PercentQuota
FROM Sales.SalesPerson Spers
JOIN HumanResources.Employee E
	ON SPers.BusinessEntityID = E.BusinessEntityID
GROUP BY SPers.BusinessEntityID, E.JobTitle, SPers.SalesQuota, Spers.SalesYTD
ORDER BY PercentQuota DESC

USE AdventureWorks2019
GO
CREATE VIEW EmployeeSalesPerformance AS
SELECT 
	SPers.BusinessEntityID, 
	Emp.JobTitle, 
	SPers.SalesQuota, 
	SPers.SalesYTD, 
	(SPers.SalesYTD/SPers.SalesQuota)*100 AS PercentQuota
FROM Sales.Salesperson SPers
JOIN HumanResources.Employee Emp
	ON SPers.BusinessEntityID = Emp.BusinessEntityID
GROUP BY SPers.BusinessEntityID, Emp.JobTitle, SPers.SalesQuota, SPers.SalesYTD
--ORDER BY PercentQuota DESC

--Vendor Performance Analysis
SELECT 
	POH.VendorID, 
	Vend.Name,
	Vend.CreditRating,
    AVG(DATEDIFF(day, POH.OrderDate, POH.ShipDate)) AS AvgLeadTime, 
	SUM(POD.RejectedQty)/SUM(POD.ReceivedQty)*100 AS AvgRejectionRate
FROM Purchasing.PurchaseOrderHeader POH
JOIN Purchasing.Vendor Vend
	ON POH.VendorID = Vend.BusinessEntityID
JOIN Purchasing.PurchaseOrderDetail POD 
	ON POH.PurchaseOrderID = POD.PurchaseOrderID
GROUP BY POH.VendorID, Vend.Name, Vend.CreditRating
ORDER BY AvgRejectionRate DESC, AvgLeadTime DESC

--Average cost per product by vendor
SELECT
	ProVend.BusinessEntityID,
	ProVend.ProductID,
	AVG(ProVend.StandardPrice) AS AvgCostPerProduct
FROM Purchasing.ProductVendor ProVend
GROUP BY ProVend.ProductID, ProVend.BusinessEntityID
ORDER BY ProVend.productID, AvgCostPerProduct


--Sales Per Item By Year
SELECT
    Pro.Name,
    DATEPART(YEAR, soh.OrderDate) as OrderYear, 
    SUM(sod.OrderQty) as QuantitySold
FROM Sales.SalesOrderDetail as SOD
JOIN Production.Product as Pro 
	ON SOD.ProductID = pro.ProductID
JOIN Sales.SalesOrderHeader as SOH
	ON SOD.SalesOrderID = soh.SalesOrderID
WHERE DATEPART(YEAR, SOH.OrderDate) IN ('2011', '2012', '2013', '2014')
GROUP BY Pro.Name, DATEPART(YEAR, SOH.OrderDate)
ORDER BY OrderYear, QuantitySold DESC, Pro.Name


--Sales Per Item By Month
SELECT
    MONTH(SOH.OrderDate) AS Month, 
	DATEPART(YEAR, SOH.OrderDate) AS Year,
    Pro.Name AS Product_Name, 
    SUM(SOD.OrderQty) AS Quantity_Sold
FROM Sales.SalesOrderHeader SOH
JOIN Sales.SalesOrderDetail SOD 
	ON SOH.SalesOrderID = SOD.SalesOrderID
JOIN Production.Product Pro
	ON SOD.ProductID = Pro.ProductID
GROUP BY MONTH(SOH.OrderDate), Pro.Name, DATEPART(YEAR, SOH.OrderDate)
ORDER BY DATEPART(YEAR,SOH.OrderDate) , MONTH (SOH.OrderDate)

--Sales per month
SELECT DATEPART(YEAR, OrderDate) AS Year
	 , DATEPART(MONTH, OrderDate) AS Month
	 , SUM(TotalDue) AS [Total Sales]
FROM Sales.SalesOrderHeader SOH
GROUP BY DATEPART(YEAR, OrderDate), DATEPART(MONTH, OrderDate)
ORDER BY Year, Month
