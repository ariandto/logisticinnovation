;WITH ArmadaLatest AS (
    SELECT 
        ba.tanggal,
        ba.no_polisi,
        ba.type,
        ba.note,
        ROW_NUMBER() OVER (PARTITION BY ba.no_polisi ORDER BY ba.Adddate DESC) AS rn
    FROM Expediter.dbo.t_Book_Armada ba
    WHERE ba.tanggal = '2025-09-08'
)
SELECT
    ma2.kode_armada AS KodeArmada,
    ma2.no_polisi AS Nopol,
    al.tanggal AS Tanggal,
    al.type AS planbookingtype, 
    al.note,
    CASE 
        WHEN al.type IS NULL AND al.tanggal IS NULL AND al.note IS NULL THEN 'Idle'
        WHEN al.type IN ('INS','POL','RBR','SVB','SVC','SVL') THEN 'Not Available'
        WHEN al.type IN ('DCS','DST','LOD','PLN') THEN 'Utilize'
        ELSE NULL
    END AS StatusUtilization
FROM Expediter.dbo.m_Armada ma2
LEFT JOIN ArmadaLatest al
       ON ma2.no_polisi = al.no_polisi
      AND al.rn = 1  
WHERE ma2.relasi = 'AHI JABABEKA' 
  AND ma2.kode_armada NOT LIKE '%C%'
ORDER BY al.tanggal, ma2.no_polisi;


select distinct arm.no_polisi, from
(
	select no_polisi,type_fisik_umum from Expediter.dbo.m_armada where relasi = 'ahi jababeka' --and type_fisik_umum not in ('CONT-40')
)arm 
inner join
(
	select no_polisi,tanggal,status,type,bookid from Expediter.dbo.t_book_armada where tanggal = '2025-09-08'
)book on arm.no_polisi = book.no_polisi --where status in ( '1' ,'2' )
left join
(
	select code,descr,plancategory from Expediter.[dbo].[t_Config_Book] order by plancategory
)cfg on book.type = cfg.code
where plancategory < 3