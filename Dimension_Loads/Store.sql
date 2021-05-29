IF EXISTS (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'dimStore')
BEGIN
	DELETE FROM dbo.dimStore;
END
GO


IF NOT EXISTS (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'dimStore')
BEGIN
	CREATE TABLE dbo.dimStore
	(
	dimStoreKey INT IDENTITY(1,1) CONSTRAINT PK_dimStore PRIMARY KEY CLUSTERED NOT NULL, -- SurrogateKey
	dimLocationKey INT NOT NULL CONSTRAINT FK_dimStore_dimLocationKey FOREIGN KEY REFERENCES dbo.dimLocation (dimLocationKey),
	dimSourceStoreID INT NOT NUll, --Natural Key
    dimStoreName nvarchar(255) NOT NULL,
	dimStoreNumber INT NOT NULL,
    dimStoreManager nvarchar(255) NOT NULL,
	dimRegion nvarchar(255) NOT NULL,
	);
END
GO


IF EXISTS (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'dimStore')
BEGIN
	-- ====================================
	-- Load dimStore table
	-- ====================================
	INSERT INTO dbo.dimStore
	(
	dimLocationKey
    ,dimSourceStoreID
	,dimStoreName
    ,dimStoreNumber
    ,dimStoreManager
	,dimRegion
	)

	SELECT 
	dbo.dimLocation.dimLocationKey AS dimLocationKey
	,Store.StoreID AS dimSourceStoreID
	,concat('Store Number',' ',Store.StoreNumber) AS dimStoreName
	,Store.StoreNumber AS dimStoreNumber
	,Store.StoreManager AS dimStoreManager
	,Store.StateProvince AS dimRegion

	FROM dbo.StageStore Store
	INNER JOIN dimLocation
	ON Store.Address = dbo.dimLocation.dimAddress or Store.PostalCode = dbo.dimLocation.dimPostalCode;

END
GO 


-- =============================
-- Begin load of unknown member
-- =============================
SET IDENTITY_INSERT dbo.dimStore ON;

INSERT INTO dbo.dimStore
(
dimStoreKey
,dimLocationKey
,dimSourceStoreID
,dimStoreName
,dimStoreNumber
,dimStoreManager
,dimRegion
)
VALUES
(
-1
,-1
,0
,'Unknown'
,0
,'Unknown'
,'Unknown'
);
SET IDENTITY_INSERT dbo.dimStore OFF;
GO
