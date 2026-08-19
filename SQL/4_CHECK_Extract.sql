SELECT COUNT(*) AS Kunden FROM stg.Kunde;
SELECT COUNT(*) AS HiringManager FROM stg.HiringManager;
SELECT COUNT(*) AS Lieferanten FROM stg.Lieferant;
SELECT COUNT(*) AS Kandidaten FROM stg.Kandidat;
SELECT COUNT(*) AS Anfragen FROM stg.Anfrage;
SELECT COUNT(*) AS AnfrageKandidat FROM stg.AnfrageKandidat;
SELECT COUNT(*) AS Interviews FROM stg.Interview;
SELECT COUNT(*) AS WorkOrders FROM stg.WorkOrder;

-------

SELECT TOP 10 *
FROM stg.Kunde;

-------

SELECT *
FROM etl.LoadLog
ORDER BY LoadID ASC;