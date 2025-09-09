
EXEC spMonitoringPengiriman;


EXEC spMonitoringPengiriman 
    @startdate = '2025-08-28',
    @enddate = '2025-08-28',
    @site = 'WMWHSE2',
    @owner = 'FBI';

EXEC spMonitoringPengiriman 
    @startdate = '2025-08-28',
    @enddate = '2025-08-28',
    @owner = 'HCI';

-- Hanya menentukan tanggal saja
EXEC spMonitoringPengiriman 
    @startdate = '2025-08-28',
    @enddate = '2025-08-28';