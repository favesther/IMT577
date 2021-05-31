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
	DimDateID INT NOT NULL CONSTRAINT FK_factRSCSalesTarget_DimDateID FOREIGN KEY REFERENCES dbo.DimDate (DimDateID),
	dimTargetSalesAmount DECIMAL(16,6) NOT NULL,
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
	,dimResellerKey
	,dimChannelID
	-- ,dimSRCname
	,DimDateID
	,dimTargetSalesAmount
	)

	SELECT DISTINCT
	ISNULL(dbo.dimStore.dimStoreKey,-1)  AS dimStoreKey
	,ISNULL(dbo.dimReseller.dimResellerKey,-1) 	AS dimResellerKey
	,dbo.dimChannel.dimChannelID
	-- CRS.TargetName AS dimSRCname,
	,dbo.DimDate.DimDateID
	,CONVERT(DECIMAL(16,6), dbo.StageTargetCRS.[ TargetSalesAmount ]) AS measureChannelTarget
	FROM StageTargetCRS
	INNER join dimChannel
	on dbo.StageTargetCRS.ChannelName = dbo.dimChannel.dimChannelName
	left OUTER join dimStore
	on dbo.StageTargetCRS.TargetName = dbo.dimStore.dimStoreName
	left OUTER join dbo.dimReseller
	on dbo.StageTargetCRS.TargetName = dbo.dimReseller.dimResellerName
	left OUTER join DimDate
	on dbo.StageTargetCRS.Year = dbo.DimDate.CalendarYear; 
END
GO 