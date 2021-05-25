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
    dimProductID INT NOT NULL CONSTRAINT FK_factProductSalesTarget_dimProduct FOREIGN KEY REFERENCES dbo.dimProduct (dimProductID),
    dimTargetDateKey INT NOT NULL CONSTRAINT FK_factProductSalesTarget_DimDate FOREIGN KEY REFERENCES dbo.DimDate (DimDateID),
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
    dimProductID
    ,dimTargetDateKey
    ,ProductTargetSalesAmount
	)
	SELECT pt.dimProductID
    ,d.DimDateID as dimTargetDateKey
    ,CAST(TP.SalesQuantityTarget AS int)/365.0 as ProductTargetSalesAmount
    FROM dbo.StageTargetProduct TP
	LEFT join dbo.dimProduct pt
	ON TP.ProductID = pt.dimSourceProductID
	LEFT JOIN dbo.DimDate d
    ON TP.Year = d.CalendarYear
END
GO 


