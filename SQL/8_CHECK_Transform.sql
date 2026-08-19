SELECT * FROM etl.LoadLog ORDER BY LoadID DESC;

SELECT TOP 10 * FROM cln.Anfrage;
SELECT TOP 10 * FROM cln.AnfrageKandidat;
SELECT TOP 10 * FROM cln.WorkOrder;

SELECT COUNT(*) FROM stg.Kunde;
SELECT COUNT(*) FROM cln.Kunde;

SELECT COUNT(*) FROM stg.Kandidat;
SELECT COUNT(*) FROM cln.Kandidat;

SELECT COUNT(*) FROM stg.Anfrage;
SELECT COUNT(*) FROM cln.Anfrage;