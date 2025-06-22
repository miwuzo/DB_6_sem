-------- 3

SELECT
    TO_CHAR(Datee, 'YYYY-MM') AS month,
    SUM(Total) AS monthly_total,
    SUM(SUM(Total)) OVER (PARTITION BY EXTRACT(YEAR FROM Datee), TO_CHAR(Datee, 'Q')) AS quarterly_total,
    SUM(SUM(Total)) OVER (PARTITION BY EXTRACT(YEAR FROM Datee), 
        CASE 
            WHEN EXTRACT(MONTH FROM Datee) <= 6 THEN 'First Half' 
            ELSE 'Second Half' 
        END) AS half_year_total,
    SUM(SUM(Total)) OVER (PARTITION BY EXTRACT(YEAR FROM Datee)) AS yearly_total
FROM
    Receipts
WHERE
    WarehouseID = 6
GROUP BY
    TO_CHAR(Datee, 'YYYY-MM'), 
    EXTRACT(YEAR FROM Datee), 
    TO_CHAR(Datee, 'Q'),
    CASE 
        WHEN EXTRACT(MONTH FROM Datee) <= 6 THEN 'First Half' 
        ELSE 'Second Half' 
    END
ORDER BY
    month;



-------- 4
SELECT
    Supplier,
    SUM(Total) AS TotalSales,
    SUM(Total) * 100.0 / SUM(SUM(Total)) OVER () AS SalesPercentageOfTotal,
    SUM(Total) * 100.0 / MAX(SUM(Total)) OVER () AS SalesPercentageOfBest
FROM 
    Receipts
GROUP BY 
    Supplier;


------- 5
SELECT 
    W.ID, 
    W.Name AS WarehouseName, 
    W.Address, 
    EXTRACT(YEAR FROM R.Datee) AS Year, 
    EXTRACT(MONTH FROM R.Datee) AS Month, 
    COUNT(*) AS ReceiptCount
FROM 
    Warehouses W
INNER JOIN 
    Receipts R ON W.ID = R.WarehouseID
WHERE 
    R.Datee >= ADD_MONTHS(SYSDATE, -6)
GROUP BY 
    W.ID, W.Name, W.Address, EXTRACT(YEAR FROM R.Datee), EXTRACT(MONTH FROM R.Datee);



------

SELECT 
    w.ID AS WarehouseID,
    w.Name AS WarehouseName,
    COUNT(e.ID) AS EmployeeCount,
    CASE 
        WHEN COUNT(e.ID) = MAX(COUNT(e.ID)) OVER () 
        THEN '� ���������� ����������� �����������'
        ELSE '������� �����'
    END AS WarehouseStatus
FROM 
    Warehouses w
LEFT JOIN 
    Employees e ON w.ID = e.WarehouseID
GROUP BY 
    w.ID, w.Name
HAVING 
    COUNT(e.ID) > 0
ORDER BY 
    EmployeeCount DESC;

















UPDATE Receipts
SET Datee = ADD_MONTHS(Datee, -24) -- �������� ���� �� 2 ���� �����
WHERE EXTRACT(YEAR FROM Datee) = 2025;






INSERT INTO Receipts (Datee, Supplier, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2025-03-05', 'YYYY-MM-DD'), '��� "������"', '��-230305-005', 7, 1100000.00);
INSERT INTO Receipts (Datee, Supplier, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2025-03-12', 'YYYY-MM-DD'), '�� "���������������"', '��-230312-049', 6, 920000.00);
INSERT INTO Receipts (Datee, Supplier, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2025-04-08', 'YYYY-MM-DD'), '�� ������� �.�.', '��-230408-016', 7, 350000.00);
INSERT INTO Receipts (Datee, Supplier, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2025-04-15', 'YYYY-MM-DD'), '��� "������� �������"', '��-230415-082', 7, 580000.00);
INSERT INTO Receipts (Datee, Supplier, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2025-05-03', 'YYYY-MM-DD'), '��� "�������� �������"', '��-230503-037', 7, 225000.00);
INSERT INTO Receipts (Datee, Supplier, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2025-05-18', 'YYYY-MM-DD'), '��� "�������������"', '��-230518-006', 7, 950000.00);
INSERT INTO Receipts (Datee, Supplier, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2025-06-07', 'YYYY-MM-DD'), '�� "���������������"', '��-230607-050', 7, 810000.00);
INSERT INTO Receipts (Datee, Supplier, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2025-06-14', 'YYYY-MM-DD'), '�� ������� �.�.', '��-230614-017', 7, 390000.00);
INSERT INTO Receipts (Datee, Supplier, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2025-07-09', 'YYYY-MM-DD'), '��� "������� �������"', '��-230709-083', 7, 620000.00);
INSERT INTO Receipts (Datee, Supplier, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2025-07-22', 'YYYY-MM-DD'), '��� "�������� �������"', '��-230722-038', 6, 255000.00);
INSERT INTO Receipts (Datee, Supplier, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2025-08-11', 'YYYY-MM-DD'), '��� "�������������"', '��-230811-007', 6, 1020000.00);
INSERT INTO Receipts (Datee, Supplier, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2025-08-25', 'YYYY-MM-DD'), '�� "���������������"', '��-230825-051', 6, 880000.00);
INSERT INTO Receipts (Datee, Supplier, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2025-09-06', 'YYYY-MM-DD'), '�� ������� �.�.', '��-230906-018', 6, 420000.00);
INSERT INTO Receipts (Datee, Supplier, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2025-09-19', 'YYYY-MM-DD'), '��� "������� �������"', '��-230919-084', 6, 590000.00);
INSERT INTO Receipts (Datee, Supplier, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2025-10-05', 'YYYY-MM-DD'), '��� "�������� �������"', '��-231005-039', 6, 230000.00);
INSERT INTO Receipts (Datee, Supplier, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2025-10-16', 'YYYY-MM-DD'), '��� "�������������"', '��-231016-008', 6, 970000.00);
INSERT INTO Receipts (Datee, Supplier, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2025-11-07', 'YYYY-MM-DD'), '�� "���������������"', '��-231107-052', 6, 830000.00);
INSERT INTO Receipts (Datee, Supplier, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2025-11-14', 'YYYY-MM-DD'), '�� ������� �.�.', '��-231114-019', 6, 440000.00);
INSERT INTO Receipts (Datee, Supplier, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2025-12-03', 'YYYY-MM-DD'), '��� "������� �������"', '��-231203-085', 6, 650000.00);
INSERT INTO Receipts (Datee, Supplier, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2025-12-18', 'YYYY-MM-DD'), '��� "�������� �������"', '��-231218-040', 6, 265000.00);
INSERT INTO Receipts (Datee, Supplier, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2025-02-10', 'YYYY-MM-DD'), '��� "�������������"', '��-230210-009', 6, 890000.00);
INSERT INTO Receipts (Datee, Supplier, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2025-02-17', 'YYYY-MM-DD'), '�� "���������������"', '��-230217-053', 6, 720000.00);
INSERT INTO Receipts (Datee, Supplier, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2025-03-22', 'YYYY-MM-DD'), '�� ������� �.�.', '��-230322-020', 6, 470000.00);
INSERT INTO Receipts (Datee, Supplier, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2025-04-28', 'YYYY-MM-DD'), '��� "������� �������"', '��-230428-086', 6, 530000.00);
INSERT INTO Receipts (Datee, Supplier, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2025-05-30', 'YYYY-MM-DD'), '��� "�������� �������"', '��-230530-041', 6, 215000.00);




-- ������� ������ � ������� Warehouses
INSERT INTO Warehouses (Name, Address, Area, ContactInfo, Type) VALUES
('����������� �����', '�. ������, ��. ������������, 15', 2500.5, '+7 (495) 123-45-67', '������ ����������');
INSERT INTO Warehouses (Name, Address, Area, ContactInfo, Type) VALUES
('�������� ����������������� �����', '�. �����-���������, �. ����������, 45', 1800.0, '+7 (812) 987-65-43', '�����������');
INSERT INTO Warehouses (Name, Address, Area, ContactInfo, Type) VALUES
('����� ������������� ��������', '�. ������-��-����, ��. ������, 123', 3200.75, '+7 (863) 456-78-90', '������������');
INSERT INTO Warehouses (Name, Address, Area, ContactInfo, Type) VALUES
('��������� ��������', '�. ������������, ��. �������������, 67', 1500.25, '+7 (343) 345-67-89', '�������������');
INSERT INTO Warehouses (Name, Address, Area, ContactInfo, Type) VALUES
('�������� �����', '�. �����������, ��. �������� �����, 12', 950.0, '+7 (4012) 34-56-78', '������� ��������');
INSERT INTO Warehouses (Name, Address, Area, ContactInfo, Type) VALUES
('����� �6', '�. �����������, ��. �������������, 8', 2100.0, '+7 (383) 123-45-67', '������������������');
INSERT INTO Warehouses (Name, Address, Area, ContactInfo, Type) VALUES
('���������� �����', '�. ������, ��. ������, 141', 2750.5, '+7 (843) 987-65-43', '����������� ���������');
INSERT INTO Warehouses (Name, Address, Area, ContactInfo, Type) VALUES
('���������', '�. ���������, ��. ��������, 33', 1850.0, '+7 (861) 234-56-78', '��������������������');
INSERT INTO Warehouses (Name, Address, Area, ContactInfo, Type) VALUES
('���������������� �����', '�. �������, ��. �����������, 5', 1200.75, '+7 (473) 345-67-89', '����������������');
INSERT INTO Warehouses (Name, Address, Area, ContactInfo, Type) VALUES
('������� �����', '�. ������, �������� "������", ���. 7', 800.0, '+7 (846) 456-78-90', '������� ���������');

-- ������� ������ � ������� Positions
INSERT INTO Positions (Name, Description, AccessLevel, WarehouseID, IsActive) VALUES
('����������� �������', '����������� ����� ���������� ������', 5, 1, 1);
INSERT INTO Positions (Name, Description, AccessLevel, WarehouseID, IsActive) VALUES
('������� ���������', '�������� ������ �����������, ������� ������', 4, 1, 1);
INSERT INTO Positions (Name, Description, AccessLevel, WarehouseID, IsActive) VALUES
('���������', '�����, �������� � ������ ������', 3, 1, 1);
INSERT INTO Positions (Name, Description, AccessLevel, WarehouseID, IsActive) VALUES
('�������', '����������-������������ ������', 2, 1, 1);
INSERT INTO Positions (Name, Description, AccessLevel, WarehouseID, IsActive) VALUES
('�������� ��', '������� ����� � ������� WMS', 3, 1, 1);
INSERT INTO Positions (Name, Description, AccessLevel, WarehouseID, IsActive) VALUES
('������', '������������ ����������� ������', 4, NULL, 1);
INSERT INTO Positions (Name, Description, AccessLevel, WarehouseID, IsActive) VALUES
('�������� �� �������', '�������� ��������, ������ �����������', 4, NULL, 1);
INSERT INTO Positions (Name, Description, AccessLevel, WarehouseID, IsActive) VALUES
('������������� �������', '������������ ���������� ��', 5, NULL, 1);
INSERT INTO Positions (Name, Description, AccessLevel, WarehouseID, IsActive) VALUES
('����������� ����������� �������', '������������������ ���������� ����������� �������', 5, 2, 1);
INSERT INTO Positions (Name, Description, AccessLevel, WarehouseID, IsActive) VALUES
('�������� ������������ ������������', '������������ ����������� ���������', 3, 2, 1);
INSERT INTO Positions (Name, Description, AccessLevel, WarehouseID, IsActive) VALUES
('�������� ����������', '������ �� ��������� �������', 3, 3, 1);
INSERT INTO Positions (Name, Description, AccessLevel, WarehouseID, IsActive) VALUES
('�����������', '���������� � �������� �������', 2, 3, 1);
INSERT INTO Positions (Name, Description, AccessLevel, WarehouseID, IsActive) VALUES
('��������� ��������', '�������� �������� ������������ ������', 3, 4, 1);
INSERT INTO Positions (Name, Description, AccessLevel, WarehouseID, IsActive) VALUES
('���������� �� ������� ������', '������ � �������� �����������', 4, 10, 1);
INSERT INTO Positions (Name, Description, AccessLevel, WarehouseID, IsActive) VALUES
('���������-���������', '���������� �� �������� ��������', 4, 9, 1);

select * from positions
-- ������� ������ � ������� Employees
INSERT INTO Employees (FullName, PositionID, WarehouseID, ContactInfo, Status) VALUES
('������ ������ ��������', 41, 6, '+7 (916) 123-45-67', 'active');
INSERT INTO Employees (FullName, PositionID, WarehouseID, ContactInfo, Status) VALUES
('������� ���� ������������', 42, 6, '+7 (926) 234-56-78', 'active');
INSERT INTO Employees (FullName, PositionID, WarehouseID, ContactInfo, Status) VALUES
('������� ������ ��������', 43, 6, '+7 (903) 345-67-89', 'active');
INSERT INTO Employees (FullName, PositionID, WarehouseID, ContactInfo, Status) VALUES
('��������� ����� ����������', 44, 6, '+7 (967) 456-78-90', 'active');
INSERT INTO Employees (FullName, PositionID, WarehouseID, ContactInfo, Status) VALUES
('�������� ������ ���������', 45, 6, '+7 (905) 567-89-01', 'active');
INSERT INTO Employees (FullName, PositionID, WarehouseID, ContactInfo, Status) VALUES
('�������� ����� ��������', 46, 6, '+7 (916) 678-90-12', 'active');
INSERT INTO Employees (FullName, PositionID, WarehouseID, ContactInfo, Status) VALUES
('�������� ����� �������������', 47, 6, '+7 (926) 789-01-23', 'active');
INSERT INTO Employees (FullName, PositionID, WarehouseID, ContactInfo, Status) VALUES
('������� ���� ����������', 41, 6, '+7 (903) 890-12-34', 'active');
INSERT INTO Employees (FullName, PositionID, WarehouseID, ContactInfo, Status) VALUES
('��������� ������� ����������', 42, 6, '+7 (967) 901-23-45', 'active');
INSERT INTO Employees (FullName, PositionID, WarehouseID, ContactInfo, Status) VALUES
('������ ����� ���������', 43, 6, '+7 (905) 012-34-56', 'active');
INSERT INTO Employees (FullName, PositionID, WarehouseID, ContactInfo, Status) VALUES
('����� ������� ����������', 44, 6, '+7 (916) 123-45-67', 'active');
INSERT INTO Employees (FullName, PositionID, WarehouseID, ContactInfo, Status) VALUES
('�������� ������ ���������', 45, 6, '+7 (926) 234-56-78', 'active');
INSERT INTO Employees (FullName, PositionID, WarehouseID, ContactInfo, Status) VALUES
('�yuu� ������� ����������', 46, 6, '+7 (903) 345-67-89', 'active');
INSERT INTO Employees (FullName, PositionID, WarehouseID, ContactInfo, Status) VALUES
('�������� ����� �����������', 47, 6, '+7 (967) 456-78-90', 'active');
INSERT INTO Employees (FullName, PositionID, WarehouseID, ContactInfo, Status) VALUES
('������� ����� ����������', 41, 6, '+7 (905) 567-89-01', 'active');
INSERT INTO Employees (FullName, PositionID, WarehouseID, ContactInfo, Status) VALUES
('������� ������� ��������', 42, 6, '+7 (916) 678-90-12', 'active');
INSERT INTO Employees (FullName, PositionID, WarehouseID, ContactInfo, Status) VALUES
('������ �������� �������������', 43, 6, '+7 (926) 789-01-23', 'active');
INSERT INTO Employees (FullName, PositionID, WarehouseID, ContactInfo, Status) VALUES
('�������� ��������� ���������', 44, 6, '+7 (903) 890-12-34', 'active');
INSERT INTO Employees (FullName, PositionID, WarehouseID, ContactInfo, Status) VALUES
('������� ����� ��������', 45, 6, '+7 (967) 901-23-45', 'active');
INSERT INTO Employees (FullName, PositionID, WarehouseID, ContactInfo, Status) VALUES
('������� �������� ����������', 46, 6, '+7 (905) 012-34-56', 'active');
INSERT INTO Employees (FullName, PositionID, WarehouseID, ContactInfo, Status) VALUES
('������� ����� ����������', 47, 6, '+7 (916) 123-45-67', 'active');
INSERT INTO Employees (FullName, PositionID, WarehouseID, ContactInfo, Status) VALUES
('��������� ���� ���������', 41, 6, '+7 (926) 234-56-78', 'active');
INSERT INTO Employees (FullName, PositionID, WarehouseID, ContactInfo, Status) VALUES
('������� ����� ��������', 42, 6, '+7 (903) 345-67-89', 'active');
INSERT INTO Employees (FullName, PositionID, WarehouseID, ContactInfo, Status) VALUES
('��������� ��������� ����������', 43, 6, '+7 (967) 456-78-90', 'active');
INSERT INTO Employees (FullName, PositionID, WarehouseID, ContactInfo, Status) VALUES
('������� ����� ���������', 44, 6, '+7 (905) 567-89-01', 'active');
INSERT INTO Employees (FullName, PositionID, WarehouseID, ContactInfo, Status) VALUES
('��������� ����� ������������', 45, 6, '+7 (916) 678-90-12', 'active');
INSERT INTO Employees (FullName, PositionID, WarehouseID, ContactInfo, Status) VALUES
('��������� ������ ��������', 46, 6, '+7 (926) 789-01-23', 'active');
INSERT INTO Employees (FullName, PositionID, WarehouseID, ContactInfo, Status) VALUES
('������ ���� ��������', 47, 6, '+7 (903) 890-12-34', 'active');
INSERT INTO Employees (FullName, PositionID, WarehouseID, ContactInfo, Status) VALUES
('�������� �������� �������������', 45, 6, '+7 (967) 901-23-45', 'active');

-- ������� ������ � ������� Products
INSERT INTO Products (Name, Article, Description, MeasurementUnit, Price) VALUES
('������� ASUS X515', 'NB-ASUS-X515', '15.6", Intel Core i5, 8GB RAM, 512GB SSD', '��.', 54990.00);
INSERT INTO Products (Name, Article, Description, MeasurementUnit, Price) VALUES
('�������� Samsung Galaxy A53', 'PH-SM-A53', '6.5", 128GB, 5G, ������', '��.', 32990.00);
INSERT INTO Products (Name, Article, Description, MeasurementUnit, Price) VALUES
('����������� Beko RCNA400K20W', 'FR-BEKO-RCNA400', 'No Frost, 395 �, �����', '��.', 45990.00);
INSERT INTO Products (Name, Article, Description, MeasurementUnit, Price) VALUES
('���� � ������ Lavazza Qualita Oro', 'CF-LV-QORO', '250 �, 100% �������', '��', 890.00);
INSERT INTO Products (Name, Article, Description, MeasurementUnit, Price) VALUES
('�������� ����� Mobil Super 3000', 'OIL-MOB-SUPER3K', '5W-40, 5 �', '�', 3200.00);
INSERT INTO Products (Name, Article, Description, MeasurementUnit, Price) VALUES
('������ �������� "������"', 'CH-ALENKA', '�������� �������, 100 �', '��.', 65.00);
INSERT INTO Products (Name, Article, Description, MeasurementUnit, Price) VALUES
('��������� Nike Air Max', 'SH-NIKE-AIRMAX', '�������, ������ 42, ������', '����', 8990.00);
INSERT INTO Products (Name, Article, Description, MeasurementUnit, Price) VALUES
('��� Greenfield "Golden Ceylon"', 'TEA-GF-GCEYLON', '100 ���������, ������', '��.', 450.00);
INSERT INTO Products (Name, Article, Description, MeasurementUnit, Price) VALUES
('���������� ������ LG F2J3NS0W', 'WM-LG-F2J3NS0W', '6 ��, �����������, �����', '��.', 32990.00);
INSERT INTO Products (Name, Article, Description, MeasurementUnit, Price) VALUES
('�������� Sony WH-1000XM4', 'HP-SONY-WHXM4', '������������, � ���������������', '��.', 24990.00);
INSERT INTO Products (Name, Article, Description, MeasurementUnit, Price) VALUES
('������ "����� � �������" 3.2%', 'MLK-DOMIK-3.2', '���������������������, 1 �', '�', 95.00);
INSERT INTO Products (Name, Article, Description, MeasurementUnit, Price) VALUES
('������� Philips PowerPro Compact', 'VAC-PH-PPC', '�������� 650 ��, ����� 2 �', '��.', 7990.00);
INSERT INTO Products (Name, Article, Description, MeasurementUnit, Price) VALUES
('��������� ����� "��������"', 'GRC-MISTRAL', '������ ����, 800 �', '��', 120.00);
INSERT INTO Products (Name, Article, Description, MeasurementUnit, Price) VALUES
('��������� LG 43UP75006LF', 'TV-LG-43UP750', '43", 4K UHD, Smart TV', '��.', 42990.00);
INSERT INTO Products (Name, Article, Description, MeasurementUnit, Price) VALUES
('���� ��������� "Dove"', 'SOAP-DOVE', '�����������, 100 �', '��.', 65.00);
INSERT INTO Products (Name, Article, Description, MeasurementUnit, Price) VALUES
('��������� Duracell AA', 'BAT-DUR-AA', '��������, 4 �� � ��������', '��.', 350.00);
INSERT INTO Products (Name, Article, Description, MeasurementUnit, Price) VALUES
('����� ������������ Gauss', 'LMP-GAUSS', 'E27, 10W, 3000K, ������ ����', '��.', 250.00);
INSERT INTO Products (Name, Article, Description, MeasurementUnit, Price) VALUES
('���� ����������� "Evian"', 'WTR-EVIAN', '1.5 �, ���������� �������', '��.', 290.00);
INSERT INTO Products (Name, Article, Description, MeasurementUnit, Price) VALUES
('������ ������� "Bureaucrat"', 'CHAIR-BUREAU', '�������, ������, � �������������', '��.', 15990.00);
INSERT INTO Products (Name, Article, Description, MeasurementUnit, Price) VALUES
('������ SanDisk Ultra 64GB', 'USB-SD-ULTRA64', 'USB 3.0, �������� �� 150 ��/�', '��.', 990.00);
















