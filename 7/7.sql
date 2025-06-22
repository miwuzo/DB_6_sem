--Базовый прогноз на основе средних значений с ростом 5%
WITH warehouse_receipts AS (
    SELECT 
        w.ID,
        w.Name,
        EXTRACT(YEAR FROM r.Datee) AS year,
        COUNT(r.ID) AS receipt_count,
        SUM(r.Total) AS receipt_value
    FROM Warehouses w
    JOIN Receipts r ON w.ID = r.WarehouseID
    WHERE EXTRACT(YEAR FROM r.Datee) IN (2023, 2024)
    GROUP BY w.ID, w.Name, EXTRACT(YEAR FROM r.Datee)
)
SELECT ID, Name, year, receipt_count, receipt_value, 
       plan_receipt_count, plan_receipt_value
FROM warehouse_receipts
MODEL
    PARTITION BY (ID, Name)
    DIMENSION BY (year)
    MEASURES (receipt_count, receipt_value, 
              0 AS plan_receipt_count, 0 AS plan_receipt_value)
    RULES (
        plan_receipt_count[2025] = ROUND(AVG(receipt_count)[year < 2025] * 1.05, 0),
        plan_receipt_value[2025] = ROUND(AVG(receipt_value)[year < 2025] * 1.05, 2)
    )
ORDER BY ID, year;




INSERT INTO Receipts (Datee, Supplier, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2021-01-15', 'YYYY-MM-DD'), 'Supplier X', 'INV-001', 6, 1000.00);

INSERT INTO Receipts (Datee, Supplier, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2021-02-20', 'YYYY-MM-DD'), 'Supplier Y', 'INV-002', 6, 1200.00);

INSERT INTO Receipts (Datee, Supplier, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2021-03-10', 'YYYY-MM-DD'), 'Supplier X', 'INV-003', 6, 900.00);

INSERT INTO Receipts (Datee, Supplier, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2022-01-20', 'YYYY-MM-DD'), 'Supplier Y', 'INV-004', 6, 1100.00);

INSERT INTO Receipts (Datee, Supplier, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2022-02-25', 'YYYY-MM-DD'), 'Supplier Z', 'INV-005', 6, 1300.00);

INSERT INTO Receipts (Datee, Supplier, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2022-03-15', 'YYYY-MM-DD'), 'Supplier X', 'INV-006', 6, 1000.00);

INSERT INTO Receipts (Datee, Supplier, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2023-01-25', 'YYYY-MM-DD'), 'Supplier Z', 'INV-007', 6, 1400.00);

INSERT INTO Receipts (Datee, Supplier, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2023-02-28', 'YYYY-MM-DD'), 'Supplier Y', 'INV-008', 6, 1200.00);

INSERT INTO Receipts (Datee, Supplier, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2023-03-20', 'YYYY-MM-DD'), 'Supplier X', 'INV-009', 6, 1500.00);

INSERT INTO Receipts (Datee, Supplier, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2021-01-10', 'YYYY-MM-DD'), 'Supplier A', 'REC-001', 7, 500.00);

INSERT INTO Receipts (Datee, Supplier, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2021-02-15', 'YYYY-MM-DD'), 'Supplier B', 'REC-002', 7, 600.00);

INSERT INTO Receipts (Datee, Supplier, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2022-01-15', 'YYYY-MM-DD'), 'Supplier B', 'REC-003', 7, 700.00);

INSERT INTO Receipts (Datee, Supplier, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2022-02-20', 'YYYY-MM-DD'), 'Supplier A', 'REC-004', 7, 650.00);

INSERT INTO Receipts (Datee, Supplier, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2023-01-20', 'YYYY-MM-DD'), 'Supplier A', 'REC-005', 7, 800.00);

INSERT INTO Receipts (Datee, Supplier, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2023-02-25', 'YYYY-MM-DD'), 'Supplier B', 'REC-006', 7, 750.00);

INSERT INTO Receipts (Datee, Supplier, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2021-03-01', 'YYYY-MM-DD'), 'Supplier C', 'REC-007', 7, 2000.00);

INSERT INTO Receipts (Datee, Supplier, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2022-03-05', 'YYYY-MM-DD'), 'Supplier D', 'REC-008', 7, 1800.00);

INSERT INTO Receipts (Datee, Supplier, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2023-03-10', 'YYYY-MM-DD'), 'Supplier C', 'REC-009', 7, 2200.00);



INSERT INTO Shipments (Datee, Client, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2021-04-10', 'YYYY-MM-DD'), 'Client A', 'SHP-001', 6, 1100.00);

INSERT INTO Shipments (Datee, Client, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2021-05-15', 'YYYY-MM-DD'), 'Client B', 'SHP-002', 6, 900.00);

INSERT INTO Shipments (Datee, Client, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2021-06-20', 'YYYY-MM-DD'), 'Client A', 'SHP-003', 6, 1200.00);

INSERT INTO Shipments (Datee, Client, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2022-04-15', 'YYYY-MM-DD'), 'Client B', 'SHP-004', 6, 1300.00);

INSERT INTO Shipments (Datee, Client, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2022-05-20', 'YYYY-MM-DD'), 'Client C', 'SHP-005', 6, 1000.00);

INSERT INTO Shipments (Datee, Client, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2022-06-25', 'YYYY-MM-DD'), 'Client B', 'SHP-006', 6, 1400.00);

INSERT INTO Shipments (Datee, Client, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2023-04-20', 'YYYY-MM-DD'), 'Client C', 'SHP-007', 6, 1500.00);

INSERT INTO Shipments (Datee, Client, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2023-05-25', 'YYYY-MM-DD'), 'Client A', 'SHP-008', 6, 1300.00);

INSERT INTO Shipments (Datee, Client, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2023-06-30', 'YYYY-MM-DD'), 'Client B', 'SHP-009', 6, 1600.00);

INSERT INTO Shipments (Datee, Client, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2021-04-05', 'YYYY-MM-DD'), 'Client D', 'SHP-010', 7, 650.00);

INSERT INTO Shipments (Datee, Client, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2021-05-10', 'YYYY-MM-DD'), 'Client E', 'SHP-011', 7, 700.00);

INSERT INTO Shipments (Datee, Client, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2022-04-10', 'YYYY-MM-DD'), 'Client E', 'SHP-012', 7, 750.00);

INSERT INTO Shipments (Datee, Client, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2022-05-15', 'YYYY-MM-DD'), 'Client D', 'SHP-013', 7, 700.00);

INSERT INTO Shipments (Datee, Client, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2023-04-15', 'YYYY-MM-DD'), 'Client D', 'SHP-014', 7, 850.00);

INSERT INTO Shipments (Datee, Client, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2023-05-20', 'YYYY-MM-DD'), 'Client E', 'SHP-015', 7, 800.00);

INSERT INTO Shipments (Datee, Client, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2021-05-01', 'YYYY-MM-DD'), 'Client F', 'SHP-016', 7, 2100.00);

INSERT INTO Shipments (Datee, Client, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2022-05-05', 'YYYY-MM-DD'), 'Client G', 'SHP-017', 7, 1900.00);

INSERT INTO Shipments (Datee, Client, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2023-05-10', 'YYYY-MM-DD'), 'Client F', 'SHP-018', 7, 2300.00);










SELECT
    WarehouseID,
    FirstDate,
    PeakDate,
    LastDate,
    FirstTotal,
    PeakTotal,
    LastTotal
FROM
    Receipts
MATCH_RECOGNIZE (
    PARTITION BY WarehouseID
    ORDER BY Datee
    MEASURES
        FIRST(Datee) AS FirstDate,
        LAST(Datee) AS LastDate,
        A.Datee AS PeakDate,
        FIRST(Total) AS FirstTotal,
        A.Total AS PeakTotal,
        LAST(Total) AS LastTotal
    ALL ROWS PER MATCH
    PATTERN (ANY_ROW A UP DOWN)
    DEFINE
        A AS Total > PREV(Total),
        UP AS Total < PREV(Total),
        DOWN AS Total > PREV(Total)
) MR
WHERE FirstTotal > 0 
  AND PeakTotal > 0 AND PeakTotal > FirstTotal AND PeakTotal >  LastTotal   
  AND LastTotal > 0; 
































SELECT
    WarehouseID,
    FirstDate,
    PeakDate,
    LastDate,
    FirstTotal,
    PeakTotal,
    LastTotal
FROM
    Receipts
MATCH_RECOGNIZE (
    PARTITION BY WarehouseID
    ORDER BY Datee
    MEASURES
        FIRST(Datee) AS FirstDate,
        LAST(Datee) AS LastDate,
        A.Datee AS PeakDate,
        FIRST(Total) AS FirstTotal,
        A.Total AS PeakTotal,
        LAST(Total) AS LastTotal
    ALL ROWS PER MATCH
    PATTERN (ANY_ROW A DOWN)  
    DEFINE
        A AS Total > PREV(Total),
        DOWN AS Total <= PREV(Total)  
) MR
WHERE FirstTotal > 0 
  AND PeakTotal > 0 AND PeakTotal > FirstTotal AND PeakTotal >  LastTotal   
  AND LastTotal > 0; 