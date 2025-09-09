DECLARE @columns NVARCHAR(MAX), @sql NVARCHAR(MAX), @columnsForTotal NVARCHAR(MAX);

-- Ambil semua Jenis_Armada
SELECT @columns = STUFF((
    SELECT DISTINCT ', ' + QUOTENAME(Jenis_Armada)
    FROM arc_expediter.dbo.m_asset_armada
    FOR XML PATH(''), TYPE
).value('.', 'NVARCHAR(MAX)'), 1, 2, '');

-- Kolom untuk total per baris
SELECT @columnsForTotal =  STUFF((
    SELECT DISTINCT ' + ISNULL(' + QUOTENAME(Jenis_Armada) + ',0)'
    FROM arc_expediter.dbo.m_asset_armada
    FOR XML PATH(''), TYPE
).value('.', 'NVARCHAR(MAX)'), 1, 3, '');

SET @sql = N'
;WITH SourceData AS (
    SELECT 
        Jenis_Armada,
        pool_site,
        COUNT(No_polisi) AS Asset
    FROM arc_expediter.dbo.m_asset_armada
    GROUP BY Jenis_Armada, pool_site
    UNION ALL
    SELECT 
        Jenis_Armada,
        ''TOTAL'' AS pool_site,   -- baris grand total
        COUNT(No_polisi) AS Asset
    FROM arc_expediter.dbo.m_asset_armada
    GROUP BY Jenis_Armada
)
SELECT 
    pool_site, 
    ' + @columns + ',
    ' + @columnsForTotal + ' AS Total
FROM SourceData
PIVOT
(
    SUM(Asset)
    FOR Jenis_Armada IN (' + @columns + ')
) AS PivotTable
ORDER BY 
    CASE WHEN pool_site = ''TOTAL'' THEN 1 ELSE 0 END, 
    pool_site;';

EXEC sp_executesql @sql;