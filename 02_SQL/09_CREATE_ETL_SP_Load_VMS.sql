USE MSP_BusinessDB;
GO

CREATE OR ALTER PROCEDURE etl.usp_Load_VMS
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @LoadTimestamp DATETIME2 = SYSDATETIME();

    /* VMS-Tabellen leeren
       Reihenfolge wegen Foreign Keys: erst abhängige Tabellen, dann Stammtabellen
    */
    DELETE FROM vms.WorkOrder;
    DELETE FROM vms.Interview;
    DELETE FROM vms.AnfrageKandidat;
    DELETE FROM vms.Anfrage;
    DELETE FROM vms.Kandidat;
    DELETE FROM vms.Lieferant;
    DELETE FROM vms.HiringManager;
    DELETE FROM vms.Kunde;

    /* Kunde */
    INSERT INTO vms.Kunde
    (
        KundeID,
        Kundenname
    )
    SELECT
        KundeID,
        Kundenname
    FROM cln.Kunde
    WHERE KundeID IS NOT NULL;

    INSERT INTO etl.LoadLog (EntityName, RowsLoaded, LoadTimestamp, Status)
    SELECT 'vms.Kunde', COUNT(*), @LoadTimestamp, 'SUCCESS'
    FROM vms.Kunde;

    /* HiringManager */
    INSERT INTO vms.HiringManager
    (
        HiringManagerID,
        KundeID,
        Vorname,
        Nachname,
        Abteilung
    )
    SELECT
        hm.HiringManagerID,
        hm.KundeID,
        hm.Vorname,
        hm.Nachname,
        hm.Abteilung
    FROM cln.HiringManager hm
    INNER JOIN vms.Kunde k
        ON hm.KundeID = k.KundeID
    WHERE hm.HiringManagerID IS NOT NULL;

    INSERT INTO etl.LoadLog (EntityName, RowsLoaded, LoadTimestamp, Status)
    SELECT 'vms.HiringManager', COUNT(*), @LoadTimestamp, 'SUCCESS'
    FROM vms.HiringManager;

    /* Lieferant */
    INSERT INTO vms.Lieferant
    (
        LieferantID,
        Lieferantenname
    )
    SELECT
        LieferantID,
        Lieferantenname
    FROM cln.Lieferant
    WHERE LieferantID IS NOT NULL;

    INSERT INTO etl.LoadLog (EntityName, RowsLoaded, LoadTimestamp, Status)
    SELECT 'vms.Lieferant', COUNT(*), @LoadTimestamp, 'SUCCESS'
    FROM vms.Lieferant;

    /* Kandidat */
    INSERT INTO vms.Kandidat
    (
        KandidatID,
        LieferantID,
        Vorname,
        Nachname
    )
    SELECT
        ka.KandidatID,
        ka.LieferantID,
        ka.Vorname,
        ka.Nachname
    FROM cln.Kandidat ka
    INNER JOIN vms.Lieferant l
        ON ka.LieferantID = l.LieferantID
    WHERE ka.KandidatID IS NOT NULL;

    INSERT INTO etl.LoadLog (EntityName, RowsLoaded, LoadTimestamp, Status)
    SELECT 'vms.Kandidat', COUNT(*), @LoadTimestamp, 'SUCCESS'
    FROM vms.Kandidat;

    /* Anfrage */
    INSERT INTO vms.Anfrage
    (
        AnfrageID,
        HiringManagerID,
        Titel,
        AnzahlPositionen,
        MaxTagessatz,
        VersendetAm,
        GewuenschterStart,
        Status
    )
    SELECT
        a.AnfrageID,
        a.HiringManagerID,
        a.Titel,
        a.AnzahlPositionen,
        a.MaxTagessatz,
        a.VersendetAm,
        a.GewuenschterStart,
        a.Status
    FROM cln.Anfrage a
    INNER JOIN vms.HiringManager hm
        ON a.HiringManagerID = hm.HiringManagerID
    WHERE a.AnfrageID IS NOT NULL;

    INSERT INTO etl.LoadLog (EntityName, RowsLoaded, LoadTimestamp, Status)
    SELECT 'vms.Anfrage', COUNT(*), @LoadTimestamp, 'SUCCESS'
    FROM vms.Anfrage;

    /* AnfrageKandidat
       Deduplizierung, weil die Kombination AnfrageID + KandidatID im VMS Primary Key ist.
    */
    ;WITH AK_Dedup AS
    (
        SELECT
            ak.AnfrageID,
            ak.KandidatID,
            ak.Uebermittlungsdatum,
            ak.Kandidatenstatus,
            ak.TagessatzAngebot,
            ROW_NUMBER() OVER (
                PARTITION BY ak.AnfrageID, ak.KandidatID
                ORDER BY ak.Uebermittlungsdatum DESC
            ) AS rn
        FROM cln.AnfrageKandidat ak
        INNER JOIN vms.Anfrage a
            ON ak.AnfrageID = a.AnfrageID
        INNER JOIN vms.Kandidat k
            ON ak.KandidatID = k.KandidatID
        WHERE ak.AnfrageID IS NOT NULL
          AND ak.KandidatID IS NOT NULL
    )
    INSERT INTO vms.AnfrageKandidat
    (
        AnfrageID,
        KandidatID,
        Uebermittlungsdatum,
        Kandidatenstatus,
        TagessatzAngebot
    )
    SELECT
        AnfrageID,
        KandidatID,
        Uebermittlungsdatum,
        Kandidatenstatus,
        TagessatzAngebot
    FROM AK_Dedup
    WHERE rn = 1;

    INSERT INTO etl.LoadLog (EntityName, RowsLoaded, LoadTimestamp, Status)
    SELECT 'vms.AnfrageKandidat', COUNT(*), @LoadTimestamp, 'SUCCESS'
    FROM vms.AnfrageKandidat;

    /* Interview
       PK: HiringManagerID + KandidatID + Interviewdatum
    */
    ;WITH Interview_Dedup AS
    (
        SELECT
            i.HiringManagerID,
            i.KandidatID,
            i.Interviewdatum,
            i.Interviewergebnis,
            ROW_NUMBER() OVER (
                PARTITION BY i.HiringManagerID, i.KandidatID, i.Interviewdatum
                ORDER BY i.Interviewdatum DESC
            ) AS rn
        FROM cln.Interview i
        INNER JOIN vms.HiringManager hm
            ON i.HiringManagerID = hm.HiringManagerID
        INNER JOIN vms.Kandidat k
            ON i.KandidatID = k.KandidatID
        WHERE i.HiringManagerID IS NOT NULL
          AND i.KandidatID IS NOT NULL
          AND i.Interviewdatum IS NOT NULL
    )
    INSERT INTO vms.Interview
    (
        HiringManagerID,
        KandidatID,
        Interviewdatum,
        Interviewergebnis
    )
    SELECT
        HiringManagerID,
        KandidatID,
        Interviewdatum,
        Interviewergebnis
    FROM Interview_Dedup
    WHERE rn = 1;

    INSERT INTO etl.LoadLog (EntityName, RowsLoaded, LoadTimestamp, Status)
    SELECT 'vms.Interview', COUNT(*), @LoadTimestamp, 'SUCCESS'
    FROM vms.Interview;

    /* WorkOrder */
    INSERT INTO vms.WorkOrder
    (
        WorkOrderID,
        AnfrageID,
        KandidatID,
        HiringManagerID,
        LieferantID,
        ErstelltAm,
        Startdatum,
        TagessatzFinal,
        Status
    )
    SELECT
        wo.WorkOrderID,
        wo.AnfrageID,
        wo.KandidatID,
        wo.HiringManagerID,
        wo.LieferantID,
        wo.ErstelltAm,
        wo.Startdatum,
        wo.TagessatzFinal,
        wo.Status
    FROM cln.WorkOrder wo
    INNER JOIN vms.Anfrage a
        ON wo.AnfrageID = a.AnfrageID
    INNER JOIN vms.Kandidat k
        ON wo.KandidatID = k.KandidatID
    INNER JOIN vms.HiringManager hm
        ON wo.HiringManagerID = hm.HiringManagerID
    INNER JOIN vms.Lieferant l
        ON wo.LieferantID = l.LieferantID
    WHERE wo.WorkOrderID IS NOT NULL;

    INSERT INTO etl.LoadLog (EntityName, RowsLoaded, LoadTimestamp, Status)
    SELECT 'vms.WorkOrder', COUNT(*), @LoadTimestamp, 'SUCCESS'
    FROM vms.WorkOrder;

END;
GO