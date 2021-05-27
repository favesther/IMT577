IF EXISTS (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'factProductTarget')
BEGIN
	INSERT INTO dbo.factProductTarget
	(
		dimProductID
		,DimDateID
		,dimTargetSalesAmount
	)
	SELECT DISTINCT  
		   dbo.dimProduct.dimProductID
		  ,dbo.dimDate.DimDateID 
		   ,dbo.StageProductTarget.[ SalesQuantityTarget ] 
	FROM StageProductTarget
	INNER JOIN dbo.dimProduct ON
	dbo.dimProduct.dimProductID = dbo.StageProductTarget.ProductID
	LEFT OUTER JOIN dbo.dimDate ON
	dbo.dimDate.CalendarYear = dbo.StageProductTarget.Year 
END
GO 