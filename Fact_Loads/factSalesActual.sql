IF EXISTS (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'factSalesActual')
BEGIN
	DELETE FROM dbo.factSalesActual;
END
GO



IF NOT EXISTS (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'factSalesActual')
BEGIN
	CREATE TABLE dbo.factSalesActual	
    (
    factSalesActualKey INT IDENTITY(1,1) NOT NULL CONSTRAINT factSalesActualKey PRIMARY KEY,
    dimProductID INT NOT NULL CONSTRAINT FK_factSalesActual_dimProductID FOREIGN KEY REFERENCES dbo.dimProduct (dimProductID),
    dimStoreKey INT NOT NULL CONSTRAINT FK_factSalesActual_dimStoreKey  FOREIGN KEY REFERENCES dbo.dimStore (dimStoreKey),
    dimResellerKey INT NOT NULL CONSTRAINT FK_factSalesActual_dimResellerKey FOREIGN KEY REFERENCES dbo.dimReseller (dimResellerKey),
    dimCustomerID INT NOT NULL CONSTRAINT FK_factSalesActual_dimCustomerID FOREIGN KEY REFERENCES dbo.dimCustomer (dimCustomerID),
    dimChannelID INT NOT NULL CONSTRAINT FK_factSalesActual_dimChannelID FOREIGN KEY REFERENCES dbo.dimChannel (dimChannelID),
    dimSalesDateKey INT NOT NULL CONSTRAINT FK_factSalesActual_DimDate_DimDateID FOREIGN KEY REFERENCES dbo.DimDate (dimDateID),
    dimLocationKey INT NOT NULL CONSTRAINT FK_factSalesActual_dimLocationKey_dimLocationKey FOREIGN KEY REFERENCES dbo.dimLocation (dimLocationKey),
    dimSourceSalesHeaderID INT NOT NULL, --Natural Key
    dimSourceSalesDetailID INT NOT NULL, --Natural Key
    dimSalesAmount numeric(18,2) NOT NULL,
    dimSalesQuantity INT NOT NULL,
    dimSalesUnitPrice Decimal(18,2) NOT NULL,
    dimSalesExtendedCost Numeric(16,6) NOT NULL,
    dimSalesTotalProfit Decimal(18,2) NOT NULL
	);
END
GO

IF EXISTS (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'factSalesActual')
BEGIN
	-- ====================================
	-- Load factSalesActual table
	-- ====================================

	INSERT INTO dbo.factSalesActual
	(
    dimProductID
    ,dimStoreKey
    ,dimResellerKey
    ,dimCustomerID
    ,dimChannelID
    ,dimSalesDateKey
    ,dimLocationKey
    ,dimSourceSalesHeaderID
    ,dimSourceSalesDetailID
    ,dimSalesAmount
    ,dimSalesQuantity
    ,dimSalesUnitPrice
    ,dimSalesExtendedCost
    ,dimSalesTotalProfit
	)
    SELECT p.dimProductID, 
    ISNULL(s.dimStoreKey,-1), 
    ISNULL(r.dimResellerKey,-1),
    ISNULL(c.dimCustomerID,-1), 
    ch.dimChannelID,
    d.DimDateID as dimSalesDateKey,
    l.dimLocationKey, 
    sh.SalesHeaderID AS dimSourceSalesHeaderID, 
    sd.SalesDetailID AS dimSourceSalesDetailID,
    sd.SalesAmount AS dimSalesAmount, 
    sd.SalesQuantity AS dimSalesQuantity, 
    sd.SalesAmount/sd.SalesQuantity AS dimSalesUnitPrice, 
    p.dimProductCost AS SalesExtendedCost,
    sd.SalesAmount-sd.SalesQuantity*p.dimProductCost as dimSalesTotalProfit
    FROM dbo.StageSalesDetail sd
    join dbo.StageSalesHeader sh on sh.SalesHeaderID = sd.SalesHeaderID
    join dbo.dimProduct p on p.dimSourceProductID =sd.ProductID
    left join dbo.dimStore s on s.dimSourceStoreID =sh.StoreID
    left join dbo.dimReseller r on r.dimSourceResellerID=sh.ResellerID
    left join dbo.dimCustomer c on c.dimSourceCustomerID=sh.CustomerID
    join dbo.dimChannel ch on ch.dimSourceChannelID=sh.ChannelID
    left join dbo.DimDate d on d.FullDate=sh.Date
    join dbo.dimLocation l on l.dimLocationKey=r.dimLocationKey OR l.dimLocationKey=c.dimLocationKey OR l.dimLocationKey=s.dimLocationKey;
END
GO 


-- =============================
-- Begin load of unknown member
-- =============================
SET IDENTITY_INSERT dbo.factSalesActual ON;

INSERT INTO dbo.factSalesActual
(
factSalesActualKey
,dimProductID
,dimStoreKey
,dimResellerKey
,dimCustomerID
,dimChannelID
,dimSalesDateKey
,dimLocationKey
,dimSourceSalesHeaderID
,dimSourceSalesDetailID
,dimSalesAmount
,dimSalesQuantity
,dimSalesUnitPrice
,dimSalesExtendedCost
,dimSalesTotalProfit
)
VALUES
( 
-1
,-1
,-1
,-1
,-1
,-1
,-1
,-1
,-1
,-1
,0.00
,-1 
,0.00
,0.000000
,0.00
);


-- Turn the identity insert to OFF so new rows auto assign identities
SET IDENTITY_INSERT dbo.factSalesActual OFF;
GO