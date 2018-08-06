<Query Kind="SQL" />

-- Search tables and views for column by name

DECLARE @colName VARCHAR(50) = 'FOO'

SELECT      COLUMN_NAME AS 'ColumnName'
            ,TABLE_NAME AS  'TableName'
FROM        INFORMATION_SCHEMA.COLUMNS
WHERE       COLUMN_NAME LIKE '%' + @colName + '%'
ORDER BY    TableName
            ,ColumnName;