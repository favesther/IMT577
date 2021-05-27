IF EXISTS (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'factChannelTarget')
BEGIN
	INSERT INTO dbo.factChannelTarget
	(
		dimChannelID
		,dimStoreID
		,dimResellerID
		,DimDateID
		,dimTargetSalesAmount
	) 
	SELECT DISTINCT   
		   dbo.dimChannel.dimChannelID
		   ,ISNULL(dbo.dimStore.dimStoreID, -1) AS dimStoreID
		   ,ISNULL(dbo.dimReseller.dimResellerID, -1) AS dimReseller
		   ,dbo.dimDate.DimDateID
		   ,CONVERT(DECIMAL(16,6), dbo.StageChannelTarget.[ TargetSalesAmount ]) AS measureChannelTarget
	FROM StageChannelTarget
	INNER JOIN dbo.dimChannel ON
	dbo.dimChannel.dimChannelName = dbo.StageChannelTarget.ChannelName
	LEFT OUTER JOIN dimStore  ON
	dbo.dimStore.dimStoreNumber = 
	CASE  
		WHEN dbo.StageChannelTarget.TargetName = 'Store Number 5'  
		THEN CAST('5' AS INT)
		WHEN dbo.StageChannelTarget.TargetName = 'Store Number 8'  
		THEN CAST('8' AS INT)
		WHEN dbo.StageChannelTarget.TargetName = 'Store Number 10'  
		THEN CAST('10' AS INT)
		WHEN dbo.StageChannelTarget.TargetName = 'Store Number 21'  
		THEN CAST('21' AS INT)
		WHEN dbo.StageChannelTarget.TargetName = 'Store Number 34'  
		THEN CAST('34' AS INT)
		WHEN dbo.StageChannelTarget.TargetName = 'Store Number 39'  
		THEN CAST('39' AS INT)
		WHEN dbo.StageChannelTarget.TargetName = 'Store Number 39'  
		THEN CAST('39' AS INT)
	END
	OR 
	dbo.dimStore.dimRegion = 	
	CASE
		WHEN dbo.StageChannelTarget.TargetName = 'Mississippi Distributors'  
		THEN CAST('Mississippi' AS VARCHAR(255))
		WHEN dbo.StageChannelTarget.TargetName = 'Georgia Mega Store'  
		THEN CAST('Georgia' AS VARCHAR(255))
	END
	LEFT OUTER JOIN dbo.dimReseller ON
	dbo.dimReseller.dimResellerName = dbo.StageChannelTarget.TargetName
	LEFT OUTER JOIN dbo.dimDate ON
	dbo.dimDate.CalendarYear = dbo.StageChannelTarget.Year
END
GO 