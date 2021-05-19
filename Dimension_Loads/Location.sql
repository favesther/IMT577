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
	dimAddress
	,dimCity
	,dimStateProvince
    ,dimCountry
	,dimPostalCode
	)
	SELECT [Address]
		,[City]
		,[StateProvince]
		,[Country]
		,[PostalCode]
	FROM [dbo].[StageStore]
	UNION
	SELECT [Address]
		,[City]
		,[StateProvince]
		,[Country]
		,[PostalCode]
	FROM [dbo].[StageReseller]

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
