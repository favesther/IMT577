IF EXISTS (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'factSRCSalesTarget')
BEGIN
	DELETE FROM dbo.factSRCSalesTarget;
END
GO



IF NOT EXISTS (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'factSRCSalesTarget')
BEGIN
	CREATE TABLE dbo.factSRCSalesTarget
	(
	factSRCSalesTargetKey INT IDENTITY(1,1) CONSTRAINT PK_factSRCSalesTargetKey PRIMARY KEY CLUSTERED NOT NULL, -- SurrogateKey
    dimStoreKey INT NOT NULL CONSTRAINT FK_factSRCSalesTarget_dimStoreKey  FOREIGN KEY REFERENCES dbo.dimStore (dimStoreKey),
    dimResellerKey INT NOT NULL CONSTRAINT FK_factSRCSalesTarget_dimResellerKey FOREIGN KEY REFERENCES dbo.dimReseller (dimResellerKey),    
	dimChannelID INT NOT NULL CONSTRAINT FK_factSRCSalesTarget_dimChannelID FOREIGN KEY REFERENCES dbo.dimChannel (dimChannelID),
	-- dimSRCname nvarchar(255) NOT NULL,
	dimTargetDateKey INT NOT NULL CONSTRAINT FK_factRSCSalesTarget_DimDateID FOREIGN KEY REFERENCES dbo.DimDate (dimDateID),
	SalesTargetSalesAmount Numeric(16,6) NOT NULL,
	);
END
GO

IF EXISTS (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'factSRCSalesTarget')
BEGIN
	-- ====================================
	-- Load factSRCSalesTarget table
	-- ====================================

	INSERT INTO dbo.factSRCSalesTarget
	(
	dimStoreKey
	dimResellerKey
	dimChannelID
	dimTargetDateKey
	SalesTargetSalesAmount
	)

	SELECT s.dimStoreKey, r.dimResellerKey, c.dimChannelID, DimDate.DimDateID as dimTargetDateKey, 
	CAST(CRS.TargetSalesAmount AS int)/365.0 as SalesTargetSalesAmount
	FROM dbo.StageTargetCRS AS CRS
	join dbo.dimChannel c
	on pt.TargetName = c.dimChannelName
	left join dbo.dimStore s
	on pt.TargetName = s.dimStoreName
	left join dbo.dimReseller r
	on pt.TargetName = r.dimResellerName
	left join dbo.DimDate DimDate
	on CRS.Year = DimDate.CalendarYear    
END
GO 

	-- FROM StageTargetCRS
    -- INNER JOIN dbo.dimChannel as dimChannel
    -- ON StageTargetCRS.ChannelName = dimChannel.dimChannelName 
    -- INNER JOIN dbo.dimReseller as dimReseller
    -- StageTargetCRS.TargetName = dimReseller.dimResellerName
    -- INNER JOIN dbo.DimDate as DimDate
    -- on StageTargetCRS.Year = DimDate.CalendarYear
    -- INNER JOIN dbo.dimStore as dimStore 
    -- on StageTargetCRS.TargetName = dimStore.dimStoreName;