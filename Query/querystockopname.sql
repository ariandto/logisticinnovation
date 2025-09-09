--SELECT top 100 * FROM m_Asset_Armada

SELECT COUNT(DISTINCT Pool_Site) AS Jumlah_Site
FROM m_Asset_Armada;

-- Stock Opname armada

SELECT COUNT(*) AS Total_Armada,
SUM(CASE WHEN IsActive = 1 THEN 1 ELSE 0 END) AS Armada_Aktif,
SUM(CASE WHEN IsActive = 0 THEN 1 ELSE 0 END) AS Armada_NonAktif
FROM m_Asset_Armada;

SELECT DISTINCT Pool_Site from M_Asset_Armada WHERE Pool_Site is NOT NULL;

SELECT 
    Pool_Site, 
    COUNT(*) AS Total_Armada,
    SUM(CASE WHEN IsActive = 1 THEN 1 ELSE 0 END) AS Armada_Aktif,
    SUM(CASE WHEN IsActive = 0 THEN 1 ELSE 0 END) AS Armada_NonAktif
FROM m_Asset_Armada
GROUP BY Pool_Site
ORDER BY Total_Armada DESC;


SELECT 
    'ALL_SITE' AS Pool_Site,
    COUNT(*) AS Total_Armada,
    SUM(CASE WHEN IsActive = 1 THEN 1 ELSE 0 END) AS Armada_Aktif,
    SUM(CASE WHEN Tipe_BBM LIKE '%Solar%' THEN 1 ELSE 0 END) AS Armada_BBM_Solar,
    SUM(CASE WHEN Tipe_BBM LIKE '%Bensin%' THEN 1 ELSE 0 END) AS Armada_BBM_Bensin
FROM m_Asset_Armada

UNION ALL

-- Per site
SELECT 
    Pool_Site,
    COUNT(*) AS Total_Armada,
    SUM(CASE WHEN IsActive = 1 THEN 1 ELSE 0 END) AS Armada_Aktif,
    SUM(CASE WHEN Tipe_BBM LIKE '%Solar%' THEN 1 ELSE 0 END) AS Armada_BBM_Solar,
    SUM(CASE WHEN Tipe_BBM LIKE '%Bensin%' THEN 1 ELSE 0 END) AS Armada_BBM_Bensin
FROM m_Asset_Armada
GROUP BY Pool_Site;




--monitoring armada per site

SELECT Pool_Site,
Count(*) AS Total_Armada,
SUM(CASE WHEN IsActive = 1 THEN 1 ELSE 0 END) AS Armada_Aktif,
SUM(CASE WHEN IsActive = 0 THEN 1 ELSE 0 END) AS Armada_NonAktif
FROM m_Asset_Armada
Group BY Pool_Site
ORDER BY Total_Armada DESC;

--SELECT COUNT(*) AS Total_Asset_Armada
--FROM M_Asset_Armada;


--by tipe armada
SELECT 
    Tipe_Armada,
    COUNT(*) AS Total_Armada,
    SUM(CASE WHEN IsActive = 1 THEN 1 ELSE 0 END) AS Armada_Aktif,
    SUM(CASE WHEN IsActive = 0 THEN 1 ELSE 0 END) AS Armada_NonAktif
FROM m_Asset_Armada
GROUP BY Tipe_Armada
ORDER BY Total_Armada DESC;

--tahun pembuatan
SELECT 
    Tahun_Pembuatan,
    COUNT(*) AS Total_Armada,
    SUM(CASE WHEN IsActive = 1 THEN 1 ELSE 0 END) AS Armada_Aktif,
    SUM(CASE WHEN IsActive = 0 THEN 1 ELSE 0 END) AS Armada_NonAktif
FROM m_Asset_Armada
GROUP BY Tahun_Pembuatan
ORDER BY Tahun_Pembuatan ASC;

SELECT 
    Pool_Site,
    Tipe_BBM,
    COUNT(*) AS Total_Armada,
    SUM(CASE WHEN IsActive = 1 THEN 1 ELSE 0 END) AS Armada_Aktif,
    SUM(CASE WHEN IsActive = 0 THEN 1 ELSE 0 END) AS Armada_NonAktif
FROM m_Asset_Armada
GROUP BY Pool_Site, Tipe_BBM
ORDER BY Pool_Site, Total_Armada DESC;


SELECT 
    Relasi,
    COUNT(*) AS Total_Armada,
    SUM(CASE WHEN IsActive = 1 THEN 1 ELSE 0 END) AS Armada_Aktif,
    SUM(CASE WHEN IsActive = 0 THEN 1 ELSE 0 END) AS Armada_NonAktif
FROM m_Asset_Armada
GROUP BY Relasi
ORDER BY Total_Armada DESC;
