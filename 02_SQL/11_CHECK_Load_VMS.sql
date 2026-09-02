SELECT * 
FROM etl.LoadLog
ORDER BY LoadID DESC;

SELECT COUNT(*) AS Kunde FROM vms.Kunde;
SELECT COUNT(*) AS HiringManager FROM vms.HiringManager;
SELECT COUNT(*) AS Lieferant FROM vms.Lieferant;
SELECT COUNT(*) AS Kandidat FROM vms.Kandidat;
SELECT COUNT(*) AS Anfrage FROM vms.Anfrage;
SELECT COUNT(*) AS AnfrageKandidat FROM vms.AnfrageKandidat;
SELECT COUNT(*) AS Interview FROM vms.Interview;
SELECT COUNT(*) AS WorkOrder FROM vms.WorkOrder;