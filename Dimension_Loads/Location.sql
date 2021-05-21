IF EXISTS (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'dimLocation')
BEGIN
	DELETE FROM dbo.dimLocation;
END
GO


IF NOT EXISTS (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'dimLocation')
BEGIN
	CREATE TABLE dbo.dimLocation
	(
	dimLocationKey INT IDENTITY(1,1) CONSTRAINT PK_dimLocation PRIMARY KEY CLUSTERED NOT NULL, -- SurrogateKey
	dimAddress nvarchar(255) NOT NULL,
	dimCity nvarchar(255) NOT NULL,
	dimPostalCode nvarchar(255) NOT NULL,
    dimStateProvince nvarchar(255) NOT NULL,
    dimCountry nvarchar(255) NOT NULL,
	);
END
GO


IF EXISTS (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'dimLocation')
BEGIN
	-- ====================================
	-- Load dimLocation table
	-- ====================================

	INSERT INTO dbo.dimLocation
	(
	dimSourceLocationID
	,dimPostalCode
	,dimAddress
	,dimCity
	,dimRegion
	,dimCountry
	)
	SELECT DISTINCT
	CAST(dbo.StageCustomer.CustomerID AS VARCHAR(255))
	,CAST(dbo.StageCustomer.PostalCode AS INT)
	,dbo.StageCustomer.Address
	,dbo.StageCustomer.City
	,dbo.StageCustomer.StateProvince
	,dbo.StageCustomer.Country 
	FROM StageCustomer
	UNION
	SELECT DISTINCT
	CAST(dbo.StageStore.StoreID AS VARCHAR(255))
	,CAST(dbo.StageStore.PostalCode As INT) 
	,dbo.StageStore.Address 
	,dbo.StageStore.City 
	,dbo.StageStore.StateProvince 
	,dbo.StageStore.Country 
	FROM StageStore
	UNION 
	SELECT DISTINCT
	CAST(dbo.StageReseller.ResellerID AS VARCHAR(255))
	,CAST(dbo.StageReseller.PostalCode As INT) 
	,dbo.StageReseller.Address 
	,dbo.StageReseller.City 
	,dbo.StageReseller.StateProvince 
	,dbo.StageReseller.Country
	FROM StageReseller

END
GO 


-- =============================
-- Begin load of unknown member
-- =============================
SET IDENTITY_INSERT dbo.dimLocation ON;

INSERT INTO dbo.dimLocation
(
dimLocationKey
,dimAddress
,dimCity
,dimPostalCode
,dimStateProvince
,dimCountry
)
VALUES
(
-1
,'Unknown' 
,'Unknown'
,0
,'Unknown'
,'Unknown' 
);
SET IDENTITY_INSERT dbo.dimLocation OFF;
GO
