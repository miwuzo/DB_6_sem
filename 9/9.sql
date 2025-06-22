-- 1. �������� ����� ��� ���������


CREATE OR REPLACE TYPE WarehouseType2 AS OBJECT (
    ID NUMBER,
    Name NVARCHAR2(100),
    Address NVARCHAR2(255)
);

CREATE OR REPLACE TYPE WarehouseCollection2 AS TABLE OF WarehouseType2;


CREATE OR REPLACE TYPE PositionType2 AS OBJECT (
    ID NUMBER,
    Name NVARCHAR2(100),
    Description CLOB,
    AccessLevel NUMBER,
    WarehouseID NUMBER,
    Warehouses WarehouseCollection2 
);

CREATE OR REPLACE TYPE PositionCollection2 AS TABLE OF PositionType2;











-- 2. �������� ��������� K1 � ��������� ��������� K2

DECLARE
    K1 PositionCollection2 := PositionCollection2(); 
    K2 WarehouseCollection2; 
BEGIN
    -- ���������� K1
    SELECT PositionType2(ID, Name, Description, AccessLevel, WarehouseID, NULL)
    BULK COLLECT INTO K1 FROM Positions;

    FOR i IN 1 .. K1.COUNT LOOP
        K2 := WarehouseCollection2();
        
        -- ���������� K2 
        SELECT WarehouseType2(ID, Name, Address)
        BULK COLLECT INTO K2 FROM Warehouses WHERE ID = K1(i).WarehouseID;

        -- ������������ ��������� K2 � �������� K1
        K1(i).Warehouses := K2;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('��������� K1 � ��������� ��������� K2 ������� �������.');
END;




select * from positions;


-- �������� �������� �� ������ ��������� �1
DECLARE
    K1 PositionCollection2 := PositionCollection2(); 
    search_id NUMBER := 45; 
    found BOOLEAN := FALSE;
BEGIN
    -- ����������
    SELECT PositionType2(ID, Name, Description, AccessLevel, WarehouseID, NULL)
    BULK COLLECT INTO K1 FROM Positions;

    -- ��������
    IF K1.COUNT > 0 THEN
        FOR i IN 1 .. K1.COUNT LOOP
            IF K1(i).ID = search_id THEN
                found := TRUE;
                EXIT; 
            END IF;
        END LOOP;

        IF found THEN
            DBMS_OUTPUT.PUT_LINE('������� � ID ' || search_id || ' ������ � ��������� K1.');
        ELSE
            DBMS_OUTPUT.PUT_LINE('������� � ID ' || search_id || ' �� ������ � ��������� K1.');
        END IF;
    ELSE
        DBMS_OUTPUT.PUT_LINE('��������� K1 �����.');
    END IF;
END;





-- 
DECLARE
    K1 PositionCollection2 := PositionCollection2(); 
BEGIN
    -- ����������
    SELECT PositionType2(ID, Name, Description, AccessLevel, WarehouseID, NULL)      
    BULK COLLECT INTO K1 FROM Positions; -- where ID = '999999';

    -- �������� 
    IF K1.COUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('��������� K1 �����.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('��������� K1 �� �����. ���������: ' || K1.COUNT);
    END IF;
END;




















-- �������������� 

CREATE TABLE ArchivedPositions (
     ID NUMBER,
     Name NVARCHAR2(100),
     Description CLOB,
     AccessLevel NUMBER,
     WarehouseID NUMBER
);

CREATE TABLE Warehouses2 (
    ID NUMBER PRIMARY KEY,
    Name NVARCHAR2(100),
    Address NVARCHAR2(255)
);



DECLARE
    K1 PositionCollection2 := PositionCollection2();
    K2 WarehouseCollection2 := WarehouseCollection2();
BEGIN
    
    SELECT PositionType2(ID, Name, Description, AccessLevel, WarehouseID, NULL)
    BULK COLLECT INTO K1 FROM Positions;

    
    SELECT WarehouseType2(ID, Name, Address)
    BULK COLLECT INTO K2 FROM Warehouses;

    -- ������� 
    IF K2.COUNT > 0 THEN
        FOR j IN 1 .. K2.COUNT LOOP
            INSERT INTO Warehouses2 (ID, Name, Address)
            VALUES (K2(j).ID, K2(j).Name, K2(j).Address);
        END LOOP;
    END IF;

    -- 
    IF K1.COUNT > 0 THEN
        FOR i IN 1 .. K1.COUNT LOOP
            INSERT INTO ArchivedPositions (ID, Name, Description, AccessLevel, WarehouseID)
            VALUES (K1(i).ID, K1(i).Name, K1(i).Description, K1(i).AccessLevel, K1(i).WarehouseID);
        END LOOP;

        COMMIT; 
        DBMS_OUTPUT.PUT_LINE('������ �� ��������� K1 ������� ��������� � ������� ArchivedPositions.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('��������� K1 �����, ������� �� ���������.');
    END IF;

    COMMIT; -- ��� �������
    DBMS_OUTPUT.PUT_LINE('������ �� ��������� K2 ������� ��������� � ������� Warehouses.');
END;





select * from Warehouses2;
select * from ArchivedPositions;

truncate table ArchivedPositions;






-- bulk
DECLARE
    TYPE PositionArray2 IS TABLE OF PositionType2; -- ���������� ��� 
    K1 PositionArray2; 
    v_old_access_level INTEGER;
BEGIN
    -- ���������� 
    SELECT PositionType2(ID, Name, Description, AccessLevel, WarehouseID, NULL)
    BULK COLLECT INTO K1 FROM Positions;

    -- �� ����������
    DBMS_OUTPUT.PUT_LINE('������ �� ����������:');
    FOR i IN 1 .. K1.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE('ID: ' || K1(i).ID || ', AccessLevel: ' || K1(i).AccessLevel);
    END LOOP;

    -----------
    FORALL i IN 1 .. K1.COUNT
        UPDATE Positions
        SET AccessLevel = AccessLevel + 1 
        WHERE ID = K1(i).ID; 

    COMMIT; 

    -- ����� ����������
    DBMS_OUTPUT.PUT_LINE('������ ����� ����������:');
    FOR i IN 1 .. K1.COUNT LOOP
        SELECT AccessLevel INTO v_old_access_level
        FROM Positions
        WHERE ID = K1(i).ID;

        DBMS_OUTPUT.PUT_LINE('ID: ' || K1(i).ID || ', AccessLevel: ' || v_old_access_level);
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('��������� ������ ��������� ��� ���� ������� �� ��������� K1.');
END;
