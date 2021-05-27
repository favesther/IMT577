IF EXISTS (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'factSales')
BEGIN
	INSERT INTO dbo.factSales
	(
		dimProductID
		,dimChannelID
		,dimResellerID
		,dimCustomerID
		,dimStoreID
		,factSaleQuantity
		,factSaleAmount
		,dimDateID		
	)
	SELECT 
		ISNULL(dbo.dimProduct.dimProductID, -1)
		,ISNULL(dbo.dimChannel.dimChannelID, -1)
		,ISNULL(dbo.dimReseller.dimResellerID, -1)
		,ISNULL(dbo.dimCustomer.dimCustomerID, -1)
		,ISNULL(dbo.dimStore.dimStoreID, -1)
		,dbo.StageSalesDetail.SalesQuantity
		,dbo.StageSalesDetail.SalesAmount
		,dbo.dimDate.DimDateID
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
END
GO 