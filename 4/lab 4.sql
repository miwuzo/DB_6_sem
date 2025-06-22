
CREATE TABLE Warehouses (
    ID INT PRIMARY KEY DEFAULT NEXT VALUE FOR SeqWarehouses,
    Name VARCHAR(100) NOT NULL,
    Address VARCHAR(255),
    Area DECIMAL,
    ContactInfo VARCHAR(255),
    Type VARCHAR(255)
);

CREATE TABLE Positions (
    ID INT PRIMARY KEY DEFAULT NEXT VALUE FOR SeqPositions,
    Name VARCHAR(100) NOT NULL,
    Description TEXT,
    AccessLevel INT,
    WarehouseID INT NULL,
    IsActive BIT DEFAULT 1,
    FOREIGN KEY (WarehouseID) REFERENCES Warehouses(ID)
);

CREATE TABLE Employees (
    ID INT PRIMARY KEY DEFAULT NEXT VALUE FOR SeqEmployees,
    FullName VARCHAR(255) NOT NULL,
    PositionID INT NOT NULL,
    WarehouseID INT NOT NULL,
    ContactInfo VARCHAR(255),
    Status VARCHAR(50) DEFAULT 'active',
    FOREIGN KEY (PositionID) REFERENCES Positions(ID),
    FOREIGN KEY (WarehouseID) REFERENCES Warehouses(ID)
);

CREATE TABLE Products (
    ID INT PRIMARY KEY DEFAULT NEXT VALUE FOR SeqProducts,
    Name VARCHAR(255) NOT NULL,
    Article VARCHAR(50),
    Description TEXT,
    MeasurementUnit VARCHAR(50),
    Price DECIMAL
);

CREATE TABLE Receipts (
    ID INT PRIMARY KEY DEFAULT NEXT VALUE FOR SeqReceipts,
    Date DATE,
    Supplier VARCHAR(50),
    InvoiceNumber VARCHAR(50),
    WarehouseID INT NOT NULL,
    Total DECIMAL,
    FOREIGN KEY (WarehouseID) REFERENCES Warehouses(ID)
);

CREATE TABLE Shipments (
    ID INT PRIMARY KEY DEFAULT NEXT VALUE FOR SeqShipments,
    Date DATE,
    Client VARCHAR(50),
    InvoiceNumber VARCHAR(50),
    WarehouseID INT NOT NULL,
    Total DECIMAL,
    FOREIGN KEY (WarehouseID) REFERENCES Warehouses(ID)
);











-- ��������� ������� � ����� geometry (��� �������� �����)
ALTER TABLE Warehouses
ADD Location geometry;

-- ��������� ������������ ������ (������)
UPDATE Warehouses
SET Location = geometry::Point(37.6178, 55.7512, 4326)  
WHERE ID = 2;






CREATE TABLE Imported_Data (
    ID INT IDENTITY(1,1),
    Name VARCHAR(100),
    WKT_Geometry TEXT,
    Shape GEOMETRY
);










INSERT INTO Warehouses (Name, Address, Location)
VALUES 
    ('����� 1', '����', geometry::Point(30.5234, 50.4501, 4326)),
    ('����� 2', '�����', geometry::Point(24.0316, 49.8422, 4326));












-- 6. ����������� ���� ���������������� ������
SELECT DISTINCT 
    Location.STGeometryType() AS GeometryType
FROM Warehouses
WHERE Location IS NOT NULL;


-- 7. ����������� SRID////

SELECT DISTINCT 
    Location.STSrid AS SRID
FROM Warehouses
WHERE Location IS NOT NULL;

-- 8. ����������� ������������ ��������///
SELECT COLUMN_NAME, DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'Warehouses';

-- 9. ������� �������� � ������� WKT
SELECT 
    ID,
    Name,
    Location.STAsText() AS WKT_Representation
FROM Warehouses
WHERE Location IS NOT NULL;

-- 10. ������������ ��������

-- 10.1. ���������� ����������� 
DECLARE @warehouse1 geometry = (SELECT TOP 1 Location FROM Warehouses WHERE ID = 1);
DECLARE @warehouse2 geometry = (SELECT TOP 1 Location FROM Warehouses WHERE ID = 2);

-- ����� ������ ����� 
DECLARE @buffer1 geometry = @warehouse1.STBuffer(0.1);
DECLARE @buffer2 geometry = @warehouse2.STBuffer(0.1);

SELECT 
    @buffer1.STIntersection(@buffer2).STAsText() AS IntersectionWKT;







	-- ������� 2

	-- 1. 
DECLARE @TestWarehouses TABLE (
    ID INT,
    Name VARCHAR(100),
    Location GEOMETRY
);

-- 2. 2 ����� � 50 ������ ���� �� ����� 
INSERT INTO @TestWarehouses (ID, Name, Location)
VALUES 
    (1, '����� A', geometry::Point(30.5234, 50.4501, 4326)),  
    (2, '����� B', geometry::Point(30.5240, 50.4505, 4326));  

-- 3. ������ �� 150 ������
DECLARE @point1 GEOMETRY = (SELECT Location FROM @TestWarehouses WHERE ID = 1);
DECLARE @point2 GEOMETRY = (SELECT Location FROM @TestWarehouses WHERE ID = 2);

DECLARE @buffer1 GEOMETRY = @point1.STBuffer(0.00135);  
DECLARE @buffer2 GEOMETRY = @point2.STBuffer(0.00135);

-- 4. ��������� �����������
SELECT 
    @buffer1.STIntersection(@buffer2).STAsText() AS IntersectionWKT,
    @buffer1.STIntersection(@buffer2).STArea() AS IntersectionArea; 

-- 5. ���
SELECT 'BUFFER 1' AS Object, @buffer1.STAsText() AS WKT UNION ALL
SELECT 'BUFFER 2' AS Object, @buffer2.STAsText() AS WKT UNION ALL
SELECT 'INTERSECTION' AS Object, @buffer1.STIntersection(@buffer2).STAsText() AS WKT;






-- 10.2. ���������� ������

DECLARE @point geometry = geometry::Point(30.5234, 50.4501, 4326);
DECLARE @buffer geometry = @point.STBuffer(0.1);


SELECT 
    @buffer.STAsText() AS BufferWKT,
    @buffer.STNumPoints() AS NumPoints;

WITH Numbers AS (
    SELECT TOP (100) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.objects
)
SELECT 
    n AS PointNumber,
    @buffer.STPointN(n).STX AS Longitude,
    @buffer.STPointN(n).STY AS Latitude
FROM Numbers
WHERE n <= @buffer.STNumPoints();

-- 10.3. ������� 
-- ������� ����� � ����� ��������� SRID 4326 
DECLARE @point geometry = geometry::Point(30.5234, 50.4501, 4326);


DECLARE @buffer1 geometry = @point.STBuffer(0.1);

SELECT @buffer1.STArea() AS BufferArea;

-- 11. �������� ���������������� ��������

-- ����� (1)
DECLARE @point geometry = geometry::STPointFromText('POINT(30.5234 50.4501)', 4326);

-- ����� (2)
DECLARE @line geometry = geometry::STLineFromText('LINESTRING(30.5234 50.4501, 30.5244 50.4501)', 4326);


-- ������� (3)
DECLARE @polygon geometry = geometry::STPolyFromText('POLYGON((30.5234 50.4501, 30.5244 50.4501, 30.5244 50.4511, 30.5234 50.4501))', 4326);

-- 12. ����� ��������, ���������� ���������

-- ��� ����� 
SELECT 
    ID,
    Name,
    Location.STAsText() AS WarehouseLocation
FROM Warehouses
WHERE Location.STDistance(@point) < 1.0;


-- ���
SELECT 
    ID,
    Name,
    Location.STAsText() AS WarehouseLocation
FROM Warehouses
WHERE Location.STIntersects(@line) = 1;

-- �������

SELECT 
    ID,
    Name,
    Location.STAsText() AS WarehouseLocation
FROM Warehouses
WHERE Location.STWithin(@polygon) = 1;

-- 13. �������������� ���������������� ��������

CREATE SPATIAL INDEX IX_Warehouses_Location
ON Warehouses(Location)
WITH (BOUNDING_BOX = (20, 50, 40, 60));  


DECLARE @point geometry = geometry::STPointFromText('POINT(30.5234 50.4501)', 4326);

-- �������� ������������� �������
SELECT 
    ID,
    Name
FROM Warehouses WITH(INDEX(IX_Warehouses_Location))
WHERE Location.STDistance(@point) < 1.0;

-- 14. �������� ��������� ��� ������ �� �����
CREATE OR ALTER PROCEDURE FindWarehousesNearPoint
    @longitude FLOAT,
    @latitude FLOAT,
    @distance FLOAT = 1.0,  
    @srid INT = 4326
AS
BEGIN
    DECLARE @point geometry = geometry::Point(@longitude, @latitude, @srid);
    
    SELECT 
        ID,
        Name,
        Address,
        Location.STAsText() AS LocationWKT,
        Location.STDistance(@point) AS Distance
    FROM Warehouses
    WHERE Location.STDistance(@point) < @distance
    ORDER BY Distance;
END;
GO


EXEC FindWarehousesNearPoint 30.5234, 50.4501, 0.5;