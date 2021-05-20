IF EXISTS (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'factSRCSalesTarget')
BEGIN
	DELETE FROM dbo.factSRCSalesTarget;
END
GO



IF NOT EXISTS (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'factSRCSalesTarget')
BEGIN
	CREATE TABLE dbo.factSRCSalesTarget
	(
	factSRCSalesTargetKey INT IDENTITY(1,1) CONSTRAINT PK_factSRCSalesTargetKey PRIMARY KEY CLUSTERED NOT NULL, -- SurrogateKey    dimChannelID INT NOT NULL CONSTRAINT FK_factSalesActual_dimChannelID FOREIGN KEY REFERENCES dbo.dimChannel (dimChannelID),
    dimChannelID INT NOT NULL CONSTRAINT FK_PK_factSRCSalesTarget_dimChannelID FOREIGN KEY REFERENCES dbo.dimChannel (dimChannelID),
	dimSRCname nvarchar(255) NOT NULL,
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
	dimChannelID
	dimSRCname,
	dimTargetDateKey,
	SalesTargetSalesAmount
	)

	SELECT CRS.TargetName,CRS.dimChannelID DimDate.DimDateID, CAST(CRS.TargetSalesAmount AS int)/365.0
	FROM (
		select StageTargetCRS.*, Channel.dimChannelID
		from dbo.StageTargetCRS StageTargetCRS
		left join dbo.dimChannel Channel
		on StageTargetCRS.ChannelName = Channel.dimChannelName) CRS, dbo.DimDate DimDate
	WHERE CRS.Year = DimDate.CalendarYear

	-- FROM StageTargetCRS
    -- INNER JOIN dbo.dimChannel as dimChannel
    -- ON StageTargetCRS.ChannelName = dimChannel.dimChannelName 
    -- INNER JOIN dbo.dimReseller as dimReseller
    -- StageTargetCRS.TargetName = dimReseller.dimResellerName
    -- INNER JOIN dbo.DimDate as DimDate
    -- on StageTargetCRS.Year = DimDate.CalendarYear
    -- INNER JOIN dbo.dimStore as dimStore 
    -- on StageTargetCRS.TargetName = dimStore.dimStoreName;
    
END
GO 
