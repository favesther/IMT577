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
	)

	SELECT 
	Location.dimLocationKey AS dimLocationKey
	,Store.StoreID AS dimSourceStoreID
	,Storename.dimStoreName
	,Store.StoreNumber AS dimStoreNumber
	,Store.StoreManager AS dimStoreManager

	FROM (
		select cast(Prefix.column1+' '+Prefix.column2 AS nvarchar(255)) + cast(' '+Store1.StoreNumber AS nvarchar(255)) AS dimStoreName 
		from dbo.StageStore Store1, dbo.Prefix Prefix) Storename, dbo.StageStore Store
	INNER JOIN dbo.dimLocation Location
	ON Store.Address = Location.dimAddress;
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
)
VALUES
(
-1
,-1
,0
,'Unknown'
,0
,'Unknown'

);
SET IDENTITY_INSERT dbo.dimStore OFF;
GO
