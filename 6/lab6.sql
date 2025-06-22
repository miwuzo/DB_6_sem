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
        THEN 'С наибольшим количеством сотрудников'
        ELSE 'Обычный склад'
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
SET Datee = ADD_MONTHS(Datee, -24) -- Сдвигаем дату на 2 года назад
WHERE EXTRACT(YEAR FROM Datee) = 2025;






INSERT INTO Receipts (Datee, Supplier, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2025-03-05', 'YYYY-MM-DD'), 'ООО "Пример"', 'ТП-230305-005', 7, 1100000.00);
INSERT INTO Receipts (Datee, Supplier, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2025-03-12', 'YYYY-MM-DD'), 'АО "ЭлектроникаПлюс"', 'ЭП-230312-049', 6, 920000.00);
INSERT INTO Receipts (Datee, Supplier, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2025-04-08', 'YYYY-MM-DD'), 'ИП Смирнов А.А.', 'СМ-230408-016', 7, 350000.00);
INSERT INTO Receipts (Datee, Supplier, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2025-04-15', 'YYYY-MM-DD'), 'ООО "Бытовые решения"', 'БР-230415-082', 7, 580000.00);
INSERT INTO Receipts (Datee, Supplier, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2025-05-03', 'YYYY-MM-DD'), 'ЗАО "Продукты питания"', 'ПП-230503-037', 7, 225000.00);
INSERT INTO Receipts (Datee, Supplier, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2025-05-18', 'YYYY-MM-DD'), 'ООО "ТехноПоставка"', 'ТП-230518-006', 7, 950000.00);
INSERT INTO Receipts (Datee, Supplier, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2025-06-07', 'YYYY-MM-DD'), 'АО "ЭлектроникаПлюс"', 'ЭП-230607-050', 7, 810000.00);
INSERT INTO Receipts (Datee, Supplier, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2025-06-14', 'YYYY-MM-DD'), 'ИП Смирнов А.А.', 'СМ-230614-017', 7, 390000.00);
INSERT INTO Receipts (Datee, Supplier, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2025-07-09', 'YYYY-MM-DD'), 'ООО "Бытовые решения"', 'БР-230709-083', 7, 620000.00);
INSERT INTO Receipts (Datee, Supplier, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2025-07-22', 'YYYY-MM-DD'), 'ЗАО "Продукты питания"', 'ПП-230722-038', 6, 255000.00);
INSERT INTO Receipts (Datee, Supplier, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2025-08-11', 'YYYY-MM-DD'), 'ООО "ТехноПоставка"', 'ТП-230811-007', 6, 1020000.00);
INSERT INTO Receipts (Datee, Supplier, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2025-08-25', 'YYYY-MM-DD'), 'АО "ЭлектроникаПлюс"', 'ЭП-230825-051', 6, 880000.00);
INSERT INTO Receipts (Datee, Supplier, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2025-09-06', 'YYYY-MM-DD'), 'ИП Смирнов А.А.', 'СМ-230906-018', 6, 420000.00);
INSERT INTO Receipts (Datee, Supplier, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2025-09-19', 'YYYY-MM-DD'), 'ООО "Бытовые решения"', 'БР-230919-084', 6, 590000.00);
INSERT INTO Receipts (Datee, Supplier, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2025-10-05', 'YYYY-MM-DD'), 'ЗАО "Продукты питания"', 'ПП-231005-039', 6, 230000.00);
INSERT INTO Receipts (Datee, Supplier, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2025-10-16', 'YYYY-MM-DD'), 'ООО "ТехноПоставка"', 'ТП-231016-008', 6, 970000.00);
INSERT INTO Receipts (Datee, Supplier, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2025-11-07', 'YYYY-MM-DD'), 'АО "ЭлектроникаПлюс"', 'ЭП-231107-052', 6, 830000.00);
INSERT INTO Receipts (Datee, Supplier, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2025-11-14', 'YYYY-MM-DD'), 'ИП Смирнов А.А.', 'СМ-231114-019', 6, 440000.00);
INSERT INTO Receipts (Datee, Supplier, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2025-12-03', 'YYYY-MM-DD'), 'ООО "Бытовые решения"', 'БР-231203-085', 6, 650000.00);
INSERT INTO Receipts (Datee, Supplier, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2025-12-18', 'YYYY-MM-DD'), 'ЗАО "Продукты питания"', 'ПП-231218-040', 6, 265000.00);
INSERT INTO Receipts (Datee, Supplier, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2025-02-10', 'YYYY-MM-DD'), 'ООО "ТехноПоставка"', 'ТП-230210-009', 6, 890000.00);
INSERT INTO Receipts (Datee, Supplier, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2025-02-17', 'YYYY-MM-DD'), 'АО "ЭлектроникаПлюс"', 'ЭП-230217-053', 6, 720000.00);
INSERT INTO Receipts (Datee, Supplier, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2025-03-22', 'YYYY-MM-DD'), 'ИП Смирнов А.А.', 'СМ-230322-020', 6, 470000.00);
INSERT INTO Receipts (Datee, Supplier, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2025-04-28', 'YYYY-MM-DD'), 'ООО "Бытовые решения"', 'БР-230428-086', 6, 530000.00);
INSERT INTO Receipts (Datee, Supplier, InvoiceNumber, WarehouseID, Total) VALUES
(TO_DATE('2025-05-30', 'YYYY-MM-DD'), 'ЗАО "Продукты питания"', 'ПП-230530-041', 6, 215000.00);




-- Вставка данных в таблицу Warehouses
INSERT INTO Warehouses (Name, Address, Area, ContactInfo, Type) VALUES
('Центральный склад', 'г. Москва, ул. Промышленная, 15', 2500.5, '+7 (495) 123-45-67', 'Общего назначения');
INSERT INTO Warehouses (Name, Address, Area, ContactInfo, Type) VALUES
('Северный распределительный центр', 'г. Санкт-Петербург, ш. Выборгское, 45', 1800.0, '+7 (812) 987-65-43', 'Холодильный');
INSERT INTO Warehouses (Name, Address, Area, ContactInfo, Type) VALUES
('Южный логистический комплекс', 'г. Ростов-на-Дону, пр. Стачки, 123', 3200.75, '+7 (863) 456-78-90', 'Отапливаемый');
INSERT INTO Warehouses (Name, Address, Area, ContactInfo, Type) VALUES
('Восточный терминал', 'г. Екатеринбург, ул. Магистральная, 67', 1500.25, '+7 (343) 345-67-89', 'Сортировочный');
INSERT INTO Warehouses (Name, Address, Area, ContactInfo, Type) VALUES
('Западный склад', 'г. Калининград, ул. Портовое шоссе, 12', 950.0, '+7 (4012) 34-56-78', 'Морской терминал');
INSERT INTO Warehouses (Name, Address, Area, ContactInfo, Type) VALUES
('Склад №6', 'г. Новосибирск, ул. Логистическая, 8', 2100.0, '+7 (383) 123-45-67', 'Автоматизированный');
INSERT INTO Warehouses (Name, Address, Area, ContactInfo, Type) VALUES
('Фулфилмент центр', 'г. Казань, пр. Победы, 141', 2750.5, '+7 (843) 987-65-43', 'Электронной коммерции');
INSERT INTO Warehouses (Name, Address, Area, ContactInfo, Type) VALUES
('Агросклад', 'г. Краснодар, ул. Зерновая, 33', 1850.0, '+7 (861) 234-56-78', 'Сельскохозяйственный');
INSERT INTO Warehouses (Name, Address, Area, ContactInfo, Type) VALUES
('Фармацевтический склад', 'г. Воронеж, ул. Медицинская, 5', 1200.75, '+7 (473) 345-67-89', 'Фармацевтический');
INSERT INTO Warehouses (Name, Address, Area, ContactInfo, Type) VALUES
('Опасные грузы', 'г. Самара, промзона "Восток", стр. 7', 800.0, '+7 (846) 456-78-90', 'Опасные материалы');

-- Вставка данных в таблицу Positions
INSERT INTO Positions (Name, Description, AccessLevel, WarehouseID, IsActive) VALUES
('Управляющий складом', 'Руководство всеми операциями склада', 5, 1, 1);
INSERT INTO Positions (Name, Description, AccessLevel, WarehouseID, IsActive) VALUES
('Старший кладовщик', 'Контроль работы кладовщиков, приемка товара', 4, 1, 1);
INSERT INTO Positions (Name, Description, AccessLevel, WarehouseID, IsActive) VALUES
('Кладовщик', 'Прием, хранение и отпуск товара', 3, 1, 1);
INSERT INTO Positions (Name, Description, AccessLevel, WarehouseID, IsActive) VALUES
('Грузчик', 'Погрузочно-разгрузочные работы', 2, 1, 1);
INSERT INTO Positions (Name, Description, AccessLevel, WarehouseID, IsActive) VALUES
('Оператор ПК', 'Ведение учета в системе WMS', 3, 1, 1);
INSERT INTO Positions (Name, Description, AccessLevel, WarehouseID, IsActive) VALUES
('Логист', 'Планирование перемещений товара', 4, NULL, 1);
INSERT INTO Positions (Name, Description, AccessLevel, WarehouseID, IsActive) VALUES
('Менеджер по запасам', 'Контроль остатков, заказы поставщикам', 4, NULL, 1);
INSERT INTO Positions (Name, Description, AccessLevel, WarehouseID, IsActive) VALUES
('Администратор системы', 'Обслуживание складского ПО', 5, NULL, 1);
INSERT INTO Positions (Name, Description, AccessLevel, WarehouseID, IsActive) VALUES
('Управляющий холодильным складом', 'Специализированное управление холодильным складом', 5, 2, 1);
INSERT INTO Positions (Name, Description, AccessLevel, WarehouseID, IsActive) VALUES
('Оператор холодильного оборудования', 'Обслуживание холодильных установок', 3, 2, 1);
INSERT INTO Positions (Name, Description, AccessLevel, WarehouseID, IsActive) VALUES
('Водитель погрузчика', 'Работа на складской технике', 3, 3, 1);
INSERT INTO Positions (Name, Description, AccessLevel, WarehouseID, IsActive) VALUES
('Маркировщик', 'Маркировка и упаковка товаров', 2, 3, 1);
INSERT INTO Positions (Name, Description, AccessLevel, WarehouseID, IsActive) VALUES
('Контролер качества', 'Проверка качества поступающего товара', 3, 4, 1);
INSERT INTO Positions (Name, Description, AccessLevel, WarehouseID, IsActive) VALUES
('Специалист по опасным грузам', 'Работа с опасными материалами', 4, 10, 1);
INSERT INTO Positions (Name, Description, AccessLevel, WarehouseID, IsActive) VALUES
('Фармацевт-кладовщик', 'Специалист по хранению лекарств', 4, 9, 1);

select * from positions
-- Вставка данных в таблицу Employees
INSERT INTO Employees (FullName, PositionID, WarehouseID, ContactInfo, Status) VALUES
('Иванов Сергей Петрович', 41, 6, '+7 (916) 123-45-67', 'active');
INSERT INTO Employees (FullName, PositionID, WarehouseID, ContactInfo, Status) VALUES
('Петрова Анна Владимировна', 42, 6, '+7 (926) 234-56-78', 'active');
INSERT INTO Employees (FullName, PositionID, WarehouseID, ContactInfo, Status) VALUES
('Сидоров Михаил Игоревич', 43, 6, '+7 (903) 345-67-89', 'active');
INSERT INTO Employees (FullName, PositionID, WarehouseID, ContactInfo, Status) VALUES
('Кузнецова Елена Дмитриевна', 44, 6, '+7 (967) 456-78-90', 'active');
INSERT INTO Employees (FullName, PositionID, WarehouseID, ContactInfo, Status) VALUES
('Васильев Андрей Сергеевич', 45, 6, '+7 (905) 567-89-01', 'active');
INSERT INTO Employees (FullName, PositionID, WarehouseID, ContactInfo, Status) VALUES
('Николаев Денис Олегович', 46, 6, '+7 (916) 678-90-12', 'active');
INSERT INTO Employees (FullName, PositionID, WarehouseID, ContactInfo, Status) VALUES
('Смирнова Ольга Александровна', 47, 6, '+7 (926) 789-01-23', 'active');
INSERT INTO Employees (FullName, PositionID, WarehouseID, ContactInfo, Status) VALUES
('Федоров Иван Васильевич', 41, 6, '+7 (903) 890-12-34', 'active');
INSERT INTO Employees (FullName, PositionID, WarehouseID, ContactInfo, Status) VALUES
('Алексеева Татьяна Николаевна', 42, 6, '+7 (967) 901-23-45', 'active');
INSERT INTO Employees (FullName, PositionID, WarehouseID, ContactInfo, Status) VALUES
('Громов Павел Андреевич', 43, 6, '+7 (905) 012-34-56', 'active');
INSERT INTO Employees (FullName, PositionID, WarehouseID, ContactInfo, Status) VALUES
('Белов Алексей Дмитриевич', 44, 6, '+7 (916) 123-45-67', 'active');
INSERT INTO Employees (FullName, PositionID, WarehouseID, ContactInfo, Status) VALUES
('Ковалева Марина Сергеевна', 45, 6, '+7 (926) 234-56-78', 'active');
INSERT INTO Employees (FullName, PositionID, WarehouseID, ContactInfo, Status) VALUES
('Оyuuв Дмитрий Викторович', 46, 6, '+7 (903) 345-67-89', 'active');
INSERT INTO Employees (FullName, PositionID, WarehouseID, ContactInfo, Status) VALUES
('Лебедева Ирина Анатольевна', 47, 6, '+7 (967) 456-78-90', 'active');
INSERT INTO Employees (FullName, PositionID, WarehouseID, ContactInfo, Status) VALUES
('Соколов Артем Валерьевич', 41, 6, '+7 (905) 567-89-01', 'active');
INSERT INTO Employees (FullName, PositionID, WarehouseID, ContactInfo, Status) VALUES
('Волкова Наталья Игоревна', 42, 6, '+7 (916) 678-90-12', 'active');
INSERT INTO Employees (FullName, PositionID, WarehouseID, ContactInfo, Status) VALUES
('Козлов Владимир Александрович', 43, 6, '+7 (926) 789-01-23', 'active');
INSERT INTO Employees (FullName, PositionID, WarehouseID, ContactInfo, Status) VALUES
('Новикова Екатерина Сергеевна', 44, 6, '+7 (903) 890-12-34', 'active');
INSERT INTO Employees (FullName, PositionID, WarehouseID, ContactInfo, Status) VALUES
('Морозов Антон Павлович', 45, 6, '+7 (967) 901-23-45', 'active');
INSERT INTO Employees (FullName, PositionID, WarehouseID, ContactInfo, Status) VALUES
('Павлова Светлана Викторовна', 46, 6, '+7 (905) 012-34-56', 'active');
INSERT INTO Employees (FullName, PositionID, WarehouseID, ContactInfo, Status) VALUES
('Семенов Игорь Николаевич', 47, 6, '+7 (916) 123-45-67', 'active');
INSERT INTO Employees (FullName, PositionID, WarehouseID, ContactInfo, Status) VALUES
('Михайлова Юлия Андреевна', 41, 6, '+7 (926) 234-56-78', 'active');
INSERT INTO Employees (FullName, PositionID, WarehouseID, ContactInfo, Status) VALUES
('Тарасов Роман Олегович', 42, 6, '+7 (903) 345-67-89', 'active');
INSERT INTO Employees (FullName, PositionID, WarehouseID, ContactInfo, Status) VALUES
('Филиппова Анастасия Дмитриевна', 43, 6, '+7 (967) 456-78-90', 'active');
INSERT INTO Employees (FullName, PositionID, WarehouseID, ContactInfo, Status) VALUES
('Данилов Артем Сергеевич', 44, 6, '+7 (905) 567-89-01', 'active');
INSERT INTO Employees (FullName, PositionID, WarehouseID, ContactInfo, Status) VALUES
('Савельева Елена Владимировна', 45, 6, '+7 (916) 678-90-12', 'active');
INSERT INTO Employees (FullName, PositionID, WarehouseID, ContactInfo, Status) VALUES
('Григорьев Максим Игоревич', 46, 6, '+7 (926) 789-01-23', 'active');
INSERT INTO Employees (FullName, PositionID, WarehouseID, ContactInfo, Status) VALUES
('Титова Анна Павловна', 47, 6, '+7 (903) 890-12-34', 'active');
INSERT INTO Employees (FullName, PositionID, WarehouseID, ContactInfo, Status) VALUES
('Комарова Виктория Александровна', 45, 6, '+7 (967) 901-23-45', 'active');

-- Вставка данных в таблицу Products
INSERT INTO Products (Name, Article, Description, MeasurementUnit, Price) VALUES
('Ноутбук ASUS X515', 'NB-ASUS-X515', '15.6", Intel Core i5, 8GB RAM, 512GB SSD', 'шт.', 54990.00);
INSERT INTO Products (Name, Article, Description, MeasurementUnit, Price) VALUES
('Смартфон Samsung Galaxy A53', 'PH-SM-A53', '6.5", 128GB, 5G, черный', 'шт.', 32990.00);
INSERT INTO Products (Name, Article, Description, MeasurementUnit, Price) VALUES
('Холодильник Beko RCNA400K20W', 'FR-BEKO-RCNA400', 'No Frost, 395 л, белый', 'шт.', 45990.00);
INSERT INTO Products (Name, Article, Description, MeasurementUnit, Price) VALUES
('Кофе в зернах Lavazza Qualita Oro', 'CF-LV-QORO', '250 г, 100% арабика', 'кг', 890.00);
INSERT INTO Products (Name, Article, Description, MeasurementUnit, Price) VALUES
('Машинное масло Mobil Super 3000', 'OIL-MOB-SUPER3K', '5W-40, 5 л', 'л', 3200.00);
INSERT INTO Products (Name, Article, Description, MeasurementUnit, Price) VALUES
('Плитка шоколада "Аленка"', 'CH-ALENKA', 'Молочный шоколад, 100 г', 'шт.', 65.00);
INSERT INTO Products (Name, Article, Description, MeasurementUnit, Price) VALUES
('Кроссовки Nike Air Max', 'SH-NIKE-AIRMAX', 'Мужские, размер 42, черные', 'пара', 8990.00);
INSERT INTO Products (Name, Article, Description, MeasurementUnit, Price) VALUES
('Чай Greenfield "Golden Ceylon"', 'TEA-GF-GCEYLON', '100 пакетиков, черный', 'уп.', 450.00);
INSERT INTO Products (Name, Article, Description, MeasurementUnit, Price) VALUES
('Стиральная машина LG F2J3NS0W', 'WM-LG-F2J3NS0W', '6 кг, фронтальная, белая', 'шт.', 32990.00);
INSERT INTO Products (Name, Article, Description, MeasurementUnit, Price) VALUES
('Наушники Sony WH-1000XM4', 'HP-SONY-WHXM4', 'Беспроводные, с шумоподавлением', 'шт.', 24990.00);
INSERT INTO Products (Name, Article, Description, MeasurementUnit, Price) VALUES
('Молоко "Домик в деревне" 3.2%', 'MLK-DOMIK-3.2', 'Ультрапастеризованное, 1 л', 'л', 95.00);
INSERT INTO Products (Name, Article, Description, MeasurementUnit, Price) VALUES
('Пылесос Philips PowerPro Compact', 'VAC-PH-PPC', 'Мощность 650 Вт, мешок 2 л', 'шт.', 7990.00);
INSERT INTO Products (Name, Article, Description, MeasurementUnit, Price) VALUES
('Гречневая крупа "Мистраль"', 'GRC-MISTRAL', 'Высший сорт, 800 г', 'кг', 120.00);
INSERT INTO Products (Name, Article, Description, MeasurementUnit, Price) VALUES
('Телевизор LG 43UP75006LF', 'TV-LG-43UP750', '43", 4K UHD, Smart TV', 'шт.', 42990.00);
INSERT INTO Products (Name, Article, Description, MeasurementUnit, Price) VALUES
('Мыло туалетное "Dove"', 'SOAP-DOVE', 'Увлажняющее, 100 г', 'шт.', 65.00);
INSERT INTO Products (Name, Article, Description, MeasurementUnit, Price) VALUES
('Батарейки Duracell AA', 'BAT-DUR-AA', 'Щелочные, 4 шт в упаковке', 'уп.', 350.00);
INSERT INTO Products (Name, Article, Description, MeasurementUnit, Price) VALUES
('Лампа светодиодная Gauss', 'LMP-GAUSS', 'E27, 10W, 3000K, теплый свет', 'шт.', 250.00);
INSERT INTO Products (Name, Article, Description, MeasurementUnit, Price) VALUES
('Вода минеральная "Evian"', 'WTR-EVIAN', '1.5 л, стеклянная бутылка', 'шт.', 290.00);
INSERT INTO Products (Name, Article, Description, MeasurementUnit, Price) VALUES
('Кресло офисное "Bureaucrat"', 'CHAIR-BUREAU', 'Кожаное, черное, с подголовником', 'шт.', 15990.00);
INSERT INTO Products (Name, Article, Description, MeasurementUnit, Price) VALUES
('Флешка SanDisk Ultra 64GB', 'USB-SD-ULTRA64', 'USB 3.0, скорость до 150 МБ/с', 'шт.', 990.00);
















