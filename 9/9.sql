-- 1. Создание типов для коллекций


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











-- 2. Создание коллекции K1 и вложенной коллекции K2

DECLARE
    K1 PositionCollection2 := PositionCollection2(); 
    K2 WarehouseCollection2; 
BEGIN
    -- Заполнение K1
    SELECT PositionType2(ID, Name, Description, AccessLevel, WarehouseID, NULL)
    BULK COLLECT INTO K1 FROM Positions;

    FOR i IN 1 .. K1.COUNT LOOP
        K2 := WarehouseCollection2();
        
        -- Заполнение K2 
        SELECT WarehouseType2(ID, Name, Address)
        BULK COLLECT INTO K2 FROM Warehouses WHERE ID = K1(i).WarehouseID;

        -- Присоединяем вложенную K2 к элементу K1
        K1(i).Warehouses := K2;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('Коллекция K1 и вложенные коллекции K2 успешно созданы.');
END;




select * from positions;


-- проверка является ли членом коллекции К1
DECLARE
    K1 PositionCollection2 := PositionCollection2(); 
    search_id NUMBER := 45; 
    found BOOLEAN := FALSE;
BEGIN
    -- Заполнение
    SELECT PositionType2(ID, Name, Description, AccessLevel, WarehouseID, NULL)
    BULK COLLECT INTO K1 FROM Positions;

    -- Проверка
    IF K1.COUNT > 0 THEN
        FOR i IN 1 .. K1.COUNT LOOP
            IF K1(i).ID = search_id THEN
                found := TRUE;
                EXIT; 
            END IF;
        END LOOP;

        IF found THEN
            DBMS_OUTPUT.PUT_LINE('Элемент с ID ' || search_id || ' найден в коллекции K1.');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Элемент с ID ' || search_id || ' не найден в коллекции K1.');
        END IF;
    ELSE
        DBMS_OUTPUT.PUT_LINE('Коллекция K1 пуста.');
    END IF;
END;





-- 
DECLARE
    K1 PositionCollection2 := PositionCollection2(); 
BEGIN
    -- Заполнение
    SELECT PositionType2(ID, Name, Description, AccessLevel, WarehouseID, NULL)      
    BULK COLLECT INTO K1 FROM Positions; -- where ID = '999999';

    -- Проверка 
    IF K1.COUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Коллекция K1 пуста.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Коллекция K1 не пуста. Элементов: ' || K1.COUNT);
    END IF;
END;




















-- преобразование 

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

    -- Вставка 
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
        DBMS_OUTPUT.PUT_LINE('Данные из коллекции K1 успешно вставлены в таблицу ArchivedPositions.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Коллекция K1 пуста, вставка не выполнена.');
    END IF;

    COMMIT; -- для складов
    DBMS_OUTPUT.PUT_LINE('Данные из коллекции K2 успешно вставлены в таблицу Warehouses.');
END;





select * from Warehouses2;
select * from ArchivedPositions;

truncate table ArchivedPositions;






-- bulk
DECLARE
    TYPE PositionArray2 IS TABLE OF PositionType2; -- Определяем тип 
    K1 PositionArray2; 
    v_old_access_level INTEGER;
BEGIN
    -- Заполнение 
    SELECT PositionType2(ID, Name, Description, AccessLevel, WarehouseID, NULL)
    BULK COLLECT INTO K1 FROM Positions;

    -- до обновления
    DBMS_OUTPUT.PUT_LINE('Данные до обновления:');
    FOR i IN 1 .. K1.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE('ID: ' || K1(i).ID || ', AccessLevel: ' || K1(i).AccessLevel);
    END LOOP;

    -----------
    FORALL i IN 1 .. K1.COUNT
        UPDATE Positions
        SET AccessLevel = AccessLevel + 1 
        WHERE ID = K1(i).ID; 

    COMMIT; 

    -- после обновления
    DBMS_OUTPUT.PUT_LINE('Данные после обновления:');
    FOR i IN 1 .. K1.COUNT LOOP
        SELECT AccessLevel INTO v_old_access_level
        FROM Positions
        WHERE ID = K1(i).ID;

        DBMS_OUTPUT.PUT_LINE('ID: ' || K1(i).ID || ', AccessLevel: ' || v_old_access_level);
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Доступные уровни обновлены для всех позиций из коллекции K1.');
END;
