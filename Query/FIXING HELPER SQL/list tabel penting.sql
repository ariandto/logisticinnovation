SELECT TOP 100 * FROM Expediter.dbo.t_si_h where SITE='WMWHSE2' AND PlanDeliveryDate='2025-08-26' -- tabel header LC

SELECT TOP 100 * FROM Expediter.dbo.t_RDO_D
SELECT TOP 100 * FROM Expediter.dbo.t_RDO_SI
SELECT TOP 100 * FROM Expediter.dbo.t_RDO_H 
SELECT TOP 100 * FROM Expediter.dbo.m_RDOStatus
SELECT TOP 100 * FROM Expediter.dbo.m_RDOReason
SELECT TOP 100 * FROM Expediter.dbo.m_RDOFuel
SELECT TOP 100 * FROM Expediter.dbo.m_RDOConfig
SELECT TOP 100 * FROM Expediter.dbo.m_RDOStopType



SELECT TOP 100 * FROM Expediter.dbo.t_si_h  [Owner]

SELECT TOP 100 * FROM Expediter.dbo.t_Jalur

SELECT TOP 100 * FROM Expediter.dbo.t_si_request WHERE SITE='WMWHSE4'

select * from arc_expediter.dbo.configtp_dp_olf where whseid='WMWHSE2'

select top 200 *  from [uat-wmsdb03].scprd.dbo.support_armada

SELECT TOP 100 * FROM Expediter.dbo.m_Armada

select top 100 * from M_Asset_Armada

Select * from arc_expediter.dbo.roster



SELECT DISTINCT [Owner] FROM Expediter.dbo.t_si_h  WHERE [site] IN ('WMWHSE2')  AND [Owner] IN ('AHI','TGI','FBI') 
UNION ALL 
SELECT DISTINCT [Owner] FROM Expediter.dbo.t_si_h WHERE [site] IN ('WMWHSE4') AND [Owner] IN ('HCI') ORDER BY [Owner];


--select*from [10.1.32.51].expediterindustrial.dbo.t_si_h where transno ='250901C039'

--select*from scprd.dbo.support_armada where reference_no ='250901C039'

--UPDATE [10.1.32.51].expediterindustrial.dbo.t_si_h  SET [Type]='INTERNAL'  where transno ='250901C039'

--update [10.1.32.51].Expediter.dbo.t_rdo_H set Status=4 where RDO_No='H014-2509-000155'