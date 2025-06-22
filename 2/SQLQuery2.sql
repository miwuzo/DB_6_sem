
-- ПОСЛЕДОВАТЕЛЬНОСТИ

CREATE SEQUENCE SeqWarehouses START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE SeqPositions START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE SeqEmployees START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE SeqProducts START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE SeqReceipts START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE SeqShipments START WITH 1 INCREMENT BY 1;


	


-- ТАБЛИЦЫ

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





-- ИНДЕКСЫ

CREATE INDEX IX_Receipts_WarehouseID ON Receipts (WarehouseID);
CREATE INDEX IX_Shipments_WarehouseID ON Shipments (WarehouseID);
CREATE INDEX IX_Employees_PositionID ON Employees (PositionID);
CREATE INDEX IX_Employees_WarehouseID ON Employees (WarehouseID);
CREATE INDEX IX_Positions_WarehouseID ON Positions (WarehouseID);
CREATE INDEX IX_Products_Name ON Products (Name); 







-- ПРЕДСТАВЛЕНИЯ

-- Журнал отгрузок
Select * from ShipmentLog;
Select * from ReceiptLog;

CREATE VIEW ShipmentLog AS
SELECT
    s.ID,
    s.Date,
    s.Client,
    s.InvoiceNumber,
    w.Name AS WarehouseName,
    s.Total
FROM Shipments s
JOIN Warehouses w ON s.WarehouseID = w.ID;
GO

-- Журнал поступлений
CREATE VIEW ReceiptLog AS
SELECT
    r.ID,
    r.Date,
    r.Supplier,
    r.InvoiceNumber,
    w.Name AS WarehouseName,
    r.Total
FROM Receipts r
JOIN Warehouses w ON r.WarehouseID = w.ID;
GO











-- ПРОЦЕДУРЫ

-- Создание поступления
CREATE PROCEDURE CreateReceipt
    @Date DATE,
    @Supplier VARCHAR(50),
    @InvoiceNumber VARCHAR(50),
    @WarehouseID INT,
    @Total DECIMAL
AS
BEGIN
    -- Проверка существования склада
    IF NOT EXISTS (SELECT 1 FROM Warehouses WHERE ID = @WarehouseID)
    BEGIN
        RAISERROR('Указанный склад не существует.', 16, 1)
        RETURN
    END

    -- Валидация данных 
    IF @Date IS NULL OR @Supplier IS NULL OR @InvoiceNumber IS NULL OR @Total IS NULL
    BEGIN
        RAISERROR('Не все обязательные поля заполнены.', 16, 1)
        RETURN
    END

    IF @Total < 0
    BEGIN
        RAISERROR('Сумма поступления не может быть отрицательной.', 16, 1)
        RETURN
    END

    BEGIN TRY
        INSERT INTO Receipts (Date, Supplier, InvoiceNumber, WarehouseID, Total)
        VALUES (@Date, @Supplier, @InvoiceNumber, @WarehouseID, @Total)

        SELECT SCOPE_IDENTITY(); -- Возвращает ID созданной записи
    END TRY
    BEGIN CATCH
       THROW; 
	END CATCH
END
GO

-- Редактирование поступления
CREATE PROCEDURE UpdateReceipt
    @ID INT,
    @Date DATE,
    @Supplier VARCHAR(50),
    @InvoiceNumber VARCHAR(50),
    @WarehouseID INT,
    @Total DECIMAL
AS
BEGIN
    -- Проверка существования поступления
    IF NOT EXISTS (SELECT 1 FROM Receipts WHERE ID = @ID)
    BEGIN
        RAISERROR('Поступление с указанным ID не найдено.', 16, 1)
        RETURN
    END

    -- Проверка существования склада
    IF NOT EXISTS (SELECT 1 FROM Warehouses WHERE ID = @WarehouseID)
    BEGIN
        RAISERROR('Указанный склад не существует.', 16, 1)
        RETURN
    END

    -- Валидация данных 
    IF @Date IS NULL OR @Supplier IS NULL OR @InvoiceNumber IS NULL OR @Total IS NULL
    BEGIN
        RAISERROR('Не все обязательные поля заполнены.', 16, 1)
        RETURN
    END

    IF @Total < 0
    BEGIN
        RAISERROR('Сумма поступления не может быть отрицательной.', 16, 1)
        RETURN
    END


    BEGIN TRY
        UPDATE Receipts
        SET Date = @Date,
            Supplier = @Supplier,
            InvoiceNumber = @InvoiceNumber,
            WarehouseID = @WarehouseID,
            Total = @Total
        WHERE ID = @ID
    END TRY
    BEGIN CATCH
       THROW;
    END CATCH
END
GO

-- Создание отгрузки
CREATE PROCEDURE CreateShipment
    @Date DATE,
    @Client VARCHAR(50),
    @InvoiceNumber VARCHAR(50),
    @WarehouseID INT,
    @Total DECIMAL
AS
BEGIN
    -- Проверка существования склада
    IF NOT EXISTS (SELECT 1 FROM Warehouses WHERE ID = @WarehouseID)
    BEGIN
        RAISERROR('Указанный склад не существует.', 16, 1)
        RETURN
    END

    -- Валидация данных (примеры)
    IF @Date IS NULL OR @Client IS NULL OR @InvoiceNumber IS NULL OR @Total IS NULL
    BEGIN
        RAISERROR('Не все обязательные поля заполнены.', 16, 1)
        RETURN
    END

    IF @Total < 0
    BEGIN
        RAISERROR('Сумма отгрузки не может быть отрицательной.', 16, 1)
        RETURN
    END

    BEGIN TRY
        INSERT INTO Shipments (Date, Client, InvoiceNumber, WarehouseID, Total)
        VALUES (@Date, @Client, @InvoiceNumber, @WarehouseID, @Total)

        SELECT SCOPE_IDENTITY(); -- Возвращает ID созданной записи
    END TRY
    BEGIN CATCH
        THROW; 
    END CATCH
END
GO

-- Редактирование отгрузки
CREATE PROCEDURE UpdateShipment
    @ID INT,
    @Date DATE,
    @Client VARCHAR(50),
    @InvoiceNumber VARCHAR(50),
    @WarehouseID INT,
    @Total DECIMAL
AS
BEGIN
    -- Проверка существования отгрузки
    IF NOT EXISTS (SELECT 1 FROM Shipments WHERE ID = @ID)
    BEGIN
        RAISERROR('Отгрузка с указанным ID не найдена.', 16, 1)
        RETURN
    END

    -- Проверка существования склада
    IF NOT EXISTS (SELECT 1 FROM Warehouses WHERE ID = @WarehouseID)
    BEGIN
        RAISERROR('Указанный склад не существует.', 16, 1)
        RETURN
    END

    -- Валидация данных (примеры)
    IF @Date IS NULL OR @Client IS NULL OR @InvoiceNumber IS NULL OR @Total IS NULL
    BEGIN
        RAISERROR('Не все обязательные поля заполнены.', 16, 1)
        RETURN
    END

    IF @Total < 0
    BEGIN
        RAISERROR('Сумма отгрузки не может быть отрицательной.', 16, 1)
        RETURN
    END

    BEGIN TRY
        UPDATE Shipments
        SET Date = @Date,
            Client = @Client,
            InvoiceNumber = @InvoiceNumber,
            WarehouseID = @WarehouseID,
            Total = @Total
        WHERE ID = @ID
    END TRY
    BEGIN CATCH
        THROW; 
    END CATCH
END
GO

-- Добавление товара
CREATE PROCEDURE CreateProduct
    @Name VARCHAR(255),
    @Article VARCHAR(50),
    @Description TEXT,
    @MeasurementUnit VARCHAR(50),
    @Price DECIMAL
AS
BEGIN
    -- Валидация данных
    IF @Name IS NULL OR @MeasurementUnit IS NULL OR @Price IS NULL
    BEGIN
        RAISERROR('Не все обязательные поля заполнены для товара.', 16, 1)
        RETURN
    END

    IF @Price < 0
    BEGIN
        RAISERROR('Цена товара не может быть отрицательной.', 16, 1)
        RETURN
    END

    BEGIN TRY
        INSERT INTO Products (Name, Article, Description, MeasurementUnit, Price)
        VALUES (@Name, @Article, @Description, @MeasurementUnit, @Price)
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

-- Удаление товара
CREATE PROCEDURE DeleteProduct
    @ProductID INT
AS
BEGIN
    -- Проверка существования товара
    IF NOT EXISTS (SELECT 1 FROM Products WHERE ID = @ProductID)
    BEGIN
        RAISERROR('Товар с указанным ID не найден.', 16, 1)
        RETURN
    END

    BEGIN TRY
        DELETE FROM Products
        WHERE ID = @ProductID
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

-- Добавление должности
CREATE PROCEDURE CreatePosition
    @Name VARCHAR(100),
    @Description TEXT,
    @AccessLevel INT,
    @WarehouseID INT = NULL,
    @IsActive BIT = 1
AS
BEGIN
    -- Проверка существования склада (если указан)
    IF @WarehouseID IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Warehouses WHERE ID = @WarehouseID)
    BEGIN
        RAISERROR('Указанный склад не существует.', 16, 1)
        RETURN
    END

    -- Валидация данных
    IF @Name IS NULL OR @AccessLevel IS NULL
    BEGIN
        RAISERROR('Не все обязательные поля заполнены для должности.', 16, 1)
        RETURN
    END

    IF @AccessLevel < 0
    BEGIN
      RAISERROR('Уровень доступа не может быть отрицательным.', 16, 1)
      RETURN
    END

    BEGIN TRY
        INSERT INTO Positions (Name, Description, AccessLevel, WarehouseID, IsActive)
        VALUES (@Name, @Description, @AccessLevel, @WarehouseID, @IsActive)
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

-- Удаление должности
CREATE PROCEDURE DeletePosition
    @PositionID INT
AS
BEGIN
    -- Проверка существования должности
    IF NOT EXISTS (SELECT 1 FROM Positions WHERE ID = @PositionID)
    BEGIN
        RAISERROR('Должность с указанным ID не найдена.', 16, 1)
        RETURN
    END

    -- Проверка, не используется ли должность сотрудниками
    IF EXISTS (SELECT 1 FROM Employees WHERE PositionID = @PositionID)
    BEGIN
        RAISERROR('Невозможно удалить должность, так как она используется сотрудниками.', 16, 1)
        RETURN
    END

    BEGIN TRY
        DELETE FROM Positions
        WHERE ID = @PositionID
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

-- Редактирование информации о складе
CREATE PROCEDURE UpdateWarehouse
    @ID INT,
    @Name VARCHAR(100),
    @Address VARCHAR(255),
    @Area DECIMAL,
    @ContactInfo VARCHAR(255),
    @Type VARCHAR(255)
AS
BEGIN
    -- Проверка существования склада
    IF NOT EXISTS (SELECT 1 FROM Warehouses WHERE ID = @ID)
    BEGIN
        RAISERROR('Склад с указанным ID не найден.', 16, 1)
        RETURN
    END

    -- Валидация данных
    IF @Name IS NULL
    BEGIN
        RAISERROR('Название склада не может быть пустым.', 16, 1)
        RETURN
    END

    BEGIN TRY
        UPDATE Warehouses
        SET Name = @Name,
            Address = @Address,
            Area = @Area,
            ContactInfo = @ContactInfo,
            Type = @Type
        WHERE ID = @ID
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

-- Добавление сотрудника
CREATE PROCEDURE CreateEmployee
    @FullName VARCHAR(255),
    @PositionID INT,
    @WarehouseID INT,
    @ContactInfo VARCHAR(255),
    @Status VARCHAR(50) = 'active'
AS
BEGIN
    -- Проверка существования должности
    IF NOT EXISTS (SELECT 1 FROM Positions WHERE ID = @PositionID)
    BEGIN
        RAISERROR('Указанная должность не существует.', 16, 1)
        RETURN
    END

    -- Проверка существования склада
    IF NOT EXISTS (SELECT 1 FROM Warehouses WHERE ID = @WarehouseID)
    BEGIN
        RAISERROR('Указанный склад не существует.', 16, 1)
        RETURN
    END

    -- Валидация данных
    IF @FullName IS NULL
    BEGIN
        RAISERROR('Полное имя сотрудника не может быть пустым.', 16, 1)
        RETURN
    END

    BEGIN TRY
        INSERT INTO Employees (FullName, PositionID, WarehouseID, ContactInfo, Status)
        VALUES (@FullName, @PositionID, @WarehouseID, @ContactInfo, @Status)
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

-- Редактирование информации о сотруднике
CREATE PROCEDURE UpdateEmployee
    @ID INT,
    @FullName VARCHAR(255),
    @PositionID INT,
    @WarehouseID INT,
    @ContactInfo VARCHAR(255),
    @Status VARCHAR(50)
AS
BEGIN
    -- Проверка существования сотрудника
    IF NOT EXISTS (SELECT 1 FROM Employees WHERE ID = @ID)
    BEGIN
        RAISERROR('Сотрудник с указанным ID не найден.', 16, 1)
        RETURN
    END

    -- Проверка существования должности
    IF NOT EXISTS (SELECT 1 FROM Positions WHERE ID = @PositionID)
    BEGIN
        RAISERROR('Указанная должность не существует.', 16, 1)
        RETURN
    END

    -- Проверка существования склада
    IF NOT EXISTS (SELECT 1 FROM Warehouses WHERE ID = @WarehouseID)
    BEGIN
        RAISERROR('Указанный склад не существует.', 16, 1)
        RETURN
    END

    -- Валидация данных
    IF @FullName IS NULL
    BEGIN
        RAISERROR('Полное имя сотрудника не может быть пустым.', 16, 1)
        RETURN
    END

    BEGIN TRY
        UPDATE Employees
        SET FullName = @FullName,
            PositionID = @PositionID,
            WarehouseID = @WarehouseID,
            ContactInfo = @ContactInfo,
            Status = @Status
        WHERE ID = @ID
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

-- Удаление сотрудника
CREATE PROCEDURE DeleteEmployee
    @EmployeeID INT
AS
BEGIN
    -- Проверка существования сотрудника
    IF NOT EXISTS (SELECT 1 FROM Employees WHERE ID = @EmployeeID)
    BEGIN
        RAISERROR('Сотрудник с указанным ID не найден.', 16, 1)
        RETURN
    END

    BEGIN TRY
        DELETE FROM Employees
        WHERE ID = @EmployeeID
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO


-- ФУНКЦИИ

-- Просмотр информации о товаре 
CREATE FUNCTION GetProductInfo (@ProductID INT)
RETURNS TABLE
AS
RETURN
(
    SELECT *
    FROM Products
    WHERE ID = @ProductID
);
GO

-- Просмотр журнала отгрузок (функция)
CREATE FUNCTION GetShipmentLog ()
RETURNS TABLE
AS
RETURN
(
    SELECT *
    FROM Shipments
);
GO

-- Просмотр журнала поступлений (функция)
CREATE FUNCTION GetReceiptLog()
RETURNS TABLE
AS
RETURN
(
    SELECT *
    FROM Receipts
);
GO



-- ТРИГГЕРЫ

-- Триггер для проверки значения Warehouses.Area
CREATE TRIGGER TR_Warehouses_Area_Check
ON Warehouses
AFTER INSERT, UPDATE
AS
BEGIN
    UPDATE Warehouses
    SET Area = CASE
        WHEN i.Area < 0 THEN 0  
        ELSE i.Area
    END
    FROM Warehouses w
    INNER JOIN inserted i ON w.ID = i.ID;
END;






-- ПРИМЕРЫ


-- Добавление склада
INSERT INTO Warehouses (Name, Address, Area, ContactInfo, Type) VALUES ('Основной склад', 'ул. Центральная, 1', 1000, 'Директор: ФИО', 'Общий');
select * from Warehouses;

-- Добавление должности
EXEC CreatePosition @Name = 'Менеджер склада', @Description = 'Управление складскими операциями', @AccessLevel = 5, @WarehouseID = 1;

-- Добавление сотрудника
EXEC CreateEmployee @FullName = 'ФИО 2', @PositionID = 1, @WarehouseID = 1, @ContactInfo = 'p2@example.com';

-- Добавление товара
EXEC CreateProduct @Name = 'Молоко', @Article = 'MLK-001', @Description = 'Молоко пастеризованное', @MeasurementUnit = 'литр', @Price = 75.00;

-- Создание поступления
DECLARE @ReceiptID INT;
EXEC @ReceiptID = CreateReceipt @Date = '2024-01-20', @Supplier = 'Поставщик 1', @InvoiceNumber = 'INV-001', @WarehouseID = 1, @Total = 10000.00;

-- Создание отгрузки
DECLARE @ShipmentID INT;
EXEC @ShipmentID = CreateShipment @Date = '2024-01-21', @Client = 'Клиент 1', @InvoiceNumber = 'SHP-001', @WarehouseID = 1, @Total = 5000.00;

-- Редактирование склада
EXEC UpdateWarehouse @ID = 1, @Name = 'Центральный склад', @Address = 'ул. Главная, 5', @Area = -1200, @ContactInfo = 'Ф И.О, +12391234567', @Type = 'Хранение';
select * from Warehouses;
-- Удаление должности
EXEC DeletePosition @PositionID = 1;

-- Редактирование сотрудника
EXEC UpdateEmployee @ID = 1, @FullName = 'Ф И О', @PositionID = 1, @WarehouseID = 1, @ContactInfo = 'iv@example.com', @Status = 'active';

-- Удаление сотрудника
EXEC DeleteEmployee @EmployeeID = 1;

-- Получение информации о товаре
SELECT * FROM GetProductInfo(2);
SELECT * FROM Products;
-- Просмотр журнала отгрузок
SELECT * FROM GetShipmentLog();

-- Просмотр журнала поступлений
SELECT * FROM GetReceiptLog();

-- Удаление товара
EXEC DeleteProduct @ProductID = 1;





SET SHOWPLAN_XML ON;  
GO  

SELECT * FROM Products order by Name;  
GO  

SET SHOWPLAN_XML OFF;  
GO