declare @startdate as varchar(20) ='2025-08-28'
declare @enddate as varchar(20)='2025-08-28'
declare @site as Varchar (20) = 'WMWHSE2'
declare @owner as varchar (20) = 'AHI'


select*from
(
	select TRANSNO,PlanDeliveryDate[site],[type],nopol,
	SUBSTRING(TRANSNO, 7, 1) AS TypeLC
	from Expediter.dbo.t_si_h where plandeliverydate between @startdate and @enddate
	and [site] = @site and [owner] = @owner
)sih
left join
(
	select requestid,jalur from Expediter.dbo.t_si_request
)req on sih.transno = req.requestid
left join
(
	select si_no,rdo_no,driverid,drivername,crew1id,crew1name from Expediter.dbo.t_rdo_h
)rdoh on sih.transno = rdoh.si_no
left join
(
	select no_polisi,kode_armada from Expediter.dbo.m_armada
)marm on sih.nopol = marm.no_polisi
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
) rdod ON rdoh.rdo_no = rdod.rdo_no