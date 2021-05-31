-- Q1a
select dimReseller.dimResellerName, Actual.CalendarYear, Actual.ActualAmount, Target.dimTargetSalesAmount
from
(select factSalesActual.dimResellerKey, DimDate.CalendarYear,  sum(factSalesActual.factSaleAmount) as ActualAmount
from dbo.factSalesActual
left join dbo.DimDate
on factSalesActual.DimDateID = DimDate.DimDateID
-- left join dimReseller
-- on factSalesActual.dimResellerKey = dimReseller.dimResellerKey
WHERE factSalesActual.dimChannelID = 329
group by DimDate.CalendarYear, factSalesActual.dimResellerKey) AS Actual
left join dbo.factSRCSalesTarget AS Target
on Actual.dimResellerKey = Target.dimResellerKey
left join dimReseller
on Actual.dimResellerKey = dimReseller.dimResellerKey


-- Q1b *
SELECT dimReseller.dimResellerName, DimDate.CalendarYear, DimDate.MonthNumberOfYear, sum(factSalesActual.factSaleAmount - factSalesActual.factSaleQuantity * dimProduct.dimProductCost) as SaleProfit
FROM dbo.factSalesActual
left join dbo.dimProduct
on dimProduct.dimProductID = factSalesActual.dimProductID
left join dimReseller
on factSalesActual.dimResellerKey = dimReseller.dimResellerKey
left join dbo.DimDate
on factSalesActual.DimDateID = DimDate.DimDateID
WHERE factSalesActual.dimChannelID = 329
group by DimDate.CalendarYear, DimDate.MonthNumberOfYear, dimReseller.dimResellerName

-- Q1c *
SELECT dimReseller.dimResellerName, DimDate.CalendarYear, DimDate.MonthNumberOfYear,dimProduct.dimProductCategory, sum(factSalesActual.factSaleAmount - factSalesActual.factSaleQuantity * dimProduct.dimProductCost) as SaleProfit
FROM dbo.factSalesActual
left join dbo.dimProduct
on dimProduct.dimProductID = factSalesActual.dimProductID
left join dimReseller
on factSalesActual.dimResellerKey = dimReseller.dimResellerKey
left join dbo.DimDate
on factSalesActual.DimDateID = DimDate.DimDateID
WHERE factSalesActual.dimChannelID = 329
group by DimDate.CalendarYear, DimDate.MonthNumberOfYear, dimReseller.dimResellerName, dimProduct.dimProductCategory

-- Q2
select dimReseller.dimResellerName, DimDate.CalendarYear, dimProduct.dimProductCategory, factSalesActual.factSaleAmount
FROM dbo.factSalesActual
left join dbo.dimProduct
on dimProduct.dimProductID = factSalesActual.dimProductID
left join dimReseller
on factSalesActual.dimResellerKey = dimReseller.dimResellerKey
left join dbo.DimDate
on factSalesActual.DimDateID = DimDate.DimDateID

-- Q3
select *
FROM dbo.factSalesActual
left join dbo.dimProduct
on dimProduct.dimProductID = factSalesActual.dimProductID
left join dimReseller
on factSalesActual.dimResellerKey = dimReseller.dimResellerKey
left join dimChannel
on factSalesActual.dimChannelID = dimChannel.dimChannelID
left join dbo.DimDate
on factSalesActual.DimDateID = DimDate.DimDateID

-- Q4
select 
FROM dbo.factSalesActual
left join dbo.dimProduct
on dimProduct.dimProductID = factSalesActual.dimProductID
left join dimReseller
on factSalesActual.dimResellerKey = dimReseller.dimResellerKey
left join dbo.DimDate
on factSalesActual.DimDateID = DimDate.DimDateID
left join dimChannel
on factSalesActual.dimChannelID = dimChannel.dimChannelID


