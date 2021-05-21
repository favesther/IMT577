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
    dimSalesDateKey INT NOT NULL CONSTRAINT FK_factSalesActual_DimDateID FOREIGN KEY REFERENCES dbo.DimDate (dimDateID),
    dimLocationKey INT NOT NULL CONSTRAINT FK_factSalesActual_dimLocationKey FOREIGN KEY REFERENCES dbo.dimLocation (dimLocationKey),
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
    ISNULL(dbo.dimProduct.dimProductID, -1)
    ,ISNULL(dbo.dimStore.dimStoreKey, -1)
    ,ISNULL(dbo.dimReseller.dimResellerKey, -1)
    ,ISNULL(dbo.dimCustomer.dimCustomerID, -1)
    ,ISNULL(dbo.dimChannel.dimChannelID, -1)
    ,dbo.dimDate.DimDateID AS dimSalesDateKey
    ,dbo.dimLocation.dimLocationKey
    ,dbo.StageSalesDetail.SalesHeaderID AS dimSourceSalesHeaderID
    ,dbo.StageSalesDetail.SalesDetailID AS dimSourceSalesDetailID
    ,dbo.StageSalesDetail.SalesAmount
    ,dbo.StageSalesDetail.SalesQuantity
    ,dbo.StageSalesDetail.SalesAmount/dbo.StageSalesDetail.SalesQuantity AS dimSalesUnitPrice
    ,dbo.dimProduct.dimProductCost * dbo.StageSalesDetail.SalesQuantity AS dimSalesExtendedCost
    ,dbo.StageSalesDetail.SalesAmount - dbo.dimProduct.dimProductCost * dbo.StageSalesDetail.SalesQuantity AS dimSalesTotalProfit

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
    LEFT JOIN dimLocation
    on dbo.dimLocation.dimLocationKey=dbo.dimReseller.dimLocationKey 
    OR dbo.dimLocation.dimLocationKey=dbo.dimCustomer.dimLocationKey 
    OR dbo.dimLocation.dimLocationKey=dbo.dimStore.dimLocationKey

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