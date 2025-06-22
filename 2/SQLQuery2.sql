
-- ������������������

CREATE SEQUENCE SeqWarehouses START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE SeqPositions START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE SeqEmployees START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE SeqProducts START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE SeqReceipts START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE SeqShipments START WITH 1 INCREMENT BY 1;


	


-- �������

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





-- �������

CREATE INDEX IX_Receipts_WarehouseID ON Receipts (WarehouseID);
CREATE INDEX IX_Shipments_WarehouseID ON Shipments (WarehouseID);
CREATE INDEX IX_Employees_PositionID ON Employees (PositionID);
CREATE INDEX IX_Employees_WarehouseID ON Employees (WarehouseID);
CREATE INDEX IX_Positions_WarehouseID ON Positions (WarehouseID);
CREATE INDEX IX_Products_Name ON Products (Name); 







-- �������������

-- ������ ��������
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

-- ������ �����������
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











-- ���������

-- �������� �����������
CREATE PROCEDURE CreateReceipt
    @Date DATE,
    @Supplier VARCHAR(50),
    @InvoiceNumber VARCHAR(50),
    @WarehouseID INT,
    @Total DECIMAL
AS
BEGIN
    -- �������� ������������� ������
    IF NOT EXISTS (SELECT 1 FROM Warehouses WHERE ID = @WarehouseID)
    BEGIN
        RAISERROR('��������� ����� �� ����������.', 16, 1)
        RETURN
    END

    -- ��������� ������ 
    IF @Date IS NULL OR @Supplier IS NULL OR @InvoiceNumber IS NULL OR @Total IS NULL
    BEGIN
        RAISERROR('�� ��� ������������ ���� ���������.', 16, 1)
        RETURN
    END

    IF @Total < 0
    BEGIN
        RAISERROR('����� ����������� �� ����� ���� �������������.', 16, 1)
        RETURN
    END

    BEGIN TRY
        INSERT INTO Receipts (Date, Supplier, InvoiceNumber, WarehouseID, Total)
        VALUES (@Date, @Supplier, @InvoiceNumber, @WarehouseID, @Total)

        SELECT SCOPE_IDENTITY(); -- ���������� ID ��������� ������
    END TRY
    BEGIN CATCH
       THROW; 
	END CATCH
END
GO

-- �������������� �����������
CREATE PROCEDURE UpdateReceipt
    @ID INT,
    @Date DATE,
    @Supplier VARCHAR(50),
    @InvoiceNumber VARCHAR(50),
    @WarehouseID INT,
    @Total DECIMAL
AS
BEGIN
    -- �������� ������������� �����������
    IF NOT EXISTS (SELECT 1 FROM Receipts WHERE ID = @ID)
    BEGIN
        RAISERROR('����������� � ��������� ID �� �������.', 16, 1)
        RETURN
    END

    -- �������� ������������� ������
    IF NOT EXISTS (SELECT 1 FROM Warehouses WHERE ID = @WarehouseID)
    BEGIN
        RAISERROR('��������� ����� �� ����������.', 16, 1)
        RETURN
    END

    -- ��������� ������ 
    IF @Date IS NULL OR @Supplier IS NULL OR @InvoiceNumber IS NULL OR @Total IS NULL
    BEGIN
        RAISERROR('�� ��� ������������ ���� ���������.', 16, 1)
        RETURN
    END

    IF @Total < 0
    BEGIN
        RAISERROR('����� ����������� �� ����� ���� �������������.', 16, 1)
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

-- �������� ��������
CREATE PROCEDURE CreateShipment
    @Date DATE,
    @Client VARCHAR(50),
    @InvoiceNumber VARCHAR(50),
    @WarehouseID INT,
    @Total DECIMAL
AS
BEGIN
    -- �������� ������������� ������
    IF NOT EXISTS (SELECT 1 FROM Warehouses WHERE ID = @WarehouseID)
    BEGIN
        RAISERROR('��������� ����� �� ����������.', 16, 1)
        RETURN
    END

    -- ��������� ������ (�������)
    IF @Date IS NULL OR @Client IS NULL OR @InvoiceNumber IS NULL OR @Total IS NULL
    BEGIN
        RAISERROR('�� ��� ������������ ���� ���������.', 16, 1)
        RETURN
    END

    IF @Total < 0
    BEGIN
        RAISERROR('����� �������� �� ����� ���� �������������.', 16, 1)
        RETURN
    END

    BEGIN TRY
        INSERT INTO Shipments (Date, Client, InvoiceNumber, WarehouseID, Total)
        VALUES (@Date, @Client, @InvoiceNumber, @WarehouseID, @Total)

        SELECT SCOPE_IDENTITY(); -- ���������� ID ��������� ������
    END TRY
    BEGIN CATCH
        THROW; 
    END CATCH
END
GO

-- �������������� ��������
CREATE PROCEDURE UpdateShipment
    @ID INT,
    @Date DATE,
    @Client VARCHAR(50),
    @InvoiceNumber VARCHAR(50),
    @WarehouseID INT,
    @Total DECIMAL
AS
BEGIN
    -- �������� ������������� ��������
    IF NOT EXISTS (SELECT 1 FROM Shipments WHERE ID = @ID)
    BEGIN
        RAISERROR('�������� � ��������� ID �� �������.', 16, 1)
        RETURN
    END

    -- �������� ������������� ������
    IF NOT EXISTS (SELECT 1 FROM Warehouses WHERE ID = @WarehouseID)
    BEGIN
        RAISERROR('��������� ����� �� ����������.', 16, 1)
        RETURN
    END

    -- ��������� ������ (�������)
    IF @Date IS NULL OR @Client IS NULL OR @InvoiceNumber IS NULL OR @Total IS NULL
    BEGIN
        RAISERROR('�� ��� ������������ ���� ���������.', 16, 1)
        RETURN
    END

    IF @Total < 0
    BEGIN
        RAISERROR('����� �������� �� ����� ���� �������������.', 16, 1)
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

-- ���������� ������
CREATE PROCEDURE CreateProduct
    @Name VARCHAR(255),
    @Article VARCHAR(50),
    @Description TEXT,
    @MeasurementUnit VARCHAR(50),
    @Price DECIMAL
AS
BEGIN
    -- ��������� ������
    IF @Name IS NULL OR @MeasurementUnit IS NULL OR @Price IS NULL
    BEGIN
        RAISERROR('�� ��� ������������ ���� ��������� ��� ������.', 16, 1)
        RETURN
    END

    IF @Price < 0
    BEGIN
        RAISERROR('���� ������ �� ����� ���� �������������.', 16, 1)
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

-- �������� ������
CREATE PROCEDURE DeleteProduct
    @ProductID INT
AS
BEGIN
    -- �������� ������������� ������
    IF NOT EXISTS (SELECT 1 FROM Products WHERE ID = @ProductID)
    BEGIN
        RAISERROR('����� � ��������� ID �� ������.', 16, 1)
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

-- ���������� ���������
CREATE PROCEDURE CreatePosition
    @Name VARCHAR(100),
    @Description TEXT,
    @AccessLevel INT,
    @WarehouseID INT = NULL,
    @IsActive BIT = 1
AS
BEGIN
    -- �������� ������������� ������ (���� ������)
    IF @WarehouseID IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Warehouses WHERE ID = @WarehouseID)
    BEGIN
        RAISERROR('��������� ����� �� ����������.', 16, 1)
        RETURN
    END

    -- ��������� ������
    IF @Name IS NULL OR @AccessLevel IS NULL
    BEGIN
        RAISERROR('�� ��� ������������ ���� ��������� ��� ���������.', 16, 1)
        RETURN
    END

    IF @AccessLevel < 0
    BEGIN
      RAISERROR('������� ������� �� ����� ���� �������������.', 16, 1)
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

-- �������� ���������
CREATE PROCEDURE DeletePosition
    @PositionID INT
AS
BEGIN
    -- �������� ������������� ���������
    IF NOT EXISTS (SELECT 1 FROM Positions WHERE ID = @PositionID)
    BEGIN
        RAISERROR('��������� � ��������� ID �� �������.', 16, 1)
        RETURN
    END

    -- ��������, �� ������������ �� ��������� ������������
    IF EXISTS (SELECT 1 FROM Employees WHERE PositionID = @PositionID)
    BEGIN
        RAISERROR('���������� ������� ���������, ��� ��� ��� ������������ ������������.', 16, 1)
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

-- �������������� ���������� � ������
CREATE PROCEDURE UpdateWarehouse
    @ID INT,
    @Name VARCHAR(100),
    @Address VARCHAR(255),
    @Area DECIMAL,
    @ContactInfo VARCHAR(255),
    @Type VARCHAR(255)
AS
BEGIN
    -- �������� ������������� ������
    IF NOT EXISTS (SELECT 1 FROM Warehouses WHERE ID = @ID)
    BEGIN
        RAISERROR('����� � ��������� ID �� ������.', 16, 1)
        RETURN
    END

    -- ��������� ������
    IF @Name IS NULL
    BEGIN
        RAISERROR('�������� ������ �� ����� ���� ������.', 16, 1)
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

-- ���������� ����������
CREATE PROCEDURE CreateEmployee
    @FullName VARCHAR(255),
    @PositionID INT,
    @WarehouseID INT,
    @ContactInfo VARCHAR(255),
    @Status VARCHAR(50) = 'active'
AS
BEGIN
    -- �������� ������������� ���������
    IF NOT EXISTS (SELECT 1 FROM Positions WHERE ID = @PositionID)
    BEGIN
        RAISERROR('��������� ��������� �� ����������.', 16, 1)
        RETURN
    END

    -- �������� ������������� ������
    IF NOT EXISTS (SELECT 1 FROM Warehouses WHERE ID = @WarehouseID)
    BEGIN
        RAISERROR('��������� ����� �� ����������.', 16, 1)
        RETURN
    END

    -- ��������� ������
    IF @FullName IS NULL
    BEGIN
        RAISERROR('������ ��� ���������� �� ����� ���� ������.', 16, 1)
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

-- �������������� ���������� � ����������
CREATE PROCEDURE UpdateEmployee
    @ID INT,
    @FullName VARCHAR(255),
    @PositionID INT,
    @WarehouseID INT,
    @ContactInfo VARCHAR(255),
    @Status VARCHAR(50)
AS
BEGIN
    -- �������� ������������� ����������
    IF NOT EXISTS (SELECT 1 FROM Employees WHERE ID = @ID)
    BEGIN
        RAISERROR('��������� � ��������� ID �� ������.', 16, 1)
        RETURN
    END

    -- �������� ������������� ���������
    IF NOT EXISTS (SELECT 1 FROM Positions WHERE ID = @PositionID)
    BEGIN
        RAISERROR('��������� ��������� �� ����������.', 16, 1)
        RETURN
    END

    -- �������� ������������� ������
    IF NOT EXISTS (SELECT 1 FROM Warehouses WHERE ID = @WarehouseID)
    BEGIN
        RAISERROR('��������� ����� �� ����������.', 16, 1)
        RETURN
    END

    -- ��������� ������
    IF @FullName IS NULL
    BEGIN
        RAISERROR('������ ��� ���������� �� ����� ���� ������.', 16, 1)
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

-- �������� ����������
CREATE PROCEDURE DeleteEmployee
    @EmployeeID INT
AS
BEGIN
    -- �������� ������������� ����������
    IF NOT EXISTS (SELECT 1 FROM Employees WHERE ID = @EmployeeID)
    BEGIN
        RAISERROR('��������� � ��������� ID �� ������.', 16, 1)
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


-- �������

-- �������� ���������� � ������ 
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

-- �������� ������� �������� (�������)
CREATE FUNCTION GetShipmentLog ()
RETURNS TABLE
AS
RETURN
(
    SELECT *
    FROM Shipments
);
GO

-- �������� ������� ����������� (�������)
CREATE FUNCTION GetReceiptLog()
RETURNS TABLE
AS
RETURN
(
    SELECT *
    FROM Receipts
);
GO



-- ��������

-- ������� ��� �������� �������� Warehouses.Area
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






-- �������


-- ���������� ������
INSERT INTO Warehouses (Name, Address, Area, ContactInfo, Type) VALUES ('�������� �����', '��. �����������, 1', 1000, '��������: ���', '�����');
select * from Warehouses;

-- ���������� ���������
EXEC CreatePosition @Name = '�������� ������', @Description = '���������� ���������� ����������', @AccessLevel = 5, @WarehouseID = 1;

-- ���������� ����������
EXEC CreateEmployee @FullName = '��� 2', @PositionID = 1, @WarehouseID = 1, @ContactInfo = 'p2@example.com';

-- ���������� ������
EXEC CreateProduct @Name = '������', @Article = 'MLK-001', @Description = '������ ���������������', @MeasurementUnit = '����', @Price = 75.00;

-- �������� �����������
DECLARE @ReceiptID INT;
EXEC @ReceiptID = CreateReceipt @Date = '2024-01-20', @Supplier = '��������� 1', @InvoiceNumber = 'INV-001', @WarehouseID = 1, @Total = 10000.00;

-- �������� ��������
DECLARE @ShipmentID INT;
EXEC @ShipmentID = CreateShipment @Date = '2024-01-21', @Client = '������ 1', @InvoiceNumber = 'SHP-001', @WarehouseID = 1, @Total = 5000.00;

-- �������������� ������
EXEC UpdateWarehouse @ID = 1, @Name = '����������� �����', @Address = '��. �������, 5', @Area = -1200, @ContactInfo = '� �.�, +12391234567', @Type = '��������';
select * from Warehouses;
-- �������� ���������
EXEC DeletePosition @PositionID = 1;

-- �������������� ����������
EXEC UpdateEmployee @ID = 1, @FullName = '� � �', @PositionID = 1, @WarehouseID = 1, @ContactInfo = 'iv@example.com', @Status = 'active';

-- �������� ����������
EXEC DeleteEmployee @EmployeeID = 1;

-- ��������� ���������� � ������
SELECT * FROM GetProductInfo(2);
SELECT * FROM Products;
-- �������� ������� ��������
SELECT * FROM GetShipmentLog();

-- �������� ������� �����������
SELECT * FROM GetReceiptLog();

-- �������� ������
EXEC DeleteProduct @ProductID = 1;





SET SHOWPLAN_XML ON;  
GO  

SELECT * FROM Products order by Name;  
GO  

SET SHOWPLAN_XML OFF;  
GO