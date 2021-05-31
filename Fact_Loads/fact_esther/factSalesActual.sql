IF EXISTS (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'factSalesActual')
BEGIN
	DELETE FROM dbo.factSalesActual;
END
GO



IF NOT EXISTS (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'factSalesActual')
BEGIN
	CREATE TABLE dbo.factSalesActual	
    (
    factSalesActualKey INT IDENTITY(1,1) CONSTRAINT PK_factSalesActual PRIMARY KEY CLUSTERED NOT NULL,
    dimProductID INT NOT NULL CONSTRAINT FK_factSalesActual_dimProduct FOREIGN KEY REFERENCES dbo.dimProduct (dimProductID),
    dimChannelID INT NOT NULL CONSTRAINT FK_factSalesActual_dimChannel FOREIGN KEY REFERENCES dbo.dimChannel (dimChannelID),
    dimResellerKey INT NOT NULL CONSTRAINT FK_factSalesActual_dimReseller FOREIGN KEY REFERENCES dbo.dimReseller (dimResellerKey),
    dimCustomerID INT NOT NULL CONSTRAINT FK_factSalesActual_dimCustomer FOREIGN KEY REFERENCES dbo.dimCustomer (dimCustomerID),
    dimStoreKey INT NOT NULL CONSTRAINT FK_factSalesActual_dimStore  FOREIGN KEY REFERENCES dbo.dimStore (dimStoreKey),
    -- dimLocationKey INT NOT NULL CONSTRAINT FK_factSalesActual_dimLocation FOREIGN KEY REFERENCES dbo.dimLocation (dimLocationKey),
    -- dimSourceSalesHeaderID INT NOT NULL, --Natural Key
    -- dimSourceSalesDetailID INT NOT NULL, --Natural Key
    dimSalesQuantity INT NOT NULL,
    dimSalesAmount numeric(18,2) NOT NULL,
    DimDateID INT NOT NULL CONSTRAINT FK_factSalesActual_DimDate FOREIGN KEY REFERENCES dbo.DimDate (DimDateID)
    -- dimSalesUnitPrice Decimal(18,2) NOT NULL,
    -- dimSalesExtendedCost Numeric(16,6) NOT NULL,
    -- dimSalesTotalProfit Decimal(18,2) NOT NULL
	);
END
GO

IF EXISTS (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'factSales')
BEGIN
	INSERT INTO dbo.factSales
	(
		dimProductID
		,dimChannelID
		,dimResellerKey
		,dimCustomerID
		,dimStoreKey
		,factSaleQuantity
		,factSaleAmount
		,DimDateID		
	)
	SELECT 
		ISNULL(dbo.dimProduct.dimProductID, -1)
		,ISNULL(dbo.dimChannel.dimChannelID, -1)
		,ISNULL(dbo.dimReseller.dimResellerKey, -1)
		,ISNULL(dbo.dimCustomer.dimCustomerID, -1)
		,ISNULL(dbo.dimStore.dimStoreKey, -1)
		,dbo.StageSalesDetail.SalesQuantity
		,dbo.StageSalesDetail.SalesAmount
		,dbo.DimDate.DimDateID
	FROM StageSalesHeader
	LEFT JOIN StageSalesDetail ON
	dbo.StageSalesDetail.SalesHeaderID = dbo.StageSalesHeader.SalesHeaderID
	LEFT JOIN dimProduct ON
	dbo.dimProduct.dimProductID = dbo.StageSalesDetail.ProductID 
	LEFT JOIN dimChannel ON
	dbo.dimChannel.dimChannelID = dbo.StageSalesHeader.ChannelID
	LEFT JOIN dimReseller ON
	dbo.dimReseller.dimSourceResellerID = dbo.StageSalesHeader.ResellerID
	LEFT JOIN dimCustomer ON
	dbo.dimCustomer.dimSourceCustomerID = dbo.StageSalesHeader.CustomerID
	LEFT JOIN dimStore ON
	dbo.dimStore.dimSourceStoreID = dbo.StageSalesHeader.StoreID
	LEFT JOIN dimDate ON
	dbo.dimDate.FullDate = dbo.StageSalesHeader.Date
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
-- ,dimSourceSalesHeaderID
-- ,dimSourceSalesDetailID
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