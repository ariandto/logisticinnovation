;WITH RosterData AS (
    SELECT 
        nik,
        NAMA,
        JOBDESK,
        Facility,
        TAHUN,
        BULAN,
        CAST([Day] AS INT) AS Tanggal,
        Tugas
    FROM [arc_expediter].[dbo].[Roster]
    UNPIVOT (
        Tugas FOR [Day] IN ([01],[02],[03],[04],[05],[06],[07],[08],[09],[10],
                            [11],[12],[13],[14],[15],[16],[17],[18],[19],[20],
                            [21],[22],[23],[24],[25],[26],[27],[28],[29],[30],[31])
    ) AS unpvt
)
SELECT 
    r.nik,
    r.NAMA,
    r.JOBDESK,
    r.Facility,
    r.TAHUN,
    r.BULAN,
    r.Tanggal,
    ISNULL(a.ShiftCode, '-')  AS ShiftCode,
    ISNULL(a.ShiftIn, '-')    AS ShiftIn,
    ISNULL(a.ShiftOut, '-')   AS ShiftOut,
    CASE 
        WHEN a.AbsDateOut IS NOT NULL AND a.ShiftOut IS NOT NULL
        THEN 
            CASE 
                WHEN a.AbsDateOut > DATEADD(MINUTE, 0, 
                        CONVERT(DATETIME, CONVERT(DATE, a.AbsDateIn)) + CAST(a.ShiftOut AS DATETIME))
                THEN 
                    CAST(DATEDIFF(MINUTE, 
                         CONVERT(DATETIME, CONVERT(DATE, a.AbsDateIn)) + CAST(a.ShiftOut AS DATETIME), 
                         a.AbsDateOut) / 60 AS VARCHAR) + ' jam ' +
                    CAST(DATEDIFF(MINUTE, 
                         CONVERT(DATETIME, CONVERT(DATE, a.AbsDateIn)) + CAST(a.ShiftOut AS DATETIME), 
                         a.AbsDateOut) % 60 AS VARCHAR) + ' menit'
                ELSE '-'
            END
        ELSE '-'
    END AS LamaLembur,
    ISNULL(CONVERT(VARCHAR(19), a.AbsDateIn, 120), '-')  AS AbsDateIn,
    ISNULL(CONVERT(VARCHAR(19), a.AbsDateOut, 120), '-') AS AbsDateOut,
    CASE 
        WHEN a.AbsDateIn IS NOT NULL AND a.AbsDateOut IS NOT NULL 
        THEN 
            CAST(DATEDIFF(MINUTE, a.AbsDateIn, a.AbsDateOut) / 60 AS VARCHAR) + ' jam ' +
            CAST(DATEDIFF(MINUTE, a.AbsDateIn, a.AbsDateOut) % 60 AS VARCHAR) + ' menit'
        ELSE '-'
    END AS LamaKerja,
    ISNULL(a.AbsAtdInCode, '-') AS AbsAtdInCode
FROM RosterData r
LEFT JOIN [arc_expediter].[dbo].[PeoplePro_TM_ABS_Absensi] a
    ON a.empID = r.nik
   AND CAST(a.absDate AS DATE) = CONVERT(DATE, CONCAT(r.TAHUN, '-', r.BULAN, '-', r.Tanggal))
WHERE r.TAHUN   = YEAR(GETDATE())
  AND r.BULAN   = MONTH(GETDATE())
  AND r.Tanggal = '8'
ORDER BY r.nik;
