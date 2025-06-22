--  Создаем тип объекта
CREATE OR REPLACE TYPE ShipmentType AS OBJECT (
    ID NUMBER,
    с DATE,
    Client NVARCHAR2(50),
    InvoiceNumber NVARCHAR2(50),
    WarehouseID NUMBER,
    Total NUMBER
);
/

SELECT owner, table_name 
FROM all_tables 
WHERE upper(table_name) = 'WHAREHOUSE_DB';

CREATE TABLE SHIPMENTTABLE22 (
  ID NUMBER,
  DATEE DATE,
  CLIENT NVARCHAR2(50),
  INVOICENUMBER NVARCHAR2(50),
  WAREHOUSEID NUMBER,
  TOTAL NUMBER
);


INSERT INTO shipments (ID, DATEE, CLIENT, INVOICENUMBER, WAREHOUSEID, TOTAL)
VALUES (1, TO_DATE('2023-05-15', 'YYYY-MM-DD'), '', '-2023-001', 6, 12500.75);

INSERT INTO shipments (ID, DATEE, CLIENT, INVOICENUMBER, WAREHOUSEID, TOTAL)
VALUES (2, TO_DATE('2023-05-16', 'YYYY-MM-DD'), '', '-2023-002', 6, 8430.00);

INSERT INTO shipments (ID, DATEE, CLIENT, INVOICENUMBER, WAREHOUSEID, TOTAL)
VALUES (3, TO_DATE('2023-05-17', 'YYYY-MM-DD'), '', '-2023-003', 6, 21700.50);

truncate table shipments
select * from shipments
drop table SHIPMENTTABLE22;
select * from SHIPMENTTABLE22;
truncate table SHIPMENTTABLE22;

ALTER TABLE SHIPMENTTABLE MODIFY INVOICENUMBER VARCHAR2(50);
--  Создаем табличный тип
CREATE OR REPLACE TYPE ShipmentTable AS TABLE OF ShipmentType;
/

-- Создаем табличную функцию
CREATE OR REPLACE FUNCTION GetShipmentsByDateRange(
    p_start_date DATE,
    p_end_date DATE
) RETURN ShipmentTable PIPELINED
IS
BEGIN
    FOR rec IN (
        SELECT ID, Datee, Client, InvoiceNumber, WarehouseID, Total
        FROM Shipments
        WHERE Datee BETWEEN p_start_date AND p_end_date
    )
    LOOP
        PIPE ROW(ShipmentType(
            rec.ID,
            rec.Datee,
            rec.Client,
            rec.InvoiceNumber,
            rec.WarehouseID,
            rec.Total
        ));
    END LOOP;

    RETURN;
END;
/

truncate table shipments;
select * from shipments;
select * from SHIPMENTTABLE22;

delete from SHIPMENTTABLE;
SELECT OBJECT_TYPE FROM USER_OBJECTS WHERE OBJECT_NAME = 'SHIPMENTTABLE'

CREATE OR REPLACE DIRECTORY DIR22 AS '/opt/oracle/smelov';




SELECT text 
FROM user_source 
WHERE name = 'SHIPMENTTABLE' AND type = 'TYPE'
ORDER BY line;


-- 5. Процедура экспорта отгрузок в файл
CREATE OR REPLACE PROCEDURE ExportShipmentsToFile(
    p_start_date DATE,
    p_end_date DATE,
    p_file_name VARCHAR2,
    p_directory VARCHAR2
) IS
    file_handle UTL_FILE.FILE_TYPE;
    CURSOR shipment_cursor IS
        SELECT ID, Datee, Client, InvoiceNumber, WarehouseID, Total
        FROM Shipments
        WHERE Datee BETWEEN p_start_date AND p_end_date;
    shipment_record shipment_cursor%ROWTYPE;
BEGIN
    -- Открываем файл для записи
    file_handle := UTL_FILE.FOPEN(p_directory, p_file_name, 'w');

    -- Итерируем по результатам курсора
    FOR shipment_record IN shipment_cursor LOOP
        UTL_FILE.PUT_LINE(file_handle, 
            shipment_record.ID || ',' || 
            TO_CHAR(shipment_record.Datee, 'YYYY-MM-DD') || ',' || 
            shipment_record.Client || ',' || 
            shipment_record.InvoiceNumber || ',' || 
            shipment_record.WarehouseID || ',' || 
            shipment_record.Total);
    END LOOP;

    -- Закрываем файл
    UTL_FILE.FCLOSE(file_handle);
EXCEPTION
    WHEN OTHERS THEN
        -- Закрыть файл в случае ошибки
        IF UTL_FILE.IS_OPEN(file_handle) THEN
            UTL_FILE.FCLOSE(file_handle);
        END IF;
        RAISE;
END;
/




RENAME SHIPMENTTABLE TO SHIPMENTTABLE_OLD;





select * from ShipmentTable;
-- Сначала удалить существующую (если точно уверены)
DROP TABLE "ShipmentTable" PURGE;

-- Создать заново (обратите внимание на кавычки)
CREATE TABLE "ShipmentTable" (
  ID NUMBER,
  DATEE DATE,
  CLIENT VARCHAR2(100),
  INVOICENUMBER NUMBER,
  WAREHOUSEID NUMBER,
  TOTAL NUMBER
);










CREATE OR REPLACE PROCEDURE ExportShipmentsToFile(
    p_start_date DATE,
    p_end_date DATE,
    p_file_name VARCHAR2,
    p_directory VARCHAR2
) IS
    file_handle UTL_FILE.FILE_TYPE;
    CURSOR shipment_cursor IS
        SELECT ID, Datee, Client, InvoiceNumber, WarehouseID, Total
        FROM Shipments
        WHERE Datee BETWEEN p_start_date AND p_end_date;
    shipment_record shipment_cursor%ROWTYPE;
BEGIN
    -- Открываем файл для записи
    file_handle := UTL_FILE.FOPEN(p_directory, p_file_name, 'w');

    -- Записываем заголовки
    UTL_FILE.PUT_LINE(file_handle, 'ID,Date,Client,InvoiceNumber,WarehouseID,Total');

    -- Итерируем по результатам курсора
    FOR shipment_record IN shipment_cursor LOOP
        UTL_FILE.PUT_LINE(file_handle, 
            shipment_record.ID || ',' || 
            TO_CHAR(shipment_record.Datee, 'YYYY-MM-DD') || ',' || 
            shipment_record.Client || ',' || 
            shipment_record.InvoiceNumber || ',' || 
            shipment_record.WarehouseID || ',' || 
            shipment_record.Total);
    END LOOP;

    -- Закрываем файл
    UTL_FILE.FCLOSE(file_handle);
EXCEPTION
    WHEN OTHERS THEN
        -- Закрыть файл в случае ошибки
        IF UTL_FILE.IS_OPEN(file_handle) THEN
            UTL_FILE.FCLOSE(file_handle);
        END IF;
        RAISE;
END;
/




select * from SHIPMENTTABLE22


BEGIN
    ExportShipmentsToFile(
        p_start_date => TO_DATE('2023-01-01', 'YYYY-MM-DD'),
        p_end_date => TO_DATE('2023-12-31', 'YYYY-MM-DD'),
        p_file_name => 'shipments_export.txt',
        p_directory => 'DIR22'
    );
END;
/







SELECT owner, table_name 
FROM all_tables 
WHERE table_name = 'SHIPMENTTABLE';

















CREATE TABLESPACE WAREHOUSE_TS
DATAFILE '/opt/oracle/oradata/ORCLCDB/warehouse01.dbf' SIZE 500M
AUTOEXTEND ON NEXT 50M MAXSIZE 2G;


CREATE USER WAREHOUSE_DB IDENTIFIED BY "1111"
DEFAULT TABLESPACE WAREHOUSE_TS
TEMPORARY TABLESPACE TEMP
QUOTA UNLIMITED ON WAREHOUSE_TS;

GRANT CONNECT, RESOURCE TO WAREHOUSE_DB;
GRANT CREATE TABLE, CREATE VIEW TO WAREHOUSE_DB;