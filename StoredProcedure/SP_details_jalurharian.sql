EXEC dbo.usp_GetDeliveryReport 'WMWHSE2','2025-08-20','DC AHI JABABEKA'

exec sp_helptext 'dbo.usp_GetDeliveryReport'

EXEC dbo.usp_GetDeliveryReport 
    @whseid = 'WMWHSE2RTL', 
    @PlanDeliveryDate = '2025-08-21';

CREATE PROCEDURE dbo.usp_GetDeliveryReport
    @Site VARCHAR(50),
    @PlanDeliveryDate DATE
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        RDOH.KodeArmada + '-' + ISNULL(NOPOL,'') [ARMADA],
        TRANSNO [LC],
        SUBSTRING(TRANSNO, 7, 1) AS [type code],
        CASE SUBSTRING(TRANSNO, 7, 1)
            WHEN 'A' THEN 'STORE DK'
            WHEN 'C' THEN 'CUSTOMER'
            WHEN 'H' THEN 'HUB'
            WHEN 'X' THEN 'Other Delivery'
            WHEN 'B' THEN 'STORE LK'
            WHEN 'L' THEN 'LUAR KOTA'
            WHEN 'T' THEN 'TRANSIT LUAR KOTA'
            ELSE ''
        END AS [Type Pengiriman],
        LaneNoZyllem [LANE ZYLLEM],
        SHIPPINGLINE,
        CODE.Descr [Status LC],
        CODER.Descr [Status RDO],
        DriverId [NIK DRIVER],
        DriverName [DRIVER NAME],
        ROSTER.shiftCode + ' ' + ROSTER.shiftIn + '-' + ROSTER.shiftOut [Roster Driver],
        Crew1Id [NIK CO DRIVER],
        Crew1Name [CO DRIVER NAME],
        ROSTERC.shiftCode + ' ' + ROSTERC.shiftIn + '-' + ROSTERC.shiftOut [Roster Co Driver],
        rdosi.DropPoint,
        SA.[CheckOut DC],
        RDOD.Tiba_first,
        RDOD.selesai_first,
        RDOD2.Tiba_Last,
        RDOD2.selesai_Last,
        RDOE.[Tiba DC],
        -- Travel Time Berangkat (jam:menit)
        RIGHT('0' + CAST(DATEDIFF(MINUTE, SA.[CheckOut DC], RDOD.Tiba_first) / 60 AS VARCHAR),2) 
        + ':' + 
        RIGHT('0' + CAST(DATEDIFF(MINUTE, SA.[CheckOut DC], RDOD.Tiba_first) % 60 AS VARCHAR),2) 
        AS [Travel Time Berangkat],
        -- Travel Time Pulang
        RIGHT('0' + CAST(DATEDIFF(MINUTE, RDOD2.Selesai_Last, RDOE.[Tiba DC]) / 60 AS VARCHAR),2) 
        + ':' + 
        RIGHT('0' + CAST(DATEDIFF(MINUTE, RDOD2.Selesai_Last, RDOE.[Tiba DC]) % 60 AS VARCHAR),2) 
        AS [Travel Time Pulang]
    FROM
    (
        SELECT NOPOL, JENISARMADA, TRANSNO, LaneNoZyllem, SHIPPINGLINE, STATUS, PlanDeliveryDate
        FROM Expediter.dbo.t_si_h
        WHERE SITE = @Site 
          AND PlanDeliveryDate = @PlanDeliveryDate
    ) SIH
    LEFT JOIN (SELECT CODE,Descr FROM Expediter.dbo.t_code WHERE Type= 'SI') CODE
        ON SIH.STATUS = CODE.Code
    LEFT JOIN (SELECT SI_No,RDO_No,Status,DriverId,DriverName,Crew1Id,Crew1Name,KodeArmada FROM Expediter.dbo.t_RDO_h) RDOH
        ON SIH.TRANSNO = RDOH.SI_No
    LEFT JOIN (SELECT CODE,Descr FROM Expediter.dbo.t_code WHERE Type= 'RDO') CODER
        ON RDOH.Status = CODER.Code
    LEFT JOIN (SELECT empID,workDate, shiftCode,shiftIn,shiftOut FROM arc_expediter.dbo.PeoplePro_TM_ABS_Roster) ROSTER
        ON RDOH.DriverId = ROSTER.empID AND SIH.PlanDeliveryDate = CAST(ROSTER.workDate AS date)
    LEFT JOIN (SELECT empID,workDate, shiftCode, shiftIn, shiftOUT FROM arc_expediter.dbo.PeoplePro_TM_ABS_Roster) ROSTERC
        ON RDOH.Crew1Id = ROSTERC.empID AND SIH.PlanDeliveryDate = CAST(ROSTERC.workDate AS date)
    LEFT JOIN (
        SELECT SI_NO, COUNT(DISTINCT SEQUENCE) [DropPoint], COUNT(DISTINCT ORDERKEY) [Order] 
        FROM Expediter.dbo.t_rdo_si
        WHERE STATUS NOT IN (12,13) AND RTACTION NOT IN ('a','t')
        GROUP BY SI_NO
    ) rdosi
        ON sih.transno = rdosi.si_no
    LEFT JOIN (
        SELECT Reference_no, DATEADD(HOUR,7, Time_Checkin) Time_Checkin,
               DATEADD(HOUR,7, Time_Checkout) [CheckOut DC] 
        FROM [uat-wmsdb03].scprd.dbo.support_armada
    ) SA
        ON SIH.TRANSNO = SA.Reference_no
    LEFT JOIN (
        SELECT RDO_No, MIN(CheckIn) [Tiba_first], MIN(CheckOut) [selesai_first] 
        FROM Expediter.dbo.t_RDO_d 
        WHERE [Status] NOT IN (12,13) 
        GROUP BY RDO_No
    ) RDOD
        ON RDOH.RDO_No = RDOD.RDO_No
    LEFT JOIN (
        SELECT RDO_No, MAX(CheckIn) [Tiba_Last], MAX(CheckOut) [selesai_Last] 
        FROM Expediter.dbo.t_RDO_d 
        WHERE [Status] NOT IN (12,13) 
        GROUP BY RDO_No 
    ) RDOD2
        ON RDOH.RDO_No = RDOD2.RDO_No
    LEFT JOIN (
        SELECT RDO_No, MAX(CheckIn) [Tiba DC] 
        FROM Expediter.dbo.t_RDO_d 
        WHERE [Status] IN (13) 
        GROUP BY RDO_No 
    ) RDOE
        ON RDOH.RDO_No = RDOE.RDO_No;
END
GO
