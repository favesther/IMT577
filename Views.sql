CREATE View DateView AS
SELECT   DimDateID, FullDate, DayNumberOfWeek, DayNameOfWeek, DayNumberOfMonth, DayNumberOfYear, WeekdayFlag, WeekNumberOfYear, [MonthName, MonthNumberOfYear, CalendarQuarter, CalendarYear, CalendarSemester, CreatedDate, CreatedBy, ModifiedDate, ModifiedBy
FROM     dbo.DimDate;


-- 

CREATE View ResellerView AS
SELECT   dimLocationKey,dimSourceResellerID,dimResellerName,dimContact,dimPhoneNumber,dimEmailAddress
FROM     dbo.dimReseller;

-- 

CREATE View ChannelView AS
SELECT   dimChannelID, dimSourceChannelID, dimSourceCategoryID, dimChannelCategoryName, dimChannelName
FROM     dbo.dimChannel;

-- 

CREATE View LocationView AS
SELECT   dimLocationKey, dimPostalCode, dimAddress, dimCity, dimStateProvince, dimCountry
FROM     dbo.dimLocation;

-- 

CREATE View CustomerView AS
SELECT   dimCustomerID, dimLocationKey, dimSourceCustomerID, dimCustomerFullName, dimCustomerFirstName, dimCustomerLastName, dimGender
FROM     dbo.dimCustomer;

-- 

CREATE View StoreView AS
SELECT   dimStoreKey, dimLocationKey, dimSourceStoreID, dimStoreName, dimStoreNumber, dimStoreManager
FROM     dbo.dimStore;

-- 

CREATE View ProductView AS
SELECT   dimProductID, dimSourceProductID, dimSourceProductTypeID, dimSourceProductCategoryID, dimProductName, dimProductType, dimProductCategory, dimProductRetailPrice, dimProductWholesalePrice, dimProductCost, dimProductRetailProfit, dimProductWholesaleUnitProfit, dimProductProfitMarginUnitPercent
FROM     dbo.dimProduct;

-- 

CREATE View ProductSalesTargetView AS
SELECT   dimProductID, dimTargetDateKey, ProductTargetSalesAmount
FROM     dbo.factProductSalesTarget;

-- 

CREATE View SRCSalesTargetView AS
SELECT   dimStoreKey, dimResellerKey, dimChannelID,dimSRCname, dimTargetDateKey, SalesTargetSalesAmount
FROM     dbo.factSRCSalesTarget;

-- 

CREATE View SalesActualView AS
SELECT   dimProductID,dimStoreKey,dimResellerKey,dimCustomerID,dimChannelID,dimSalesDateKey,dimLocationKey,dimSourceSalesHeaderID,dimSourceSalesDetailID,dimSalesAmount,dimSalesQuantity,dimSalesUnitPrice,dimSalesExtendedCost,dimSalesTotalProfit
FROM     dbo.factSalesActual;