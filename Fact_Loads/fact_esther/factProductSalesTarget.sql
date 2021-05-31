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
    -- DimDateID INT NOT NULL CONSTRAINT FK_factProductSalesTarget_DimDate FOREIGN KEY REFERENCES dbo.DimDate (DimDateID),
    dimTargetSalesAmount INT NOT NULL,
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
    ,DimDateID
    ,dimTargetSalesAmount
	)
	SELECT DISTINCT
	dbo.dimProduct.dimProductID
    ,dbo.DimDate.DimDateID
    ,dbo.StageTargetProduct.SalesQuantityTarget
    FROM StageTargetProduct
	INNER JOIN dbo.dimProduct
	ON dbo.StageTargetProduct.ProductID = dbo.dimProduct.dimSourceProductID
	LEFT OUTER JOIN dbo.DimDate
    ON dbo.StageTargetProduct.Year = dbo.DimDate.CalendarYear;
END
GO 


