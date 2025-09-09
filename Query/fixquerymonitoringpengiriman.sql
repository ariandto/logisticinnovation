DECLARE @startdate AS VARCHAR(20) ='2025-08-28'
DECLARE @enddate   AS VARCHAR(20) ='2025-08-28'
DECLARE @site      AS VARCHAR(20) = 'WMWHSE2'
DECLARE @owner     AS VARCHAR(20) = 'FBI'

-- aturan: kalau owner HCI maka site harus WMWHSE4
IF @owner = 'HCI'
    SET @site = 'WMWHSE4';

SELECT *
FROM
(
    SELECT 
        TRANSNO,
        PlanDeliveryDate,
        [site],
        [type],
        nopol,
        [Owner],
        SUBSTRING(TRANSNO, 7, 1) AS TypeLC
    FROM Expediter.dbo.t_si_h 
    WHERE plandeliverydate BETWEEN @startdate AND @enddate
      AND [site] = @site 
      AND [owner] = @owner
) sih
LEFT JOIN
(
    SELECT requestid, jalur 
    FROM Expediter.dbo.t_si_request
) req 
    ON sih.transno = req.requestid
LEFT JOIN
(
    SELECT si_no, rdo_no, driverid, drivername, crew1id, crew1name 
    FROM Expediter.dbo.t_rdo_h
) rdoh 
    ON sih.transno = rdoh.si_no
LEFT JOIN
(
    SELECT no_polisi, kode_armada 
    FROM Expediter.dbo.m_armada
) marm 
    ON sih.nopol = marm.no_polisi
LEFT JOIN
(
    SELECT 
        rdo_no,
        [1] AS [1],
        [2] AS [2],
        [3] AS [3],
        [4] AS [4],
        [5] AS [5],
        [6] AS [6],
        [7] AS [7],
        [8] AS [8],
        [9] AS [9],
        [10] AS [10],
        [11] AS [11],
        [12] AS [12],
        [13] AS [13],
        [14] AS [14],
        [15] AS [15]		
    FROM
    (
        SELECT 
            DENSE_RANK() OVER (PARTITION BY rdo_no ORDER BY detno) AS RowNum,
            rdo_no,
            checkin
        FROM Expediter.dbo.t_rdo_d
        WHERE status NOT IN (12, 13)
    ) AS SourceTable
    PIVOT
    (
        MAX(checkin) FOR RowNum IN 
        ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15])
    ) AS p
) rdod 
    ON rdoh.rdo_no = rdod.rdo_no;
