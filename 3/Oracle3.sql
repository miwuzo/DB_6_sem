ALTER TABLE Positions
ADD HierarchyID VARCHAR2(255) NULL;  -- Используем VARCHAR2 для хранения иерархического пути

ALTER TABLE Positions
ADD ParentID NUMBER NULL;

UPDATE Positions
SET HierarchyID = '/'
WHERE ID = 1; -- Предполагаем, что запись с ID = 1 будет корнем

TRUNCATE TABLE Positions;



-- Пример добавления корневого узла
INSERT INTO Positions (Name, ParentID, HierarchyID) VALUES ('Root', NULL, '/');

-- Создадим родителя с ID = 1, если его еще нет
BEGIN
  INSERT INTO Positions (ID, Name, ParentID, HierarchyID)
  SELECT 1, 'Root', NULL, '/'
  FROM dual
  WHERE NOT EXISTS (SELECT 1 FROM Positions WHERE ID = 1);
  COMMIT;
END;

-- 2. Процедура для отображения всех подчиненных узлов с указанием уровня иерархии

CREATE OR REPLACE PROCEDURE ShowSubtree (
    p_node_id IN NUMBER
) AS
    CURSOR c_subtree IS
        SELECT
            ID,
            Name,
            HierarchyID,
            LEVEL
        FROM
            Positions
        START WITH ID = p_node_id
        CONNECT BY PRIOR ID = ParentID
        ORDER SIBLINGS BY Name;

    v_record c_subtree%ROWTYPE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Subtree for node ID: ' || p_node_id);
    DBMS_OUTPUT.PUT_LINE('------------------------------------');

    OPEN c_subtree;
    LOOP
        FETCH c_subtree INTO v_record;
        EXIT WHEN c_subtree%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE('Level: ' || v_record.LEVEL || ', ID: ' || v_record.ID || ', Name: ' || v_record.Name || ', HierarchyID: ' || v_record.HierarchyID);
    END LOOP;
    CLOSE c_subtree;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No nodes found for ID: ' || p_node_id);
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
END;
/


-- 3. Процедура для добавления подчиненного узла

CREATE OR REPLACE PROCEDURE AddChildNode (
    p_parent_id IN NUMBER,
    p_child_name IN NVARCHAR2
) AS
    v_new_id NUMBER;
    v_parent_hierarchy VARCHAR2(255);
BEGIN
    -- Получаем HierarchyID родительского узла
    SELECT HierarchyID INTO v_parent_hierarchy FROM Positions WHERE ID = p_parent_id;

    -- Добавляем новую запись
    INSERT INTO Positions (Name, ParentID) VALUES (p_child_name, p_parent_id)
    RETURNING ID INTO v_new_id; -- Получаем ID добавленной записи

    -- Обновляем HierarchyID для новой записи
    UPDATE Positions
    SET HierarchyID = v_parent_hierarchy || v_new_id || '/'
    WHERE ID = v_new_id;

    DBMS_OUTPUT.PUT_LINE('Child node added with ID: ' || v_new_id || ', Name: ' || p_child_name);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Parent node not found with ID: ' || p_parent_id);
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
END;
/


-- 4. Процедура для перемещения всех подчиненных узлов

CREATE OR REPLACE PROCEDURE MoveSubtree (
    p_old_parent_id IN NUMBER,
    p_new_parent_id IN NUMBER
) AS
    v_old_hierarchy VARCHAR2(255);
    v_new_hierarchy VARCHAR2(255);
    v_subtree_root_id NUMBER;

    CURSOR c_subtree (p_subtree_root_id NUMBER) IS
        SELECT
            ID,
            HierarchyID
        FROM
            Positions
        WHERE
            HierarchyID LIKE (SELECT HierarchyID FROM Positions WHERE ID = p_subtree_root_id) || '%'
            AND ID != p_subtree_root_id;

    v_record c_subtree%ROWTYPE;
BEGIN
    -- Получаем HierarchyID старого и нового родительских узлов
    SELECT HierarchyID INTO v_old_hierarchy FROM Positions WHERE ID = p_old_parent_id;
    SELECT HierarchyID INTO v_new_hierarchy FROM Positions WHERE ID = p_new_parent_id;

    --  Убедимся, что p_new_parent_id не является потомком p_old_parent_id
    IF v_new_hierarchy LIKE v_old_hierarchy || '%' THEN
      RAISE_APPLICATION_ERROR(-20001, 'Cannot move subtree to a descendant of itself.');
    END IF;

    -- Получаем ID корня поддерева, которое будем перемещать (старый родительский ID)
    v_subtree_root_id := p_old_parent_id;

    -- Обновляем ParentID для подчиненных узлов (кроме корня поддерева)
    UPDATE Positions
    SET ParentID = p_new_parent_id
    WHERE ID = p_old_parent_id;


    -- Обновляем HierarchyID для перемещенных узлов
    FOR v_record IN c_subtree(v_subtree_root_id) LOOP
      UPDATE Positions
SET HierarchyID = v_new_hierarchy || SUBSTR(HierarchyID, LENGTH(v_old_hierarchy) + LENGTH((SELECT id FROM Positions WHERE ID = p_old_parent_id) || '/') - LENGTH((SELECT id FROM Positions WHERE ID = p_old_parent_id) || '/') +1)
WHERE ID = v_record.ID;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Subtree moved from parent ID: ' || p_old_parent_id || ' to parent ID: ' || p_new_parent_id);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Parent node not found with ID: ' || p_old_parent_id || ' or ' || p_new_parent_id);
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
END;
/




SELECT COUNT(*) FROM Positions WHERE ID = 1; -- Замените 1 на нужное значение ParentID

-- Добавим несколько узлов
EXECUTE AddChildNode(1, 'Child 1');
EXECUTE AddChildNode(1, 'Child 2');
EXECUTE AddChildNode(16, 'Grandchild 1');

-- Выведем поддерево
EXECUTE ShowSubtree(1);

-- Переместим поддерево
EXECUTE MoveSubtree(16, 17);

-- Выведем поддерево после перемещения
EXECUTE ShowSubtree(14);
-- Добавим еще один корень
INSERT INTO Positions (Name, ParentID, HierarchyID) VALUES ('Root2', NULL, '/');
-- Нельзя переместить корневое поддерево внутрь другого поддерева
BEGIN
  MoveSubtree(3,1);
END;
/
-- Очистка (удаление процедур и таблиц)
DROP PROCEDURE ShowSubtree;
DROP PROCEDURE AddChildNode;
DROP PROCEDURE MoveSubtree;
DROP TABLE Positions;
DROP TABLE Products;