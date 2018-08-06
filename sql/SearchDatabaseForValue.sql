/*
	Pulled from StackOverflow @ https://stackoverflow.com/a/12306613
	User Tim Lehner
*/

--------------------------------------------------------------------------------
-- Search all columns in all tables in a database for a string.
-- Does not search: image, sql_variant or user-defined types.
-- Exact search always for money and smallmoney; no wildcards for matching these.
--------------------------------------------------------------------------------
declare @SearchTerm nvarchar(4000) -- Can be max for SQL2005+
declare @ColumnName sysname

--------------------------------------------------------------------------------
-- SET THESE!
--------------------------------------------------------------------------------
set @SearchTerm = N'SEARCH_TERM' -- Term to be searched for, wildcards okay
set @ColumnName = N'' -- Use to restrict the search to certain columns, wildcards okay, null or empty string for all cols
--------------------------------------------------------------------------------
-- END SET
--------------------------------------------------------------------------------

set nocount on

declare @TabCols table (
      id int not null primary key identity
    , table_schema sysname not null
    , table_name sysname not null
    , column_name sysname not null
    , data_type sysname not null
)
insert into @TabCols (table_schema, table_name, column_name, data_type)
    select t.TABLE_SCHEMA, c.TABLE_NAME, c.COLUMN_NAME, c.DATA_TYPE
    from INFORMATION_SCHEMA.TABLES t
        join INFORMATION_SCHEMA.COLUMNS c on t.TABLE_SCHEMA = c.TABLE_SCHEMA
            and t.TABLE_NAME = c.TABLE_NAME
    where 1 = 1
        and t.TABLE_TYPE = 'base table'
        and c.DATA_TYPE not in ('image', 'sql_variant')
        and c.COLUMN_NAME like case when len(@ColumnName) > 0 then @ColumnName else '%' end
    order by c.TABLE_NAME, c.ORDINAL_POSITION

declare
      @table_schema sysname
    , @table_name sysname
    , @column_name sysname
    , @data_type sysname
    , @exists nvarchar(MAX) -- Can be max for SQL2005+
    , @sql nvarchar(MAX) -- Can be max for SQL2005+
    , @where nvarchar(MAX) -- Can be max for SQL2005+
    , @run nvarchar(MAX) -- Can be max for SQL2005+

while exists (select null from @TabCols) begin

    select top 1
          @table_schema = table_schema
        , @table_name = table_name
        , @exists = 'select null from [' + table_schema + '].[' + table_name + '] where 1 = 0'
        , @sql = 'select ''' + '[' + table_schema + '].[' + table_name + ']' + ''' as TABLE_NAME, * from [' + table_schema + '].[' + table_name + '] where 1 = 0'
        , @where = ''
    from @TabCols
    order by id

    while exists (select null from @TabCols where table_schema = @table_schema and table_name = @table_name) begin

        select top 1
              @column_name = column_name
            , @data_type = data_type
        from @TabCols
        where table_schema = @table_schema
            and table_name = @table_name
        order by id

        -- Special case for money
        if @data_type in ('money', 'smallmoney') begin
            if isnumeric(@SearchTerm) = 1 begin
                set @where = @where + ' or [' + @column_name + '] = cast(''' + @SearchTerm + ''' as ' + @data_type + ')' -- could also cast the column as varchar for wildcards
            end
        end
        -- Special case for xml
        else if @data_type = 'xml' begin
            set @where = @where + ' or cast([' + @column_name + '] as nvarchar(max)) like ''' + @SearchTerm + ''''
        end
        -- Special case for date
        else if @data_type in ('date', 'datetime', 'datetime2', 'datetimeoffset', 'smalldatetime', 'time') begin
            set @where = @where + ' or convert(nvarchar(50), [' + @column_name + '], 121) like ''' + @SearchTerm + ''''
        end
        -- Search all other types
        else begin
            set @where = @where + ' or [' + @column_name + '] like ''' + @SearchTerm + ''''
        end

        delete from @TabCols where table_schema = @table_schema and table_name = @table_name and column_name = @column_name

    end

    set @run = 'if exists(' + @exists + @where + ') begin ' + @sql + @where + ' print ''' + @table_name + ''' end'
    print @run
    exec sp_executesql @run

end

set nocount off