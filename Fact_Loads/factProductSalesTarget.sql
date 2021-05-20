IF EXISTS (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'factProductSalesTarget')
BEGIN
	DELETE FROM dbo.factProductSalesTarget;
END
GO



IF NOT EXISTS (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'factProductSalesTarget')
BEGIN
	CREATE TABLE dbo.factProductSalesTarget
	(
	dimfactProductSalesTargetKey INT IDENTITY(1,1) CONSTRAINT PK_factProductSalesTarget PRIMARY KEY CLUSTERED NOT NULL, -- SurrogateKey
    dimProductKey INT NOT NULL CONSTRAINT FK_factProductSalesTarget_dimProduct FOREIGN KEY REFERENCES dbo.dimProduct (dimProductKey),
    dimTargetDateKey INT NOT NULL CONSTRAINT FK_factProductSalesTarget_DimDate FOREIGN KEY REFERENCES dbo.DimDate (dimDateID),
    ProductTargetSalesAmount Numeric(16,6) NOT NULL,
	);
END
GO


IF EXISTS (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'factProductSalesTarget')
BEGIN
	-- ====================================
	-- Load factProductSalesTarget table
	-- ====================================

	INSERT INTO dbo.factProductSalesTarget
	(
    dimProductKey
    dimTargetDateKey
    ProductTargetSalesAmount
	)
	SELECT p.dimProductKey
    , d.DimDateID as dimTargetDateKey
    ,CAST(pt.SalesQuantityTarget AS int)/365.0 as ProductTargetSalesAmount
    FROM dbo.StageProductTarget pt, dbo.dimProduct p, dbo.DimDate d
    WHERE pt.Year = d.CalendarYear
END
GO 

