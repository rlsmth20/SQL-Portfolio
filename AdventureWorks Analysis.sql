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
GROUP BY age_range, D.MaritalStatus, D.Gender
ORDER BY Sales desc

--
SELECT *
FROM AdventureWorks2019.Sales.SalesPersonQuotaHistory

--Employee Sales Performance
SELECT 
	S.BusinessEntityID, 
	E.JobTitle, 
	S.SalesQuota, 
	S.SalesYTD, 
	(S.SalesYTD/S.SalesQuota)*100 AS PercentQuota
FROM Sales.Salesperson S
JOIN HumanResources.Employee E
	ON S.BusinessEntityID = E.BusinessEntityID
GROUP BY S.BusinessEntityID, E.JobTitle, S.SalesQuota, s.SalesYTD
ORDER BY PercentQuota DESC

--Vendor Performance Analysis
SELECT 
	POH.VendorID, 
	V.Name,
	V.CreditRating,
    AVG(DATEDIFF(day, POH.OrderDate, POH.ShipDate)) AS AvgLeadTime, 
	(SUM(POD.RejectedQty)/SUM(POD.ReceivedQty))*100 AS AvgRejectionRate
FROM Purchasing.PurchaseOrderHeader POH
JOIN Purchasing.Vendor V 
	ON POH.VendorID = V.BusinessEntityID
JOIN Purchasing.PurchaseOrderDetail POD 
	ON POH.PurchaseOrderID = POD.PurchaseOrderID
GROUP BY POH.VendorID, V.Name, v.CreditRating
ORDER BY AvgRejectionRate DESC, AvgLeadTime DESC

--Average cost per product by vendor
SELECT
	PV.BusinessEntityID,
	PV.ProductID,
	AVG(PV.StandardPrice) AS AvgCostPerProduct
FROM Purchasing.ProductVendor PV
GROUP BY pv.ProductID, pv.BusinessEntityID
ORDER BY pv.productID, AvgCostPerProduct



WITH sales_data (ProductName, OrderYear, QuantitySold)
AS (
SELECT 
    pro.Name as ProductName,
    DATEPART(YEAR, soh.OrderDate) as OrderYear, 
    SUM(sod.OrderQty) as QuantitySold
FROM Sales.SalesOrderDetail as sod
JOIN Production.Product as pro 
	ON sod.ProductID = pro.ProductID
JOIN Sales.SalesOrderHeader as soh
	ON sod.SalesOrderID = soh.SalesOrderID
WHERE DATEPART(YEAR, soh.OrderDate) = 2012
)
SELECT 
    ProductName,
    QuantitySold as '2012 Sales'
FROM sales_data
GROUP BY ProductName, OrderYear
ORDER BY ProductName




SELECT 
    pro.Name,
    DATEPART(YEAR, soh.OrderDate) as OrderYear, 
    SUM(sod.OrderQty) as QuantitySold
FROM Sales.SalesOrderDetail as sod
JOIN Production.Product as pro 
	ON sod.ProductID = pro.ProductID
JOIN Sales.SalesOrderHeader as soh
	ON sod.SalesOrderID = soh.SalesOrderID
WHERE DATEPART(YEAR, soh.OrderDate) = 2012
GROUP BY pro.Name, soh.OrderDate
ORDER BY pro.Name
