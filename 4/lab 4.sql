
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











-- Добавляем столбец с типом geometry (для хранения точек)
ALTER TABLE Warehouses
ADD Location geometry;

-- Обновляем существующие записи (пример)
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
    ('Склад 1', 'Киев', geometry::Point(30.5234, 50.4501, 4326)),
    ('Склад 2', 'Львов', geometry::Point(24.0316, 49.8422, 4326));












-- 6. Определение типа пространственных данных
SELECT DISTINCT 
    Location.STGeometryType() AS GeometryType
FROM Warehouses
WHERE Location IS NOT NULL;


-- 7. Определение SRID////

SELECT DISTINCT 
    Location.STSrid AS SRID
FROM Warehouses
WHERE Location IS NOT NULL;

-- 8. Определение атрибутивных столбцов///
SELECT COLUMN_NAME, DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'Warehouses';

-- 9. Возврат описаний в формате WKT
SELECT 
    ID,
    Name,
    Location.STAsText() AS WKT_Representation
FROM Warehouses
WHERE Location IS NOT NULL;

-- 10. Демонстрация операций

-- 10.1. Нахождение пересечения 
DECLARE @warehouse1 geometry = (SELECT TOP 1 Location FROM Warehouses WHERE ID = 1);
DECLARE @warehouse2 geometry = (SELECT TOP 1 Location FROM Warehouses WHERE ID = 2);

-- буфер вокруг точек 
DECLARE @buffer1 geometry = @warehouse1.STBuffer(0.1);
DECLARE @buffer2 geometry = @warehouse2.STBuffer(0.1);

SELECT 
    @buffer1.STIntersection(@buffer2).STAsText() AS IntersectionWKT;







	-- вариант 2

	-- 1. 
DECLARE @TestWarehouses TABLE (
    ID INT,
    Name VARCHAR(100),
    Location GEOMETRY
);

-- 2. 2 точки в 50 метрах друг от друга 
INSERT INTO @TestWarehouses (ID, Name, Location)
VALUES 
    (1, 'Склад A', geometry::Point(30.5234, 50.4501, 4326)),  
    (2, 'Склад B', geometry::Point(30.5240, 50.4505, 4326));  

-- 3. буферы по 150 метров
DECLARE @point1 GEOMETRY = (SELECT Location FROM @TestWarehouses WHERE ID = 1);
DECLARE @point2 GEOMETRY = (SELECT Location FROM @TestWarehouses WHERE ID = 2);

DECLARE @buffer1 GEOMETRY = @point1.STBuffer(0.00135);  
DECLARE @buffer2 GEOMETRY = @point2.STBuffer(0.00135);

-- 4. Проверяем пересечение
SELECT 
    @buffer1.STIntersection(@buffer2).STAsText() AS IntersectionWKT,
    @buffer1.STIntersection(@buffer2).STArea() AS IntersectionArea; 

-- 5. Виз
SELECT 'BUFFER 1' AS Object, @buffer1.STAsText() AS WKT UNION ALL
SELECT 'BUFFER 2' AS Object, @buffer2.STAsText() AS WKT UNION ALL
SELECT 'INTERSECTION' AS Object, @buffer1.STIntersection(@buffer2).STAsText() AS WKT;






-- 10.2. Координаты вершин

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

-- 10.3. Площадь 
-- Создаем точку с явным указанием SRID 4326 
DECLARE @point geometry = geometry::Point(30.5234, 50.4501, 4326);


DECLARE @buffer1 geometry = @point.STBuffer(0.1);

SELECT @buffer1.STArea() AS BufferArea;

-- 11. Создание пространственных объектов

-- Точка (1)
DECLARE @point geometry = geometry::STPointFromText('POINT(30.5234 50.4501)', 4326);

-- Линия (2)
DECLARE @line geometry = geometry::STLineFromText('LINESTRING(30.5234 50.4501, 30.5244 50.4501)', 4326);


-- Полигон (3)
DECLARE @polygon geometry = geometry::STPolyFromText('POLYGON((30.5234 50.4501, 30.5244 50.4501, 30.5244 50.4511, 30.5234 50.4501))', 4326);

-- 12. Поиск объектов, содержащих созданные

-- Для точки 
SELECT 
    ID,
    Name,
    Location.STAsText() AS WarehouseLocation
FROM Warehouses
WHERE Location.STDistance(@point) < 1.0;


-- лин
SELECT 
    ID,
    Name,
    Location.STAsText() AS WarehouseLocation
FROM Warehouses
WHERE Location.STIntersects(@line) = 1;

-- полигон

SELECT 
    ID,
    Name,
    Location.STAsText() AS WarehouseLocation
FROM Warehouses
WHERE Location.STWithin(@polygon) = 1;

-- 13. Индексирование пространственных объектов

CREATE SPATIAL INDEX IX_Warehouses_Location
ON Warehouses(Location)
WITH (BOUNDING_BOX = (20, 50, 40, 60));  


DECLARE @point geometry = geometry::STPointFromText('POINT(30.5234 50.4501)', 4326);

-- Проверка использования индекса
SELECT 
    ID,
    Name
FROM Warehouses WITH(INDEX(IX_Warehouses_Location))
WHERE Location.STDistance(@point) < 1.0;

-- 14. Хранимая процедура для поиска по точке
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