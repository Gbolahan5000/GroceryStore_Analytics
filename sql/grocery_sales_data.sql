
-- 1. Calculate total sales for each month

SELECT 
	DATENAME(MONTH, s.SalesDate) AS SalesMonth,
	ROUND(SUM(s.Quantity * p.Price), 2) AS TotalSales
FROM sales s
JOIN products p
ON s.ProductID = p.ProductID
GROUP BY 
	DATENAME(MONTH, s.SalesDate),
	MONTH(s.SalesDate)
ORDER BY 
	MONTH(s.SalesDate);

-- 2. Compare sales performance across different product categories each month

SELECT 
	DATENAME(MONTH, s.SalesDate) AS SalesMonth,
	c.CategoryName AS CategoryName,
	ROUND(SUM(s.Quantity * p.Price), 2) AS TotalSales
FROM sales s
JOIN products p
	ON s.ProductID = p.ProductID
JOIN categories c
	ON p.CategoryID = c.CategoryID
GROUP BY 
	DATENAME(MONTH, s.SalesDate),
	MONTH(s.SalesDate),
	c.CategoryName
ORDER BY 
	MONTH(s.SalesDate);

-- 3. Rank products based on total sale revenue

SELECT 
	ProductName,
	ROUND(SUM(s.Quantity * p.Price), 2) AS TotalRevenue,
	DENSE_RANK() OVER(ORDER BY ROUND(SUM(s.Quantity * p.Price), 2)) AS rank
FROM products P
JOIN sales s 
	ON p.ProductID = s.ProductID
GROUP BY 
	ProductName	
ORDER BY
	TotalRevenue;

-- 4. Analyze sales quantity and revenue to identify high demand products

SELECT TOP 10
	p.ProductName,
	MAX(s.Quantity) AS Quantity,
	ROUND(MAX(p.Price), 2) AS Price
FROM sales s
JOIN products p
	ON s.ProductID = p.ProductID
GROUP BY 
	p.ProductName
ORDER BY 
	Price DESC

-- 5. Examine the impact of product classifications on sales performance

SELECT 
	c.CategoryName AS CategoryName,
	ROUND(SUM(s.Quantity * p.Price), 2) AS TotalSales
FROM sales s
JOIN products p
	ON s.ProductID = p.ProductID
JOIN categories c
	ON p.CategoryID = c.CategoryID
GROUP BY
	c.CategoryName
ORDER BY 
	TotalSales DESC;

-- 6. Segment customers based on their purchase frequency and total spend

SELECT TOP 20
	c.FirstName,
	COUNT(c.FirstName) AS PurchaseFrequency,
	ROUND(SUM(s.Quantity * p.Price), 2) AS TotalSpend
FROM customers c
JOIN sales s
	ON c.CustomerID = s.CustomerID
JOIN products p
	ON s.ProductID = p.ProductID
GROUP BY 
	c.FirstName	
ORDER BY 
	TotalSpend DESC;

-- 7. Identify repeat customers vs one-time buyers

SELECT
	c.CustomerID,
	c.FirstName,
	COUNT(s.SalesID) AS PurchaseFrequency
FROM customers c
JOIN sales s
	ON c.CustomerID = s.CustomerID
GROUP BY 
	c.CustomerID,
	c.FirstName
HAVING 
	COUNT(s.SalesID) > 1
ORDER BY 
	PurchaseFrequency DESC; -- no one-time buyers

-- 8. Analyze average order value and basket size

SELECT
	ROUND(SUM(s.Quantity * p.Price), 2) AS TotalRevenue,
	COUNT(DISTINCT s.SalesId) AS TotalOrders,
	ROUND(SUM(s.Quantity * p.Price) / COUNT(DISTINCT s.SalesId), 2) AS AOV,
	ROUND(SUM(s.Quantity) * 1.0 / COUNT(DISTINCT s.SalesID), 2) AS BasketSize
FROM sales s
JOIN products p
	ON s.ProductID = p.ProductID;

-- 9. Calculate total sales attributed to each salesperson

SELECT
	e.EmployeeID,
	e.FirstName,
	COUNT(DISTINCT s.SalesId) AS TotalSales
FROM sales s
JOIN employees e
	ON s.SalesPersonID = e.EmployeeID
GROUP BY
	e.EmployeeID,
	e.FirstName
ORDER BY
	TotalSales DESC;

-- 10. Analyze sales trends based on individual salesperson contributions over time

SELECT
	e.EmployeeID,
	e.FirstName,
	DATENAME(MONTH, s.SalesDate) AS SalesMonth,
	MONTH(s.SalesDate) AS MonthNumber,
	COUNT(DISTINCT s.SalesId) AS TotalSales
FROM sales s
JOIN employees e
	ON s.SalesPersonID = e.EmployeeID
GROUP BY
	e.EmployeeID,
	e.FirstName,
	DATENAME(MONTH, s.SalesDate),
	MONTH(s.SalesDate)
ORDER BY
	e.EmployeeID,
	e.FirstName,
	MonthNumber;

-- 11. Identify top-performing and under-performing sales staff

WITH SalesPerEmployee AS (
    SELECT
        e.EmployeeID,
        e.FirstName,
        COUNT(DISTINCT s.SalesId) AS TotalSales
    FROM sales s
    JOIN employees e
        ON s.SalesPersonID = e.EmployeeID
    GROUP BY
        e.EmployeeID,
        e.FirstName
)

SELECT
    EmployeeID,
    FirstName,
    TotalSales,
    'Top Performer' AS PerformanceType
FROM SalesPerEmployee
WHERE TotalSales = (SELECT MAX(TotalSales) FROM SalesPerEmployee)

UNION ALL

SELECT
    EmployeeID,
    FirstName,
    TotalSales,
    'Least Performer' AS PerformanceType
FROM SalesPerEmployee
WHERE TotalSales = (SELECT MIN(TotalSales) FROM SalesPerEmployee);



-- 12. Map sales data to specific cities and countries to identify high performing regions

SELECT
	ci.CityName,
	co.CountryName,
	ROUND(SUM(s.Quantity * p.Price), 2) AS TotalSales
FROM sales s
JOIN products p
	ON s.ProductID = p.ProductID
JOIN customers cu
	ON s.CustomerID = cu.CustomerID
JOIN cities ci
	ON cu.CityID = ci.CityID
JOIN countries co
	ON ci.CountryID = co.CountryID
GROUP BY
	ci.CityName,
	co.CountryName;

-- 13. Compare sales volume between various geographical areas

SELECT
	ci.CityName,
	ROUND(SUM(s.Quantity), 2) AS TotalSalesVolume
FROM sales s
JOIN products p
	ON s.ProductID = p.ProductID
JOIN customers cu
	ON s.CustomerID = cu.CustomerID
JOIN cities ci
	ON cu.CityID = ci.CityID
GROUP BY
	ci.CityName
ORDER BY
	TotalSalesVolume DESC;