-- Data dictionary
SELECT 
    t.name AS TableName,
    c.name AS ColumnName,
    ty.name AS DataType,
    c.max_length AS MaxLength,
    c.is_nullable AS Nullable
FROM sys.tables t
JOIN sys.columns c ON t.object_id = c.object_id
JOIN sys.types ty ON c.user_type_id = ty.user_type_id
ORDER BY t.name, c.column_id;

-- Relations
SELECT 
    fk.name AS FK_Name,

    parent_table.name AS ParentTable,
    parent_column.name AS FK_Column,

    referenced_table.name AS ReferencedTable,
    referenced_column.name AS PK_Column

FROM sys.foreign_keys fk

JOIN sys.foreign_key_columns fkc
    ON fk.object_id = fkc.constraint_object_id

JOIN sys.tables parent_table
    ON fkc.parent_object_id = parent_table.object_id

JOIN sys.columns parent_column
    ON fkc.parent_object_id = parent_column.object_id
    AND fkc.parent_column_id = parent_column.column_id

JOIN sys.tables referenced_table
    ON fkc.referenced_object_id = referenced_table.object_id

JOIN sys.columns referenced_column
    ON fkc.referenced_object_id = referenced_column.object_id
    AND fkc.referenced_column_id = referenced_column.column_id

ORDER BY parent_table.name, fk.name;

--
execute sp_help 'data.Client'