select nik,nama,JOBDESK,Facility,roster.[Date]as [Absen Date],[Roster],ShiftCode,ShiftName,ShiftIn[Roster In],ShiftOut[Roster Out]
,AbsDateIn[Absen Masuk],AbsDateOut[Absen Pulang],AbsAtdInName[Desc Masuk],AbsAtdOutName[Desc Keluar]
into #temp
from
(
	SELECT 
		[Nik], [Nama], [Jobdesk], [Facility], [Bulan], [Tahun], [Tanggal], [ROSTER], [Adddate], [editdate]
		,TAHUN+'-'+BULAN+'-'+Tanggal [Date]
	FROM (
		SELECT 
			[Nik], [Nama], [Jobdesk], [Facility], [Bulan], [Tahun], [Adddate], [editdate], 
			[01], [02], [03], [04], [05], [06], [07], [08], [09], [10], 
			[11], [12], [13], [14], [15], [16], [17], [18], [19], [20], 
			[21], [22], [23], [24], [25], [26], [27], [28], [29], [30], [31]
		FROM 
			[arc_expediter].[dbo].[Roster]
	) AS RosterTable 
	UNPIVOT (
		[ROSTER] FOR [Tanggal] IN ([01], [02], [03], [04], [05], [06], [07], [08], [09], [10], 
									[11], [12], [13], [14], [15], [16], [17], [18], [19], [20], 
									[21], [22], [23], [24], [25], [26], [27], [28], [29], [30], [31])
	) AS UnpivotedTable 
	WHERE  TAHUN = '2025' AND BULAN = '09' AND TANGGAL BETWEEN '08' AND '08' AND Facility IN ('AHI JABABEKA') 
)roster
left join
(
	select empID,absDate,ShiftCode,ShiftName,ShiftIn,ShiftOut,AbsDateIn,AbsAtdInName,AbsDateOut,AbsAtdOutName 
	from arc_expediter.dbo.PeoplePro_TM_ABS_Absensi
)absn on roster.nik = absn.empID and roster.[Date] = cast (absn.absDate as date)
order by nik

select nik,nama,JOBDESK,Facility,[Absen Date],[Roster],ShiftCode,ShiftName,[Roster In],[Roster Out],[Absen Masuk],[Absen Pulang],[Desc Masuk],[Desc Keluar],
DATEDIFF(MINUTE,([Absen Date]+' '+[Roster Out]),[Absen Pulang]),
case when DATEDIFF(MINUTE,([Absen Date]+' '+[Roster Out]),[Absen Pulang]) < 0 then
''
else
RIGHT('0' + CAST(DATEDIFF(MINUTE, ([Absen Date] + ' ' + [Roster Out]), [Absen Pulang]) / 60 AS VARCHAR), 2) 
+ ':' + 
RIGHT('0' + CAST(DATEDIFF(MINUTE, ([Absen Date] + ' ' + [Roster Out]), [Absen Pulang]) % 60 AS VARCHAR), 2) 
end
    AS SelisihJamMenit
 from #temp