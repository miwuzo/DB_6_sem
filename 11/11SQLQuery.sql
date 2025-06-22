CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    ProductName NVARCHAR(100),
    Price DECIMAL(18, 2),
    ManufactureDate DATE
);

CREATE TABLE StorageLocations (
    LocationID INT PRIMARY KEY,
    LocationName NVARCHAR(100),
    Capacity INT
);

INSERT INTO Products (ProductID, ProductName, Price, ManufactureDate) VALUES 
(1, 'Product A', 100.00, '2023-01-10'),
(2, 'Product B', 200.00, '2023-03-15'),
(3, 'Product C', 300.00, '2023-05-20');

INSERT INTO StorageLocations (LocationID, LocationName, Capacity) VALUES
(1, 'Warehouse 1', 500),
(2, 'Warehouse 2', 300),
(3, 'Warehouse 3', 800);



select * from prod


CREATE FUNCTION dbo.GetProductsByDateRange (@StartDate DATE, @EndDate DATE)
RETURNS TABLE
AS
RETURN (
    SELECT P.ProductID, P.ProductName, P.Price, P.ManufactureDate, S.LocationName 
    FROM Products P
    JOIN StorageLocations S ON P.ProductID = S.LocationID
    WHERE P.ManufactureDate BETWEEN @StartDate AND @EndDate
);


SELECT * FROM dbo.GetProductsByDateRange('2023-01-01', '2023-12-31');

select * from vw_ProductsByDateRange;


CREATE or alter VIEW vw_ProductsByDateRange AS
SELECT * FROM dbo.GetProductsByDateRange('2023-01-01', '2023-12-31');


SELECT @@SERVERNAME AS ServerName;


SELECT * FROM [dbo].[11];
delete from [dbo].[11];

drop table [dbo].[11];

