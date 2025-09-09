DECLARE @PlanDeliveryDate DATE = '2025-08-27';
DECLARE @SITE  VARCHAR(50) = 'WMWHSE2';
DECLARE @Owner VARCHAR(50) = 'AHI';

SELECT 
    sih.TRANSNO,
    (arm.kode_armada + '-' + sih.NOPOL) AS [Armada],
    -- (sih.NOPOL + '-' + arm.kode_armada) AS [Armada],
    sih.JENISARMADA,
    rdoh.DriverId   AS [Nik Driver],
    rdoh.DriverName AS [Nama Driver],
    rdoh.Crew1Id    AS [Nik Co Driver],
    rdoh.Crew1Name  AS [Co-Driver Name],
    sireq.Jalur,
    sih.Type,
    @PlanDeliveryDate AS PlanDeliveryDate,
    SUBSTRING(sih.TRANSNO, 7, 1) AS TypeLC,
    sih.[Owner],
    sih.Site,
    rdod.MaxCheckIn
FROM Expediter.dbo.t_si_h sih
LEFT JOIN Expediter.dbo.t_RDO_H rdoh
    ON sih.TRANSNO = rdoh.SI_No
LEFT JOIN (
    SELECT 
        RDO_No,
        MAX(CheckIn) AS MaxCheckIn
    FROM Expediter.dbo.t_RDO_d
    WHERE [Status] NOT IN (12,13)
    GROUP BY RDO_No
) rdod
    ON rdoh.SI_No = rdod.RDO_No
LEFT JOIN Expediter.dbo.t_si_request sireq
    ON sih.TRANSNO = sireq.TRANSNO
LEFT JOIN Expediter.dbo.m_Armada arm
    ON sih.NOPOL = arm.no_polisi
WHERE sih.Site  = @SITE
  AND sih.Owner = @Owner
  AND PLANDELIVERYDATE = @PlanDeliveryDate;
