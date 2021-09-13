SELECT Order_ID, *
FROM [List of Orders]
WHERE Order_ID IS NULL;

SELECT Order_ID, *
FROM [Order Details]
WHERE Order_ID IS NULL;

SELECT *
FROM [Sales target];

-- Data Cleaning
-- Remove Null Values
DELETE FROM [List of Orders] 
WHERE Order_ID IS NULL;

-- CTE Monthly profit by year
With Profits
As (
	Select lo.CustomerName, od.Amount, od.Profit, od.Quantity, CONVERT(datetime, lo.Order_Date,103) as OrderDate
	From [List Of Orders] lo
	Inner Join [Order Details] od ON lo.Order_ID = od.Order_ID
	)
Select Year(pf.OrderDate) [Year], MONTH(pf.OrderDate) [Month], DATENAME(MONTH,pf.OrderDate) [Month_Name], Count(pf.Quantity) as Total_Quan, Sum(pf.Amount) as Total_Amount, Sum(pf.Profit) as Total_Profit
From Profits as pf
GROUP BY Year(pf.OrderDate), MONTH(pf.OrderDate), DATENAME(MONTH,pf.OrderDate)
Order By Year(pf.OrderDate), MONTH(pf.OrderDate), DATENAME(MONTH,pf.OrderDate);

-- Sub-categories Profits by date
With Profits
As (
	Select od.Sub_Category, od.Amount, od.Profit, od.Quantity, CONVERT(datetime, lo.Order_Date,103) as OrderDate
	From [List Of Orders] lo
	Inner Join [Order Details] od ON lo.Order_ID = od.Order_ID
	)
Select *, (ISNULL([2018-04],0) + ISNULL([2018-05],0)+ ISNULL([2018-06],0)+ ISNULL([2018-07],0)+ ISNULL([2018-08],0) + ISNULL([2018-09],0)+ ISNULL([2018-10],0)+ ISNULL([2018-11],0)+ ISNULL([2018-12],0) + ISNULL([2019-01],0)+ ISNULL([2019-02],0)+ ISNULL([2019-03],0)) as [Total]
From(
	Select pf.Sub_Category as [Sub_Category], Format (pf.OrderDate, 'yyyy-MM') as [Order_Date], pf.Profit as Profit
	From Profits pf
	) As p
Pivot
(
	Sum(Profit)
	For [Order_Date] IN ([2018-04], [2018-05], [2018-06], [2018-07], [2018-08], [2018-09], [2018-10], [2018-11], [2018-12], [2019-01], [2019-02], [2019-03])
)AS pvt

-- CTE order, profit/loss by state
With Profits
As (
	Select lo.Order_Date, lo.CustomerName, lo.State, lo.City, od.Amount, od.Profit, od.Quantity
	From [List Of Orders] lo
	Inner Join [Order Details] od ON lo.Order_ID = od.Order_ID
	)
Select pf.State, sum(pf.Profit) as Revenue, 
CASE
	WHEN sum(pf.Profit) > 0 THEN 'PROFIT'
	ELSE 'LOSS'
END AS Profit_Loss,
count(*) as Total_Orders
From Profits as pf
Group by pf.State
Order By Revenue;

-- CTE order, profit/loss by city
With Profits
As (
	Select lo.Order_Date, lo.CustomerName, lo.State, lo.City, od.Amount, od.Profit, od.Quantity
	From [List Of Orders] lo
	Inner Join [Order Details] od ON lo.Order_ID = od.Order_ID
	)
Select pf.City, sum(pf.Profit) as Profit_Loss, count(*) as Total_Orders
From Profits as pf
Group by pf.City
Order By Profit_Loss;


