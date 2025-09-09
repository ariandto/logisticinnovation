Exec [dbo].[Daily_Report_Monitoring_Driver] '2025-06-24','2025-06-24','WMWHSE4RTL','DC INFORMA JABABEKA'

Exec [dbo].[Daily_Report_Monitoring_Driver] '2025-08-20','2028-08-20','WMWHSE2','AHI JABABEKA'

sp_helptext 'daily_report_monitoring_driver'

EXEC [udsp_Get_Data] 'Get Zone DC 2','DC INFORMA JABABEKA','WMWHSE4RTL','NDC','ALL'


EXEC [udsp_Get_Data] 'Get Zone DC 2','DC INFORMA JABABEKA','WMWHSE4RTL','NDC','ALL'

sp_helptext 'udsp_Get_Data'

EXEC [udsp_Get_Data] 'Get Zone DC 2','DC INFORMA JABABEKA','KLS','NDC','ALL'


EXEC [dbo].[Daily_Report_Transport]

select * from arc_expediter.[dbo].[ConfigTP_DP_OLF]