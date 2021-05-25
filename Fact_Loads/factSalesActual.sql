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
    dimStoreKey INT NOT NULL CONSTRAINT FK_factSalesActual_dimStore  FOREIGN KEY REFERENCES dbo.dimStore (dimStoreKey),
    dimResellerKey INT NOT NULL CONSTRAINT FK_factSalesActual_dimReseller FOREIGN KEY REFERENCES dbo.dimReseller (dimResellerKey),
    dimCustomerID INT NOT NULL CONSTRAINT FK_factSalesActual_dimCustomer FOREIGN KEY REFERENCES dbo.dimCustomer (dimCustomerID),
    dimChannelID INT NOT NULL CONSTRAINT FK_factSalesActual_dimChannel FOREIGN KEY REFERENCES dbo.dimChannel (dimChannelID),
    dimSalesDateKey INT NOT NULL CONSTRAINT FK_factSalesActual_DimDate FOREIGN KEY REFERENCES dbo.DimDate (DimDateID),
    dimLocationKey INT NOT NULL CONSTRAINT FK_factSalesActual_dimLocation FOREIGN KEY REFERENCES dbo.dimLocation (dimLocationKey),
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
    ,dimSalesTotalProfit)


    SELECT 
    dbo.dimProduct.dimProductID
    ,dbo.dimStore.dimStoreKey
    ,dbo.dimReseller.dimResellerKey
    ,dbo.dimCustomer.dimCustomerID
    ,dbo.dimChannel.dimChannelID
    ,dbo.DimDate.DimDateID AS dimSalesDateKey
    ,dbo.dimLocation.dimLocationKey
    ,dbo.StageSalesDetail.SalesHeaderID AS dimSourceSalesHeaderID
    ,dbo.StageSalesDetail.SalesDetailID AS dimSourceSalesDetailID
    ,dbo.StageSalesDetail.SalesAmount
    ,dbo.StageSalesDetail.SalesQuantity
    ,dbo.StageSalesDetail.SalesAmount/dbo.StageSalesDetail.SalesQuantity AS dimSalesUnitPrice
    ,ISNULL(dbo.dimProduct.dimProductCost * dbo.StageSalesDetail.SalesQuantity,0.000000) AS dimSalesExtendedCost
    ,ISNULL(dbo.StageSalesDetail.SalesAmount - dbo.dimProduct.dimProductCost * dbo.StageSalesDetail.SalesQuantity,0.00) AS dimSalesTotalProfit

    FROM dbo.StageSalesHeader
    LEFT JOIN dbo.StageSalesDetail ON
    dbo.StageSalesDetail.SalesHeaderID = dbo.StageSalesHeader.SalesHeaderID
    LEFT JOIN dbo.dimProduct ON
    dbo.dimProduct.dimSourceProductID = dbo.StageSalesDetail.ProductID 
    LEFT JOIN dbo.dimChannel ON
    dbo.dimChannel.dimSourceChannelID = dbo.StageSalesHeader.ChannelID
    LEFT JOIN dbo.dimReseller ON
    dbo.dimReseller.dimSourceResellerID = dbo.StageSalesHeader.ResellerID
    LEFT JOIN dbo.dimCustomer ON
    dbo.dimCustomer.dimSourceCustomerID = dbo.StageSalesHeader.CustomerID
    LEFT JOIN dbo.dimStore ON
    dbo.dimStore.dimSourceStoreID = dbo.StageSalesHeader.StoreID
    LEFT JOIN dbo.DimDate ON
    dbo.DimDate.FullDate = dbo.StageSalesHeader.Date
    LEFT JOIN dbo.dimLocation
    on dbo.dimLocation.dimLocationKey=dbo.dimReseller.dimLocationKey 
    OR dbo.dimLocation.dimLocationKey=dbo.dimCustomer.dimLocationKey 
    OR dbo.dimLocation.dimLocationKey=dbo.dimStore.dimLocationKey



END
GO 

    -- select Detail.dimProductID, Header.dimStoreKey, Header.dimResellerKey, Header.dimCustomerID, 
    -- Header.dimChannelID, Header.dimDateID AS dimSalesDateKey, Header.dimLocationKey, 
    -- Header.SalesHeaderID AS dimSourceSalesHeaderID, Detail.SalesDetailID AS dimSourceSalesDetailID, 
    -- Detail.SalesAmount, Detail.SalesQuantity, Detail.SalesAmount/Detail.SalesQuantity AS dimSalesUnitPrice, 
    -- Detail.dimSalesExtendedCost, Detail.dimSalesTotalProfit
    
    -- from (
    --         select sd.SalesDetailID, sd.SalesHeaderID, P.dimProductID, sd.SalesQuantity, sd.SalesAmount,
    --         p.dimProductCost,
    --         sd.SalesAmount-sd.SalesQuantity*p.ProductCost AS dimSalesTotalProfit
    --         from dbo.StageSalesDetail sd
    --         left join dbo.dimProduct P
    --         on sd.ProductID = P.dimSourceProductID
    --     ) Detail, 
    --     (
    --         select H.*, c.dimChannelID, s.dimStoreKey, Customer.dimCustomerID, r.dimResellerKey, d.dimDateID
    --         from dbo.StageSalesHeader H
    --         left join dbo.dimChannel c
    --         on c.dimSourceChannelID = H.ChannelID  
    --         left join dbo.dimStore s
    --         on s.dimSourceStoreID = H.StoreID
    --         left join dbo.dimCustomer Customer
    --         on Customer.dimSourceCustomerID = H.CustomerID
    --         left join dbo.Reseller r
    --         on r.dimSourceResellerID = r.ResellerID
    --         left join dbo.DimDate d
    --         on d.FullDate = H.Date
    --         join dbo.dimLocation l 
    --         on l.dimLocationKey=r.dimLocationKey OR l.dimLocationKey=Customer.dimLocationKey OR l.dimLocationKey=s.dimLocationKey
    --     ) Header
    -- where Detail.SalesHeaderID = Header.SalesHeaderID

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