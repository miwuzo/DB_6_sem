-- 1. �������� ��������� ������

-- ������� ��������� ���������
CREATE TABLE Categories (
    category_id INT PRIMARY KEY,
    category_name NVARCHAR(100) NOT NULL,
    description NVARCHAR(500)
);

-- ������� �����������
CREATE TABLE Suppliers (
    supplier_id INT PRIMARY KEY,
    supplier_name NVARCHAR(100) NOT NULL,
    contact_person NVARCHAR(100),
    phone NVARCHAR(20),
    email NVARCHAR(100)
);

-- ������� ��������� (����� � ����������� � ������������)
CREATE TABLE Products (
    product_id INT PRIMARY KEY,
    product_name NVARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    category_id INT FOREIGN KEY REFERENCES Categories(category_id),
    supplier_id INT FOREIGN KEY REFERENCES Suppliers(supplier_id),
    description NVARCHAR(500)
);

-- ������� �������
CREATE TABLE Warehouses (
    warehouse_id INT PRIMARY KEY,
    warehouse_name NVARCHAR(100) NOT NULL,
    location NVARCHAR(200),
    capacity INT
);

-- ������� ����������� (����� �� ��������)
CREATE TABLE Workers (
    worker_id INT PRIMARY KEY,
    worker_name NVARCHAR(100) NOT NULL,
    position NVARCHAR(50),
    salary DECIMAL(10, 2),
    hire_date DATE,
    warehouse_id INT FOREIGN KEY REFERENCES Warehouses(warehouse_id),
    email NVARCHAR(100)
);

-- ������� ��������� (����� ��������� � �������)
CREATE TABLE Inventory (
    inventory_id INT PRIMARY KEY,
    product_id INT FOREIGN KEY REFERENCES Products(product_id),
    warehouse_id INT FOREIGN KEY REFERENCES Warehouses(warehouse_id),
    quantity INT NOT NULL,
    last_restock_date DATE,
    section NVARCHAR(50)
);

-- ������� Report ��� �������� XML
CREATE TABLE Report (
    id INT PRIMARY KEY,
    xmlData XML,
    generation_date DATETIME DEFAULT GETDATE()
);

-- 2. ���������� ��������� �������

-- ���������
INSERT INTO Categories VALUES
(1, '�����������', '����������� ���������� � �������'),
(2, '�������� �������', '������� �������� � �������'),
(3, '�����', '�������������� � ������� ����������');

-- ����������
INSERT INTO Suppliers VALUES
(1, '�����������', '������ �.�.', '+79161234567', 'sales@electronix.ru'),
(2, '�������', '������� �.�.', '+79167654321', 'orders@freshfood.ru'),
(3, '������� ���', '������� �.�.', '+79165554433', 'info@bookworld.ru');

-- ��������
INSERT INTO Products VALUES
(1, '�������', 999.99, 1, 1, '������ ������� ��� ������ � ���'),
(2, '��������', 499.99, 1, 1, '����������� ��������'),
(3, '����', 9.99, 2, 2, '������� 100%'),
(4, '����� SQL', 29.99, 3, 3, '����������� �� SQL ��� ����������');

-- ������
INSERT INTO Warehouses VALUES
(1, '�������� �����', '������, ��. ���������, 1', 10000),
(2, '������������ �����', '�����-���������, ��. �������������, 5', 5000);

-- ����������
INSERT INTO Workers VALUES
(1, '������ ����', '�������� ������', 2500.00, '2020-05-10', 1, 'i.ivanov@company.ru'),
(2, '������ ����', '���������', 1800.00, '2021-06-15', 1, 'p.petrov@company.ru'),
(3, '�������� ����', '���������', 2200.00, '2019-07-20', NULL, 'a.sidorova@company.ru'),
(4, '�������� �������', '�������', 1500.00, '2022-08-25', 2, 'a.kuznetsov@company.ru');

-- ���������
INSERT INTO Inventory VALUES
(1, 1, 1, 50, '2023-01-15', '������ A'),
(2, 2, 1, 100, '2023-02-20', '������ B'),
(3, 3, 2, 200, '2023-03-10', '������ C'),
(4, 4, 2, 150, '2023-04-05', '������ D');

-- 3. ��������� ��������� XML �� ������� ����� ���������

CREATE OR ALTER PROCEDURE GenerateWarehouseXML
AS
BEGIN
    DECLARE @xmlData XML;
    SET @xmlData = (
        SELECT
            -- ���������� � ����������
            (SELECT c.category_id, c.category_name, c.description,
                    (SELECT p.product_id, p.product_name, p.price, p.description
                     FROM Products p
                     WHERE p.category_id = c.category_id
                     FOR XML PATH('product'), TYPE) AS products
             FROM Categories c
             FOR XML PATH('category'), ROOT('categories'), TYPE),
            
            -- ���������� � �����������
            (SELECT s.supplier_id, s.supplier_name, s.contact_person, s.phone, s.email,
                    (SELECT p.product_id, p.product_name
                     FROM Products p
                     WHERE p.supplier_id = s.supplier_id
                     FOR XML PATH('supplied_product'), TYPE) AS supplied_products
             FROM Suppliers s
             FOR XML PATH('supplier'), ROOT('suppliers'), TYPE),
            
            -- ���������� � ������� � ������������ � ����������
            (SELECT w.warehouse_id, w.warehouse_name, w.location, w.capacity,
                    (SELECT worker_id, worker_name, position, salary, 
                            DATEDIFF(YEAR, hire_date, GETDATE()) AS years_of_service
                     FROM Workers
                     WHERE warehouse_id = w.warehouse_id OR (warehouse_id IS NULL AND position = '���������')
                     FOR XML PATH('worker'), TYPE) AS workers,
                    
                    (SELECT i.inventory_id, 
                            p.product_name, 
                            i.quantity, 
                            (i.quantity * p.price) AS total_value,
                            i.section, 
                            i.last_restock_date
                     FROM Inventory i
                     JOIN Products p ON i.product_id = p.product_id
                     WHERE i.warehouse_id = w.warehouse_id
                     FOR XML PATH('inventory_item'), TYPE) AS inventory,
                    
                    (SELECT SUM(i.quantity * p.price) AS total_inventory_value
                     FROM Inventory i
                     JOIN Products p ON i.product_id = p.product_id
                     WHERE i.warehouse_id = w.warehouse_id) AS total_warehouse_value
             FROM Warehouses w
             FOR XML PATH('warehouse'), ROOT('warehouses'), TYPE),
            
            -- ����� ����������
            (SELECT 
                (SELECT COUNT(*) FROM Products) AS total_products,
                (SELECT COUNT(*) FROM Workers) AS total_workers,
                (SELECT SUM(quantity) FROM Inventory) AS total_items,
                (SELECT SUM(quantity * price) 
                 FROM Inventory i
                 JOIN Products p ON i.product_id = p.product_id) AS total_inventory_value
             FOR XML PATH('statistics'), TYPE),
            
            GETDATE() AS timestamp
        FOR XML PATH('warehouse_data'), TYPE
    );
    SELECT @xmlData AS GeneratedXML;
END;

-- 4. ��������� ������� XML � ������� Report

CREATE OR ALTER PROCEDURE InsertXMLIntoReport
AS
BEGIN
    DECLARE @xmlData XML;
    DECLARE @newId INT;
    
    -- �������� ����� ID
    SELECT @newId = ISNULL(MAX(id), 0) + 1 FROM Report;
    
    -- ���������� XML
    CREATE TABLE #TempXML (GeneratedXML XML);
    INSERT INTO #TempXML EXEC GenerateWarehouseXML;
    SELECT @xmlData = GeneratedXML FROM #TempXML;
    DROP TABLE #TempXML;
    
    -- ��������� � �������
    INSERT INTO Report (id, xmlData) VALUES (@newId, @xmlData);
    
    -- ���������� ���������
    SELECT id, generation_date FROM Report WHERE id = @newId;
END;

-- 5. �������� XML ��������

-- ��������� XML ������
CREATE PRIMARY XML INDEX IX_Report_xmlData ON Report(xmlData);

-- ��������� XML �������
CREATE XML INDEX IX_Report_xmlData_Path ON Report(xmlData)
USING XML INDEX IX_Report_xmlData FOR PATH;

CREATE XML INDEX IX_Report_xmlData_Value ON Report(xmlData)
USING XML INDEX IX_Report_xmlData FOR VALUE;

-- 6. ��������� ���������� ������ �� XML

CREATE OR ALTER PROCEDURE GetDataFromXML
    @XPath NVARCHAR(MAX),
    @SearchValue NVARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @SQL NVARCHAR(MAX);
    
    IF @SearchValue IS NULL
    BEGIN
        SET @SQL = N'
        SELECT 
            id,
            xmlData.query(''/warehouse_data' + @XPath + ''') AS extracted_data,
            generation_date
        FROM Report
        WHERE xmlData.exist(''/warehouse_data' + @XPath + ''') = 1
        ORDER BY id DESC;';
    END
    ELSE
    BEGIN
        SET @SQL = N'
        SELECT 
            id,
            xmlData.query(''/warehouse_data' + @XPath + ''') AS extracted_data,
            generation_date
        FROM Report
        WHERE xmlData.exist(''/warehouse_data' + @XPath + ''') = 1
        AND xmlData.exist(''/warehouse_data' + @XPath + '[contains(., sql:variable("@SearchValue"))]'') = 1
        ORDER BY id DESC;';
    END
    
    EXEC sp_executesql @SQL, N'@SearchValue NVARCHAR(200)', @SearchValue;
END;













CREATE OR ALTER PROCEDURE GetDataFromXML2
    @XPath NVARCHAR(MAX),
    @SearchValue NVARCHAR(200) = NULL,
    @SearchAttribute NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @SQL NVARCHAR(MAX);
    
    IF @SearchValue IS NULL
    BEGIN
        -- ������ ��������� ������ �� XPath ��� ����������
        SET @SQL = N'
        SELECT 
            id,
            xmlData.query(''/warehouse_data' + @XPath + ''') AS extracted_data,
            generation_date
        FROM Report
        WHERE xmlData.exist(''/warehouse_data' + @XPath + ''') = 1
        ORDER BY id DESC;';
    END
    ELSE IF @SearchAttribute IS NULL
    BEGIN
        -- ����� �� �������� �������� (��� �������� ��������)
        SET @SQL = N'
        SELECT 
            id,
            xmlData.query(''for $item in /warehouse_data' + @XPath + '
                           where contains($item, sql:variable("@SearchValue"))
                           return $item'') AS extracted_data,
            generation_date
        FROM Report
        WHERE xmlData.exist(''/warehouse_data' + @XPath + '[contains(., sql:variable("@SearchValue"))]'') = 1
        ORDER BY id DESC;';
    END
    ELSE
    BEGIN
        -- ����� �� �������� ����������� ��������
        SET @SQL = N'
        SELECT 
            id,
            xmlData.query(''for $item in /warehouse_data' + @XPath + '
                           where contains($item/@' + @SearchAttribute + ', sql:variable("@SearchValue"))
                           return $item'') AS extracted_data,
            generation_date
        FROM Report
        WHERE xmlData.exist(''/warehouse_data' + @XPath + '[contains(@' + @SearchAttribute + ', sql:variable("@SearchValue"))]'') = 1
        ORDER BY id DESC;';
    END
    
    EXEC sp_executesql @SQL, N'@SearchValue NVARCHAR(200)', @SearchValue;
END;



-- �������� XML �����
EXEC InsertXMLIntoReport;

-- �������� ��� ���������
EXEC GetDataFromXML '/categories/category';
select * from Categories;

-- �������� ���������� � ���������� ������
EXEC GetDataFromXML '/warehouses/warehouse[warehouse_id=1]';
select * from Warehouses where warehouse_id=1;

-- ����� �� �������� ��������
EXEC GetDataFromXML2 '/categories/category/products/product', '�������';

-- �������� ����� ����������
EXEC GetDataFromXML '/statistics';