USE [arc_expediter]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[spMonitoringPengiriman]
    @startdate VARCHAR(20) = NULL,
    @enddate   VARCHAR(20) = NULL,
    @site      VARCHAR(MAX) = NULL,
    @owner     VARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @startdate IS NULL SET @startdate = CONVERT(VARCHAR(20), GETDATE(), 120);
    IF @enddate   IS NULL SET @enddate   = CONVERT(VARCHAR(20), GETDATE(), 120);

    CREATE TABLE #Sites (Site VARCHAR(50));
    CREATE TABLE #Owners (Owner VARCHAR(50));

    IF @site IS NOT NULL
    BEGIN
        DECLARE @SiteXML XML = CAST('<S><V>' + REPLACE(@site, ',', '</V><V>') + '</V></S>' AS XML);
        INSERT INTO #Sites (Site)
        SELECT LTRIM(RTRIM(V.value('.', 'VARCHAR(50)')))
        FROM @SiteXML.nodes('/S/V') AS X(V);
    END

    IF @owner IS NOT NULL
    BEGIN
        DECLARE @OwnerXML XML = CAST('<S><V>' + REPLACE(@owner, ',', '</V><V>') + '</V></S>' AS XML);
        INSERT INTO #Owners (Owner)
        SELECT LTRIM(RTRIM(V.value('.', 'VARCHAR(50)')))
        FROM @OwnerXML.nodes('/S/V') AS X(V);
    END

    ;WITH RdoSI AS
    (
        SELECT 
            SI_NO,
            COUNT(DISTINCT SEQUENCE) AS DropPoint,
            COUNT(DISTINCT ORDERKEY) AS [Order]
        FROM Expediter.dbo.t_rdo_si
        WHERE STATUS NOT IN (12, 13) 
          AND RTACTION NOT IN ('a','t')
        GROUP BY SI_NO
    ),
    MainResult AS
    (
        SELECT 
            sih.TRANSNO,
            CASE 
                WHEN LEN(sih.TRANSNO) >= 7 THEN SUBSTRING(sih.TRANSNO, 7, 1)
                ELSE ''
            END AS [type code],
            CASE 
                WHEN LEN(sih.TRANSNO) >= 7 THEN 
                    CASE SUBSTRING(sih.TRANSNO, 7, 1)
                        WHEN 'A' THEN 'Store Dalam Kota'
                        WHEN 'D' THEN 'Store Dalam Kota'
                        WHEN 'C' THEN 'Customer'
                        WHEN 'H' THEN 'Hub'
                        WHEN 'X' THEN 'Other Delivery'
                        WHEN 'B' THEN 'Store Luar Kota'
                        WHEN 'L' THEN 'Luar Kota'
                        WHEN 'T' THEN 'Transit Luar Kota'
                        ELSE ''
                    END
                ELSE ''
            END AS [Type Pengiriman],
            sih.PlanDeliveryDate,
            sih.[site],
            sih.[type],
            sih.nopol,
            sih.[Owner],
            sih.[Jenisarmada],
            (
                OLF.std_TravelTime * 2 + ISNULL(rdos.DropPoint,0) * 
                CASE 
                    WHEN LEN(sih.TRANSNO) >= 7 THEN 
                        CASE SUBSTRING(sih.TRANSNO,7,1)
                            WHEN 'C' THEN 30
                            WHEN 'H' THEN 120
                            WHEN 'A' THEN 
                                CASE 
                                    WHEN sih.Jenisarmada IN ('FUSO','WINGBOX','CONT-20') THEN 120
                                    WHEN sih.Jenisarmada = 'CONT-40' THEN 150
                                    ELSE 60
                                END
                            WHEN 'B' THEN 
                                CASE 
                                    WHEN sih.Jenisarmada IN ('FUSO','WINGBOX','CONT-20') THEN 120
                                    WHEN sih.Jenisarmada = 'CONT-40' THEN 150
                                    ELSE olf.std_Time_per_Dp
                                END
                            WHEN 'L' THEN 
                                CASE 
                                    WHEN sih.Jenisarmada IN ('FUSO','WINGBOX','CONT-20') THEN 120
                                    WHEN sih.Jenisarmada = 'CONT-40' THEN 150
                                    ELSE olf.std_Time_per_Dp
                                END
                            ELSE olf.std_Time_per_Dp
                        END
                    ELSE olf.std_Time_per_Dp
                END
            ) AS Standar_TAT_Calc,
            CASE 
                WHEN LEN(sih.TRANSNO) >= 7 AND SUBSTRING(sih.TRANSNO,7,1) = 'H' THEN 120
                WHEN SUBSTRING(sih.TRANSNO,7,1) = 'A' 
                     AND sih.Jenisarmada NOT IN ('FUSO','WINGBOX','CONT-20','CONT-40') THEN 60
                WHEN sih.Jenisarmada IN ('FUSO','WINGBOX','CONT-20') 
                     AND SUBSTRING(sih.TRANSNO,7,1) IN ('A','B','L') THEN 120
                WHEN sih.Jenisarmada = 'CONT-40' THEN 150
                ELSE olf.std_Time_per_Dp
            END AS std_Time_per_Dp_2,
            olf.std_UJP,
            CASE 
                WHEN SUBSTRING(sih.TRANSNO,7,1) IN ('A','D','X','H') THEN 1
                ELSE olf.std_droppoint
            END AS [std drop point],
            req.jalur,
            rdos.DropPoint,
            rdos.[Order],
            rdoh.rdo_no,
            rdoh.driverid,
            rdoh.drivername,
            rdoh.crew1id,
            rdoh.crew1name,
            marm.no_polisi,
            marm.kode_armada,
            rdod.[1] AS Checkin1,
            rdod.[2] AS Checkin2,
            rdod.[3] AS Checkin3,
            rdod.[4] AS Checkin4,
            rdod.[5] AS Checkin5,
            rdod.[6] AS Checkin6,
            rdod.[7] AS Checkin7,
            rdod.[8] AS Checkin8,
            rdod.[9] AS Checkin9,
            rdod.[10] AS Checkin10,
            rdod.[11] AS Checkin11,
            rdod.[12] AS Checkin12,
            rdod.[13] AS Checkin13,
            rdod.[14] AS Checkin14,
            rdod.[15] AS Checkin15,
            rdod.[16] AS Checkin16,
            rdod.[17] AS Checkin17,
            rdod.[18] AS Checkin18,
            rdod.[19] AS Checkin19,
            rdod.[20] AS Checkin20,
            ROW_NUMBER() OVER (PARTITION BY sih.TRANSNO ORDER BY sih.PlanDeliveryDate DESC) AS rn
        FROM Expediter.dbo.t_si_h sih
        LEFT JOIN Expediter.dbo.t_si_request req 
            ON sih.transno = req.requestid
        LEFT JOIN Expediter.dbo.t_rdo_h rdoh 
            ON sih.transno = rdoh.si_no
        LEFT JOIN RdoSI rdos
            ON rdoh.si_no = rdos.SI_NO
        LEFT JOIN arc_expediter.dbo.configtp_dp_olf olf
            ON req.jalur = olf.jalur
        LEFT JOIN Expediter.dbo.m_armada marm 
            ON sih.nopol = marm.no_polisi
        LEFT JOIN
        (
            SELECT 
                rdo_no,
                [1],[2],[3],[4],[5],
                [6],[7],[8],[9],[10],
                [11],[12],[13],[14],[15],
                [16],[17],[18],[19],[20]
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
                ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],
                 [11],[12],[13],[14],[15],[16],[17],[18],[19],[20])
            ) AS p
        ) rdod 
            ON rdoh.rdo_no = rdod.rdo_no
        WHERE sih.plandeliverydate BETWEEN @startdate AND @enddate
          AND (@site IS NULL OR EXISTS (SELECT 1 FROM #Sites s WHERE s.Site = sih.[site]))
          AND (@owner IS NULL OR EXISTS (SELECT 1 FROM #Owners o WHERE o.Owner = sih.[Owner]))
          AND NOT (sih.[Owner] = 'HCI' AND sih.[site] <> 'WMWHSE4')
          AND sih.[type] IN ('Internal','Pinjam Sisco')
    )
    SELECT *
    FROM MainResult
    WHERE rn = 1;

    DROP TABLE #Sites;
    DROP TABLE #Owners;
END
GO
