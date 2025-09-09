---NO	ARMADA	NOMOR POLISI	TYPE ARMADA	Nomer LC	LINE ZYLLEM		STATUS LC	STATUS ERDO	NIK	DRIVER	ROSTER	NIK	CO- DRIVER	ROSTER

--SELECT TOP 10 NOPOL, JENISARMADA, TRANSNO, LaneNoZyllem, STATUS FROM Expediter.dbo.t_si_h
SELECT top 100 * FROM Expediter.dbo.t_RDO_h  where SI_No ='250817H033'
SELECT TOP 100 * FROM Expediter.dbo.t_RDO_SI
select TOP 100 *from [uat-wmsdb03].scprd.dbo.support_armada
SELECT top 100 * FROM Expediter.dbo.t_RDO_d where RDO_No ='A001-2508-001247' order by detno 


SELECT top 100 * FROM Expediter.dbo.t_RDO_d

SELECT RDO_No,min(CheckIn)[Tiba],min(CheckOut)selesai 
FROM Expediter.dbo.t_RDO_d 
where RDO_No ='A001-2508-001247' and [Status] not in (12,13) order by detno
group by RDO_No 

--250817H033
-SELECT top 100 * FROM Expediter.dbo.t_RDO_h
--SELECT TOP 100 * FROM Expediter.dbo.t_RDO_SI
--SELECT top 100 * FROM Expediter.dbo.t_RDO_d order by DetNo DESC



--SELECT TOP 100 * FROM Expediter.dbo.t_si_h
--SELECT TOP 100 * FROM Expediter.dbo.t_code
--SELECT top 100 * FROM Expediter.dbo.t_RDO_h
--SELECT TOP 100 * FROM arc_expediter.dbo.PeoplePro_TM_ABS_Roster
--SELECT TOP 100 * FROM Expediter.dbo.t_RDO_SI
--select TOP 100 *from [uat-wmsdb03].scprd.dbo.support_armada
--SELECT top 100 * FROM Expediter.dbo.t_RDO_d

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
    Crew1Name [ CO DRIVER NAME],
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
	--TIME TRAVEL PULANG
	RIGHT('0' + CAST(DATEDIFF(MINUTE, RDOD2.Selesai_Last, RDOE.[Tiba DC]) / 60 AS VARCHAR),2) 
    + ':' + 
    RIGHT('0' + CAST(DATEDIFF(MINUTE, RDOD2.Selesai_Last, RDOE.[Tiba DC]) % 60 AS VARCHAR),2) 
    AS [Travel Time Pulang]
	--select*
FROM
(
SELECT  NOPOL, JENISARMADA, TRANSNO, LaneNoZyllem,SHIPPINGLINE,STATUS,PlanDeliveryDate FROM Expediter.dbo.t_si_h
WHERE SITE = 'WMWHSE2' AND PlanDeliveryDate = '2025-08-20'
)SIH
LEFT JOIN
(
	SELECT CODE,Descr FROM Expediter.dbo.t_code WHERE Type= 'SI' 
)CODE
ON SIH.STATUS = CODE.Code
LEFT JOIN
( 
	SELECT SI_No,RDO_No,Status,DriverId,DriverName,Crew1Id,Crew1Name,KodeArmada FROM Expediter.dbo.t_RDO_h 
)RDOH ON SIH.TRANSNO = RDOH.SI_No
 LEFT JOIN
(
	SELECT CODE,Descr FROM Expediter.dbo.t_code WHERE Type= 'RDO' 
)CODER ON RDOH.Status = CODER.Code
LEFT JOIN
(
	SELECT empID,workDate, shiftCode,shiftIn,shiftOut FROM arc_expediter.dbo.PeoplePro_TM_ABS_Roster
)ROSTER ON RDOH.DriverId = ROSTER.empID AND SIH.PlanDeliveryDate = CAST(ROSTER.workDate AS date)
LEFT JOIN
(
  SELECT empID,workDate, shiftCode, shiftIn, shiftOUT FROM arc_expediter.dbo.PeoplePro_TM_ABS_Roster
) ROSTERC ON RDOH.Crew1Id = ROSTERC.empID AND SIH.PlanDeliveryDate = CAST(ROSTERC.workDate AS date)
LEFT JOIN
(
select SI_NO,count (distinct SEQUENCE)[DropPoint],count(distinct ORDERKEY)[Order] 
	from Expediter.dbo.t_rdo_si
	where STATUS not in (12,13) and RTACTION not in ('a','t')
	group by SI_NO
)rdosi
ON sih.transno = rdosi.si_no
LEFT JOIN
(
	select Reference_no, DATEADD(HOUR,7, Time_Checkin)Time_Checkin,DATEADD(HOUR,7, Time_Checkout) [CheckOut DC] from [uat-wmsdb03].scprd.dbo.support_armada
)SA
ON SIH.TRANSNO = SA.Reference_no
LEFT JOIN
(
	SELECT RDO_No,min(CheckIn)[Tiba_first],min(CheckOut)[selesai_first] FROM Expediter.dbo.t_RDO_d where [Status] not in (12,13) 
group by RDO_No
)RDOD
ON RDOH.RDO_No = RDOD.RDO_No
LEFT JOIN
(
	SELECT RDO_No,max(CheckIn)[Tiba_Last],max(CheckOut)[selesai_Last] FROM Expediter.dbo.t_RDO_d where [Status] not in (12,13) 
group by RDO_No 
)RDOD2 --JAM BONGKAR TERAKHIR
ON RDOH.RDO_No = RDOD2.RDO_No
LEFT JOIN
(
	SELECT RDO_No, max (CheckIn) [Tiba DC] FROM Expediter.dbo.t_RDO_d where [Status] in (13) group by RDO_No 
)RDOE
ON RDOH.RDO_No = RDOE.RDO_No








														