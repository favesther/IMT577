IF EXISTS (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'dimCustomer')
BEGIN
	DELETE FROM dbo.dimCustomer;
END
GO



IF NOT EXISTS (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'dimCustomer')
BEGIN
	CREATE TABLE dbo.dimCustomer
	(
	dimCustomerID INT IDENTITY(1,1) CONSTRAINT PK_dimCustomer PRIMARY KEY CLUSTERED NOT NULL, -- SurrogateKey
	dimLocationKey INT NOT NULL CONSTRAINT FK_dimCustomer_dimLocationKey FOREIGN KEY REFERENCES dbo.dimLocation (dimLocationKey),
	dimSourceCustomerID uniqueidentifier NOT NUll, --Natural Key
    dimCustomerFullName Nvarchar(255) NOT NULL,
    dimCustomerFirstName Nvarchar(255) NOT NULL,
    dimCustomerLastName Nvarchar(255) NOT NULL,
    dimGender Nvarchar(55) NOT NULL
	);
END
GO


IF EXISTS (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'dimCustomer')
BEGIN
	-- ====================================
	-- Load dimCustomer table
	-- ====================================

	INSERT INTO dbo.dimCustomer
	(
    dimLocationKey
    ,dimSourceCustomerID
    ,dimCustomerFullName
    ,dimCustomerFirstName
    ,dimCustomerLastName
    ,dimGender
	)
	SELECT 
	dbo.dimLocation.dimLocationKey AS dimLocationKey
	,dbo.StageCustomer.CustomerID AS dimSourceCustomerID
	,dbo.StageCustomer.FirstName + ' ' + dbo.StageCustomer.LastName AS dimCustomerFullName
	,dbo.StageCustomer.FirstName AS dimCustomerFirstName
	,dbo.StageCustomer.LastName AS dimCustomerLastName
	,dbo.StageCustomer.Gender AS dimGender

	FROM StageCustomer
	INNER JOIN dimLocation
	ON StageCustomer.Address = dimLocation.dimAddress;
END
GO 




-- =============================
-- Begin load of unknown member
-- =============================

SET IDENTITY_INSERT dbo.dimCustomer ON;

INSERT INTO dbo.dimCustomer
(
dimCustomerID
,dimLocationKey
,dimSourceCustomerID
,dimCustomerFullName
,dimCustomerFirstName
,dimCustomerLastName
,dimGender

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
SET IDENTITY_INSERT dbo.dimCustomer OFF;
GO
