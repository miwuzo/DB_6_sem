DROP TYPE Product_Obj FORCE;
DROP TYPE Warehouse_Obj FORCE;
drop table Products_Obj1


CREATE TABLE Productss OF Product_Obj;
INSERT INTO Productss VALUES (Product_Obj(1, '����� 1', 'A001', 100));
select name, article, price from Productss




DECLARE
    product1 Product_Obj := Product_Obj(1, '����� 1', 'A001', 100);
    product2 Product_Obj := Product_Obj(2, '����� 2', 'A002', 150);
    product3 Product_Obj := Product_Obj(3, '����� 3', 'A003', 100);
    comparison_result NUMBER;
BEGIN
    -- ��������� product1 � product2
    comparison_result := product1.compare_product(product2);
    DBMS_OUTPUT.PUT_LINE('��������� product1 � product2: ' || comparison_result); 

    -- ��������� product1 � product3
    comparison_result := product1.compare_product(product3);
    DBMS_OUTPUT.PUT_LINE('��������� product1 � product3: ' || comparison_result);

    -- ��������� product2 � product1
    comparison_result := product2.compare_product(product1);
    DBMS_OUTPUT.PUT_LINE('��������� product2 � product1: ' || comparison_result); 
END;
/


// �������� ��������� ����� ������
-- ������� ��������� ��� ��� ������� (Products)
CREATE OR REPLACE TYPE Product_Obj AS OBJECT (
    ID NUMBER,
    Name NVARCHAR2(255),
    Article NVARCHAR2(50),
    Description CLOB,
    MeasurementUnit NVARCHAR2(50),
    Price NUMBER,
    
    -- �������������� ����������� (����� 2a)
    CONSTRUCTOR FUNCTION Product_Obj(
        ID NUMBER,
        p_name NVARCHAR2,
        p_article NVARCHAR2,
        p_price NUMBER
    ) RETURN SELF AS RESULT,
    
    -- ����� ��������� ORDER (����� 2b)
    ORDER MEMBER FUNCTION compare_product(p_product Product_Obj) RETURN NUMBER,
    
    -- ������� ��� ����� ���������� (����� 2c)
    MEMBER FUNCTION calculate_discounted_price(p_discount NUMBER) RETURN NUMBER DETERMINISTIC,
    
    -- ��������� ��� ����� ���������� (����� 2d)
    MEMBER PROCEDURE update_price(p_new_price NUMBER)
);
/

-- ���� ���� ��� �������
CREATE OR REPLACE TYPE BODY Product_Obj AS
    -- ���������� ��������������� ������������
    CONSTRUCTOR FUNCTION Product_Obj(
        ID NUMBER,
        p_name NVARCHAR2,
        p_article NVARCHAR2,
        p_price NUMBER
    ) RETURN SELF AS RESULT IS
    BEGIN
        SELF.ID := NULL;
        SELF.Name := p_name;
        SELF.Article := p_article;
        SELF.Description := NULL;
        SELF.MeasurementUnit := NULL;
        SELF.Price := p_price;
        RETURN;
    END;
    
    -- ���������� ������ ���������
    ORDER MEMBER FUNCTION compare_product(p_product Product_Obj) RETURN NUMBER IS
    BEGIN
        IF SELF.Price < p_product.Price THEN
            RETURN -1;
        ELSIF SELF.Price > p_product.Price THEN
            RETURN 1;
        ELSE
            RETURN 0;
        END IF;
    END;
    
    -- ���������� �������-������
    MEMBER FUNCTION calculate_discounted_price(p_discount NUMBER) RETURN NUMBER DETERMINISTIC IS
    BEGIN
        RETURN SELF.Price * (1 - p_discount/100);
    END;
    
    -- ���������� ���������-������
    MEMBER PROCEDURE update_price(p_new_price NUMBER) IS
    BEGIN
        SELF.Price := p_new_price;
    END;
END;
/

-- ������� ��������� ��� ��� ������� (Warehouses)
CREATE OR REPLACE TYPE Warehouse_Obj AS OBJECT (
    ID NUMBER,
    Name NVARCHAR2(100),
    Address NVARCHAR2(255),
    Area NUMBER,
    ContactInfo NVARCHAR2(255),
    Type NVARCHAR2(255),
    
    -- �������������� ����������� (����� 2a)
    CONSTRUCTOR FUNCTION Warehouse_Obj(
        p_name NVARCHAR2,
        p_address NVARCHAR2,
        p_area NUMBER
    ) RETURN SELF AS RESULT,
    
    -- ����� ��������� MAP (����� 2b)
    MAP MEMBER FUNCTION warehouse_area RETURN NUMBER DETERMINISTIC,
    
    -- ������� ��� ����� ���������� (����� 2c)
    MEMBER FUNCTION can_store_hazardous RETURN VARCHAR2,
    
    -- ��������� ��� ����� ���������� (����� 2d)
    MEMBER PROCEDURE update_contact_info(p_new_info NVARCHAR2)
);
/

-- ���� ���� ��� �������
CREATE OR REPLACE TYPE BODY Warehouse_Obj AS
    -- ���������� ��������������� ������������
    CONSTRUCTOR FUNCTION Warehouse_Obj(
        p_name NVARCHAR2,
        p_address NVARCHAR2,
        p_area NUMBER
    ) RETURN SELF AS RESULT IS
    BEGIN
        SELF.ID := NULL;
        SELF.Name := p_name;
        SELF.Address := p_address;
        SELF.Area := p_area;
        SELF.ContactInfo := NULL;
        SELF.Type := NULL;
        RETURN;
    END;
    
    -- ���������� ������ ��������� MAP
    MAP MEMBER FUNCTION warehouse_area RETURN NUMBER IS
    BEGIN
        RETURN SELF.Area;
    END;
    
    -- ���������� �������-������
    MEMBER FUNCTION can_store_hazardous RETURN VARCHAR2 IS
    BEGIN
        IF SELF.Type = '����������' OR SELF.Area > 1000 THEN
            RETURN '��';
        ELSE
            RETURN '���';
        END IF;
    END;
    
    -- ���������� ���������-������
    MEMBER PROCEDURE update_contact_info(p_new_info NVARCHAR2) IS
    BEGIN
        SELF.ContactInfo := p_new_info;
    END;
END;
/







// �������� ��������� ������ � ����������� ������


-- ������� ��������� �������
CREATE TABLE Products_Obj1 OF Product_Obj (
    ID PRIMARY KEY
);

drop table Products_Obj1;

CREATE TABLE Warehouses_Obj1 OF Warehouse_Obj (
    ID PRIMARY KEY
);

-- �������� ������ �� ����������� ������ � ��������� (����� 3)
INSERT INTO Products_Obj1
SELECT Product_Obj(ID, Name, Article, Description, MeasurementUnit, Price)
FROM Products;
COMMIT;

INSERT INTO Warehouses_Obj1
SELECT Warehouse_Obj(ID, Name, Address, Area, ContactInfo, Type)
FROM Warehouses;
COMMIT;

select * from Warehouses_Obj1;
select * from Products_Obj1;




// ������������ ��������� �������������
CREATE OR REPLACE VIEW Products_View AS
SELECT 
    p.ID,
    p.Name,
    p.Article,
    p.Price,
    p.calculate_discounted_price(10) AS PriceWithDiscount
FROM Products_Obj1 p;

CREATE OR REPLACE VIEW Warehouses_View AS
SELECT 
    w.ID,
    w.Name,
    w.Address,
    w.Area,
    w.can_store_hazardous() AS CanStoreHazardous
FROM Warehouses_Obj1 w;

-- ������ ������� � ��������� ��������������
SELECT * FROM Products_View WHERE Price > 100;
SELECT * FROM Warehouses_View WHERE CanStoreHazardous = '��';

















-- ������ �� �������� ��������� �������
CREATE INDEX idx_product_price1 ON Products_Obj1(Price);

-- ������ �� ������ ���������� ����
CREATE bitmap INDEX idx_product_discounted_price ON Products_Obj1 p (
    p.calculate_discounted_price(10)
);

drop index idx_product_discounted_price;
-- ������ �� MAP ������ ��� �������
CREATE INDEX idx_warehouse_area ON Warehouses_Obj1 w (
    w.warehouse_area()
);

-- ������ ��������, ������������ ��� 

EXPLAIN PLAN FOR
SELECT * 
FROM Products_Obj1 
WHERE Price = 100;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

EXPLAIN PLAN FOR
SELECT * FROM Products_Obj1 p 
WHERE p.calculate_discounted_price(10) > 50;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

EXPLAIN PLAN FOR
SELECT * FROM Warehouses_Obj1 w
WHERE w.warehouse_area() > 500;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);










































-- ���������� ���� ������ � �������������� ������
DECLARE
    v_product Product_Obj;
BEGIN
    SELECT VALUE(p) INTO v_product 
    FROM Products_Obj1 p 
    WHERE p.ID = 10;
    
    v_product.update_price(150);
    
    UPDATE Products_Obj1 p
    SET p = v_product
    WHERE p.ID = 100;
    
    COMMIT;
END;
/

-- ������������� ������ ������
SELECT w.Name, w.can_store_hazardous()
FROM Warehouses_Obj1 w;