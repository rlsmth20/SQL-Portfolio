USE AdventureWorks2019
GO


--Total sales by product category
SELECT
	pc.Name Product_Category
   ,SUM(sod.orderqty) Total_Sales
FROM Production.ProductCategory pc
JOIN Production.ProductSubcategory ps
		ON pc.ProductCategoryID = ps.ProductCategoryID
JOIN Production.Product p
		ON p.ProductSubcategoryID = ps.ProductSubcategoryID
JOIN sales.SalesOrderDetail sod
		ON sod.ProductID = p.ProductID
GROUP BY pc.Name
ORDER BY Total_Sales DESC


--Yield by product category
SELECT
	pc.Name Product_Category
   ,CAST(ROUND(AVG(p.StandardCost/sod.UnitPrice*100),0) AS INT) 'Yield %'
FROM Sales.SalesOrderDetail sod
JOIN Production.Product p
		ON p.ProductID = sod.ProductID
JOIN Production.ProductSubcategory ps
		ON ps.ProductSubcategoryID = p.ProductSubcategoryID
JOIN Production.ProductCategory pc
		ON pc.ProductCategoryID = ps.ProductCategoryID
GROUP BY pc.Name
ORDER BY 'Yield %' DESC


--Total profit by product category
SELECT
	pc.Name Product_Category
   ,CAST(ROUND(SUM(sod.LineTotal-p.StandardCost*sod.OrderQty),0) AS INT) 'Profit $'
FROM Sales.SalesOrderDetail sod
JOIN Production.Product p
		ON p.ProductID = sod.ProductID
JOIN Production.ProductSubcategory ps
		ON ps.ProductSubcategoryID = p.ProductSubcategoryID
JOIN Production.ProductCategory pc
		ON pc.ProductCategoryID = ps.ProductCategoryID
GROUP BY pc.Name
ORDER BY 'Profit $' DESC


--Top 10 selling bikes
SELECT TOP 10
	p.Name
   ,SUM(sod.orderqty) Total_Sales
FROM Sales.SalesOrderDetail sod
JOIN Production.Product p
		ON p.ProductID = sod.ProductID
JOIN Production.ProductSubcategory ps
		ON ps.ProductSubcategoryID = p.ProductSubcategoryID
JOIN Production.ProductCategory pc
		ON pc.ProductCategoryID = ps.ProductCategoryID
WHERE pc.Name = 'Bikes'
GROUP BY p.Name
ORDER BY Total_Sales DESC


--Top 10 most profitable bikes
SELECT TOP 10
	p.Name
   ,CAST(ROUND(SUM(sod.LineTotal-p.StandardCost*sod.OrderQty),0) AS INT) 'Profit $'
FROM Sales.SalesOrderDetail sod
JOIN Production.Product p
		ON p.ProductID = sod.ProductID
JOIN Production.ProductSubcategory ps
		ON ps.ProductSubcategoryID = p.ProductSubcategoryID
JOIN Production.ProductCategory pc
		ON pc.ProductCategoryID = ps.ProductCategoryID
WHERE pc.Name = 'Bikes'
GROUP BY p.Name
ORDER BY 'Profit $' DESC


--Bike sales by date
SELECT
	soh.OrderDate Sale_Date
   ,COUNT(soh.SalesOrderID) #_Sold
FROM sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod
		ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product p
		ON p.ProductID = sod.ProductID
JOIN Production.ProductSubcategory ps
		ON ps.ProductSubcategoryID = p.ProductSubcategoryID
JOIN Production.ProductCategory pc
		ON pc.ProductCategoryID = ps.ProductCategoryID
WHERE pc.Name = 'Bikes'
GROUP BY soh.OrderDate
ORDER BY #_Sold DESC
