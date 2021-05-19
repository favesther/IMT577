IF EXISTS (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'dimReseller')
BEGIN
	DELETE FROM dbo.dimReseller;
END
GO


IF NOT EXISTS (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'dimReseller')
BEGIN
	CREATE TABLE dbo.dimReseller
	(
	dimResellerKey INT IDENTITY(1,1) CONSTRAINT PK_dimReseller PRIMARY KEY CLUSTERED NOT NULL, -- SurrogateKey
	dimLocationKey INT NOT NULL CONSTRAINT FK_dimReseller_DimLocationKey FOREIGN KEY REFERENCES dbo.dimLocation (dimLocationKey),
	dimSourceResellerID uniqueidentifier NOT NUll, --Natural Key
    dimResellerName Nvarchar(255) NOT NULL,
    dimContact Nvarchar(255) NOT NULL,
    dimPhoneNumber nvarchar(20) NOT NULL,
    dimEmailAddress Nvarchar(255) NOT NULL
	);
END
GO


IF EXISTS (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'dimReseller')
BEGIN
	-- ====================================
	-- Load dimReseller table
	-- ====================================

	INSERT INTO dbo.dimReseller
	(
    dimLocationKey
    ,dimSourceResellerID
    ,dimResellerName
    ,dimContact
    ,dimPhoneNumber
    ,dimEmailAddress
	)
	SELECT 
    dbo.dimLocation.dimLocationKey AS dimLocationKey
	,dbo.StageReseller.ResellerID AS dimSourceResellerID
	,dbo.StageReseller.ResellerName AS dimResellerName
	,dbo.StageReseller.Contact AS dimContact
	,dbo.StageReseller.PhoneNumber AS dimPhoneNumber
	,dbo.StageReseller.EmailAddress AS dimEmailAddress

	FROM StageReseller
	INNER JOIN dimLocation
	ON StageReseller.Address = dimLocation.dimAddress;
END
GO 



-- =============================
-- Begin load of unknown member
-- =============================

SET IDENTITY_INSERT dbo.dimReseller ON;

INSERT INTO dbo.dimReseller
(
dimResellerKey
,dimLocationKey
,dimSourceResellerID
,dimResellerName
,dimContact
,dimPhoneNumber
,dimEmailAddress
)
VALUES
(
-1
,-1
, NEWID ( ) 
,'Unknown'
,'Unknown'
,'Unknown'
,'Unknown'
);
SET IDENTITY_INSERT dbo.dimReseller OFF;
GO

