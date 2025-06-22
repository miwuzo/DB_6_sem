""-- 1. Создание таблицы клиентов
CREATE TABLE customers (
    customer_id NUMBER PRIMARY KEY,
    name NVARCHAR2(100) NOT NULL,
    email NVARCHAR2(100),
    phone NVARCHAR2(20),
    address NVARCHAR2(255)
);

-- 2. Создание таблицы продуктов
CREATE TABLE products (
    product_id NUMBER PRIMARY KEY,
    product_name NVARCHAR2(100) NOT NULL,
    price NUMBER(10, 2) NOT NULL
);

-- 3. Создание таблицы заказов
CREATE TABLE orders (
    order_id NUMBER PRIMARY KEY,
    customer_id NUMBER NOT NULL,
    order_date DATE DEFAULT SYSDATE,
    CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE
);

-- 4. Создание таблицы состава заказов
CREATE TABLE composition_of_orders (
    order_id NUMBER NOT NULL,
    product_id NUMBER NOT NULL,
    quantity NUMBER NOT NULL,
    CONSTRAINT fk_composition_orders FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    CONSTRAINT fk_composition_products FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
    PRIMARY KEY (order_id, product_id)
);

-- 5. Создание таблицы отчётов
CREATE TABLE report (
    id NUMBER PRIMARY KEY,
    xmldata XMLTYPE
);

-- 6. Индекс для XML-данных
CREATE INDEX ix_report_xmldata ON report(xmldata) INDEXTYPE IS XDB.XMLINDEX;
""
























select * from customers;

-- 1.

create table report (
    id number primary key,
    xmldata xmltype
);

-- 2. 

create or replace procedure GenerateXML as
    xmldata xmltype;
begin
    select 
        xmlelement("data",
            (
                select xmlagg(
                    xmlelement("product", 
                        xmlforest(p.product_id as "product_id", p.product_name as "product_name", p.price as "price")
                    ) order by p.product_id
                ) from products p
            ),
            (
                select xmlagg(
                    xmlelement("order", 
                        xmlforest(o.order_id as "order_id", o.order_date as "order_date"),
                        xmlelement("products",
                            (
                                select xmlagg(
                                    xmlelement("product_name", p.product_name)
                                )
                                from composition_of_orders co join products p on co.product_id = p.product_id 
                                where co.order_id = o.order_id
                            )
                        ),
                        xmlelement("total_cost",
                            (
                                select sum(co.quantity * p.price) from composition_of_orders co 
                                join products p on co.product_id = p.product_id 
                                where co.order_id = o.order_id
                            )
                        )
                    )
                ) from orders o
            ),
            (
                select xmlagg(
                    xmlelement("customer", 
                        xmlforest(c.customer_id as "customer_id", c.name as "name")
                    )
                ) from customers c
            ),
            xmlelement("generated_at", SYSTIMESTAMP)
        ) into xmldata from dual;
    insert into report (id, xmldata) values ((select NVL(max(id), 0) + 1 from report), xmldata);
    commit;
    dbms_output.put_line('XML generated and inserted into Report table.');
end;

exec GenerateXML;

select * from report;
delete from report;

-- 4. 

create index ix_report_xmldata1 on report(xmldata) indextype is xdb.xmlindex;
drop index ix_report_xmldata;

select * from report where exists (
    select 1 from XMLTable('/data/product' passing xmlData columns product_id number path 'product_id')
        where product_id = 1
);

-- 5.

create or replace procedure extractxmlvalue (
    attributename in nvarchar2,
    extractedvalues out sys_refcursor
)
as
    sqlstatement nvarchar2(1000);
begin
    sqlstatement := 'select x.ExtractedValue from report, XMLTABLE(''/data/*'' passing xmlData
        columns ExtractedValue nvarchar2(100) path ''' || attributename || ''') x';
    open extractedvalues for sqlstatement;
end;

declare
    extractedvaluescursor sys_refcursor;
    extractedvalue nvarchar2(100);
begin
    extractxmlvalue(attributename => 'product_name', extractedvalues => extractedvaluescursor);
    loop
        fetch extractedvaluescursor into extractedvalue;
        exit when extractedvaluescursor%notfound;
        dbms_output.put_line(extractedvalue);
    end loop;
    close extractedvaluescursor;
end;



-- 1. Выборка всех имён продуктов из XML
DECLARE
    extractedvaluescursor SYS_REFCURSOR;
    extractedvalue NVARCHAR2(100);
BEGIN
    extractxmlvalue(attributename => 'product_name', extractedvalues => extractedvaluescursor);
    LOOP
        FETCH extractedvaluescursor INTO extractedvalue;
        EXIT WHEN extractedvaluescursor%NOTFOUND;
        DBMS_OUTPUT.put_line(extractedvalue);
    END LOOP;
    CLOSE extractedvaluescursor;
END;


select * from products












-- 7. Заполнение таблицы customers
INSERT INTO customers (customer_id, name, email, phone, address) VALUES (1, 'Иван Иванов', 'ivanov@example.com', '1234567890', 'г. Москва, ул. Пушкина, д. 10');
INSERT INTO customers (customer_id, name, email, phone, address) VALUES (2, 'Петр Петров', 'petrov@example.com', '0987654321', 'г. Санкт-Петербург, ул. Ленина, д. 20');
INSERT INTO customers (customer_id, name, email, phone, address) VALUES (3, 'Сергей Сергеев', 'sergeev@example.com', '1122334455', 'г. Новосибирск, ул. Кирова, д. 30');

-- 8. Заполнение таблицы products
INSERT INTO products (product_id, product_name, price) VALUES (1, 'Телефон', 19999.99);
INSERT INTO products (product_id, product_name, price) VALUES (2, 'Ноутбук', 54999.99);
INSERT INTO products (product_id, product_name, price) VALUES (3, 'Планшет', 29999.99);

-- 9. Заполнение таблицы orders
INSERT INTO orders (order_id, customer_id, order_date) VALUES (1, 1, SYSDATE - 10);
INSERT INTO orders (order_id, customer_id, order_date) VALUES (2, 2, SYSDATE - 5);
INSERT INTO orders (order_id, customer_id, order_date) VALUES (3, 3, SYSDATE - 2);

-- 10. Заполнение таблицы composition_of_orders
INSERT INTO composition_of_orders (order_id, product_id, quantity) VALUES (1, 1, 2);
INSERT INTO composition_of_orders (order_id, product_id, quantity) VALUES (2, 2, 1);
INSERT INTO composition_of_orders (order_id, product_id, quantity) VALUES (3, 3, 1);
