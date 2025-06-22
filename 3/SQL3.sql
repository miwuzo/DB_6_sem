-- 1. ���������� ������� HierarchyID � ������� Positions
ALTER TABLE Positions
ADD HierarchyID HIERARCHYID NULL;  


UPDATE Positions SET HierarchyID = HIERARCHYID::GetRoot() WHERE ID = 1; 

INSERT INTO Positions (Name, Description, AccessLevel, WarehouseID, IsActive, HierarchyID)
VALUES ('������', '��������', 1, NULL, 1, HIERARCHYID::GetRoot());

-- 2. ��������� ��� ����������� ����������� ����� � ��������� ������
CREATE PROCEDURE GetSubordinatesWithLevel
    @Node HierarchyID
AS
BEGIN
    SELECT
        ID,
        Name,
        HierarchyID.ToString() AS HierarchyPath,
        HierarchyID.GetLevel() AS HierarchyLevel
    FROM
        Positions
    WHERE
	-- ������� HierarchyID �������� �������� ���� __
        HierarchyID.IsDescendantOf(@Node) = 1
    ORDER BY
        HierarchyID;
END;

EXEC GetSubordinatesWithLevel '/';
EXEC GetSubordinatesWithLevel '/1/';



-- 3. ��������� ��� ���������� ������������ ����
CREATE OR ALTER PROCEDURE AddSubordinateNode
    @ParentNodeId INT,
    @NewNodeName VARCHAR(100),
    @NewNodeDescription TEXT,
    @NewNodeAccessLevel INT,
    @NewNodeWarehouseID INT NULL,
    @NewNodeIsActive BIT
AS
BEGIN
    DECLARE @ParentNode HierarchyID;
    SELECT @ParentNode = HierarchyID FROM Positions WHERE ID = @ParentNodeId;

    IF @ParentNode IS NULL
    BEGIN
        RAISERROR('������������ ���� �� ������.', 16, 1);
        RETURN;
    END

    DECLARE @NewHierarchyID HierarchyID;

    -- ���������� HierarchyID ��� ���������� �������
    SELECT @NewHierarchyID = @ParentNode.GetDescendant(MAX(HierarchyID), NULL)
    FROM Positions
    WHERE HierarchyID.GetAncestor(1) = @ParentNode;

    -- ���� ��� �������� ---- ��������� ��� ���� ���
    IF @NewHierarchyID IS NULL
    BEGIN
        SET @NewHierarchyID = @ParentNode.GetDescendant(NULL, NULL);
    END

    
    INSERT INTO Positions (Name, Description, AccessLevel, WarehouseID, IsActive, HierarchyID)
    VALUES (@NewNodeName, @NewNodeDescription, @NewNodeAccessLevel, @NewNodeWarehouseID, @NewNodeIsActive, @NewHierarchyID);

    -- ID ������
    SELECT SCOPE_IDENTITY();
END;






-- ����
INSERT INTO Positions (Name, Description, AccessLevel, WarehouseID, IsActive, HierarchyID)
VALUES ('������', '�������� �����', 1, NULL, 1, HIERARCHYID::GetRoot());

-- 
EXEC AddSubordinateNode 38, '������� 2 - 4', '1-3', 2, 10, 1;

EXEC GetSubordinatesWithLevel '/';
EXEC AddSubordinateNode 46, '������� 3 - 2', '2-1', 3, 20, 1;
EXEC AddSubordinateNode 32, '������� 2 - 3', '2-3', 3, 22, 1;
EXEC MoveSubordinates 42, 43;  -- � 1 ��� 2.

TRUNCATE TABLE Positions;

CREATE OR ALTER PROCEDURE MoveSubordinates
    @SourceParentNodeId INT,
    @DestinationParentNodeId INT
AS
BEGIN
    DECLARE @SourceParentNodeHierarchy HIERARCHYID;
    DECLARE @DestinationParentNodeHierarchy HIERARCHYID;
    DECLARE @ChildId INT;
    DECLARE @ChildHierarchy HIERARCHYID;
    DECLARE @NewChildHierarchy HIERARCHYID;
    DECLARE @MaxSiblingHierarchy HIERARCHYID;

    -- �������� HierarchyID ��� ��������� � �������� ������������ �����
    SELECT @SourceParentNodeHierarchy = HierarchyID FROM Positions WHERE ID = @SourceParentNodeId;
    SELECT @DestinationParentNodeHierarchy = HierarchyID FROM Positions WHERE ID = @DestinationParentNodeId;

    -- �������� �� ������������� �����
    IF @SourceParentNodeHierarchy IS NULL OR @DestinationParentNodeHierarchy IS NULL
    BEGIN
        PRINT '������: ���� �� ��������� ����� �� ����������.';
        RETURN;
    END;

    -- ������ ��� �������� �������� �����
    DECLARE child_cursor CURSOR FOR
        SELECT ID, HierarchyID
        FROM Positions
        WHERE HierarchyID.IsDescendantOf(@SourceParentNodeHierarchy) = 1
          AND HierarchyID <> @SourceParentNodeHierarchy  -- ��������� ��� �������� ��������
        ORDER BY HierarchyID;

    OPEN child_cursor;
    FETCH NEXT FROM child_cursor INTO @ChildId, @ChildHierarchy;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- ������� ������������ sibling, ����� �������� ����� ���� � �����
        SELECT TOP 1 @MaxSiblingHierarchy = HierarchyID
        FROM Positions
        WHERE HierarchyID.GetAncestor(1) = @DestinationParentNodeHierarchy  --  ����� siblings  @DestinationParentNodeHierarchy
        ORDER BY HierarchyID DESC;

        --  ������� ����� ���� ��� ��������� ��������, �������� ��� � ����� siblings
        SET @NewChildHierarchy = @DestinationParentNodeHierarchy.GetDescendant(@MaxSiblingHierarchy, NULL);


        -- ��������� HierarchyID ��������� ����
        UPDATE Positions
        SET HierarchyID = @NewChildHierarchy
        WHERE ID = @ChildId;

        FETCH NEXT FROM child_cursor INTO @ChildId, @ChildHierarchy;
    END;

    CLOSE child_cursor;
    DEALLOCATE child_cursor;
END;















-- 4 ����������� ���� ����������� �����
CREATE OR ALTER PROCEDURE MoveSubordinates
    @SourceParentNodeId INT,
    @DestinationParentNodeId INT
AS
BEGIN
   

    BEGIN TRANSACTION;

    BEGIN TRY
        
        DECLARE @SourceParentNode HIERARCHYID;
        DECLARE @DestinationParentNode HIERARCHYID;
        DECLARE @NewSourceParentNode HIERARCHYID;
        DECLARE @SourceParentNodeString NVARCHAR(MAX);
        DECLARE @NewSourceParentNodeString NVARCHAR(MAX);
		DECLARE @TempTable TABLE (
			ID INT,
			OldHierarchyID HIERARCHYID,
			NewHierarchyID HIERARCHYID
		);

        
        SELECT @SourceParentNode = HierarchyID FROM Positions WHERE ID = @SourceParentNodeId;
        SELECT @DestinationParentNode = HierarchyID FROM Positions WHERE ID = @DestinationParentNodeId;

       
        IF @SourceParentNode IS NULL OR @DestinationParentNode IS NULL
        BEGIN
            RAISERROR('One or both parent nodes not found.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

		SELECT @NewSourceParentNode = @DestinationParentNode.GetDescendant(NULL, NULL);

        SELECT @SourceParentNodeString = @SourceParentNode.ToString();
        SELECT @NewSourceParentNodeString = @NewSourceParentNode.ToString();

		INSERT INTO @TempTable (ID, OldHierarchyID, NewHierarchyID)
		SELECT
			p.ID,
			p.HierarchyID,
			CONVERT(hierarchyid, @NewSourceParentNodeString + SUBSTRING(CONVERT(NVARCHAR(MAX), p.HierarchyID), LEN(@SourceParentNodeString) + 1, 8000))
		FROM Positions p
		WHERE p.HierarchyID.IsDescendantOf(@SourceParentNode) = 1;

		UPDATE Positions
		SET HierarchyID = t.NewHierarchyID
		FROM Positions p
		INNER JOIN @TempTable t ON p.ID = t.ID;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000);

    END CATCH;
END;

EXEC MoveSubordinates 31, 37;  -- � 1 ��� 2.


--������
WITH PositionHierarchy AS (
    SELECT
        ID,
        Name,
        CAST(Name AS VARCHAR(MAX)) AS DisplayPath,
        HierarchyID,
        HierarchyID.GetLevel() AS Level
    FROM
        Positions
    WHERE
        HierarchyID = HIERARCHYID::GetRoot() 
    UNION ALL
    SELECT
        e.ID,
        e.Name,
        CAST(ph.DisplayPath + ' / ' + e.Name AS VARCHAR(MAX)) AS DisplayPath,
        e.HierarchyID,
        e.HierarchyID.GetLevel() AS Level
    FROM
        Positions e
    INNER JOIN
        PositionHierarchy ph ON e.HierarchyID.GetAncestor(1) = ph.HierarchyID
)
SELECT
    ID,
    Name,
    DisplayPath,
    Level
FROM
    PositionHierarchy
ORDER BY
    HierarchyID;






