IF EXISTS (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'dimProduct')
BEGIN
	DELETE FROM dbo.dimProduct;
END
GO




IF NOT EXISTS (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'dimProduct')
BEGIN
	CREATE TABLE dbo.dimProduct
	(
	dimProductID INT IDENTITY(1,1) CONSTRAINT PK_dimProduct PRIMARY KEY CLUSTERED NOT NULL, -- SurrogateKey
	dimSourceProductID INT NOT NUll, --Natural Key
	dimSourceProductTypeID INT NOT NUll, --Natural Key
	dimSourceProductCategoryID INT NOT NUll, --Natural Key
    dimProductName Nvarchar(50) NOT NULL,
    dimProductType Nvarchar(50) NOT NULL,
    dimProductCategory Nvarchar(50) NOT NULL,
    dimProductRetailPrice numeric(18,2) NOT NULL,
    dimProductWholesalePrice numeric(18,2) NOT NULL,
    dimProductCost numeric(18,2) NOT NULL,
    dimProductRetailProfit numeric(18,2) NOT NULL,
    dimProductWholesaleUnitProfit numeric(18,2) NOT NULL,
    dimProductProfitMarginUnitPercent Decimal(5,2) NOT NULL,
	);
END
GO


IF EXISTS (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'dimProduct')
BEGIN
	-- ====================================
	-- Load dimProduct table
	-- ====================================

	INSERT INTO dbo.dimProduct
	(
	dimSourceProductID
    ,dimSourceProductTypeID
    ,dimSourceProductCategoryID
    ,dimProductName
    ,dimProductType
    ,dimProductCategory
    ,dimProductRetailPrice
    ,dimProductWholesalePrice
    ,dimProductCost
    ,dimProductRetailProfit
    ,dimProductWholesaleUnitProfit
    ,dimProductProfitMarginUnitPercent
	)
	SELECT 
	dbo.StageProduct.ProductID AS dimSourceProductID
	,dbo.StageProduct.ProductTypeID AS dimSourceProductTypeID
	,dbo.StageProductCategory.ProductCategoryID AS dimSourceProductCategoryID
	,dbo.StageProduct.Product AS dimProductName
	,dbo.StageProductType.ProductType AS dimProductType
	,dbo.StageProductCategory.ProductCategory AS dimProductCategory
	,dbo.StageProduct.Price AS dimProductRetailPrice
	,dbo.StageProduct.WholesalePrice AS dimProductWholesalePrice
	,dbo.StageProduct.Cost AS dimProductCost
	,(dbo.StageProduct.Price-dbo.StageProduct.Cost) AS dimProductRetailProfit
	,(dbo.StageProduct.WholesalePrice-dbo.StageProduct.Cost) AS dimProductWholesaleUnitProfit
	,(dbo.StageProduct.Price-dbo.StageProduct.Cost)/dbo.StageProduct.Price AS dimProductProfitMarginUnitPercent


	FROM StageProduct
    INNER JOIN StageProductType
	ON StageProduct.ProductTypeID = StageProductType.ProductTypeID
	INNER JOIN StageProductCategory
    ON StageProductType.ProductCategoryID = StageProductCategory.ProductCategoryID
	INNER JOIN StageSalesDetail
	ON StageSalesDetail.ProductID = StageProduct.ProductID;

END
GO 



-- =============================
-- Begin load of unknown member
-- =============================

SET IDENTITY_INSERT dbo.dimProduct ON;

INSERT INTO dbo.dimProduct
(
dimProductID
,dimSourceProductID
,dimSourceProductTypeID
,dimSourceProductCategoryID
,dimProductName
,dimProductType
,dimProductCategory
,dimProductRetailPrice
,dimProductWholesalePrice
,dimProductCost
,dimProductRetailProfit
,dimProductWholesaleUnitProfit
,dimProductProfitMarginUnitPercent
)
VALUES
(
-1
,-1
,-1
,-1
,'Unknown'
,'Unknown'
,'Unknown' 
,0.00
,0.00
,0.00
,0.00
,0.00
,0.00
);
SET IDENTITY_INSERT dbo.dimProduct OFF;
GO



