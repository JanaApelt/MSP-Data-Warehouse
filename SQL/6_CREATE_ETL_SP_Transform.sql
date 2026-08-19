USE MSP_BusinessDB;
GO

CREATE OR ALTER PROCEDURE etl.usp_Transform_Data
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CleanTimestamp DATETIME2 = SYSDATETIME();

    TRUNCATE TABLE cln.WorkOrder;
    TRUNCATE TABLE cln.Interview;
    TRUNCATE TABLE cln.AnfrageKandidat;
    TRUNCATE TABLE cln.Anfrage;
    TRUNCATE TABLE cln.Kandidat;
    TRUNCATE TABLE cln.Lieferant;
    TRUNCATE TABLE cln.HiringManager;
    TRUNCATE TABLE cln.Kunde;

    /* Kunde */
    INSERT INTO cln.Kunde (KundeID, Kundenname)
    SELECT
        TRY_CAST(KundeID AS INT),
        NULLIF(TRIM(Kundenname), '')
    FROM stg.Kunde;

    INSERT INTO etl.LoadLog (EntityName, RowsLoaded, LoadTimestamp, Status)
    SELECT 'cln.Kunde', COUNT(*), @CleanTimestamp, 'SUCCESS'
    FROM cln.Kunde;

    /* Hiring Manager */
    INSERT INTO cln.HiringManager
    (
        HiringManagerID,
        KundeID,
        Vorname,
        Nachname,
        Abteilung
    )
    SELECT
        TRY_CAST(HiringManagerID AS INT),
        TRY_CAST(KundeID AS INT),
        NULLIF(TRIM(Vorname), ''),
        NULLIF(TRIM(Nachname), ''),
        NULLIF(TRIM(Abteilung), '')
    FROM stg.HiringManager;

    INSERT INTO etl.LoadLog (EntityName, RowsLoaded, LoadTimestamp, Status)
    SELECT 'cln.HiringManager', COUNT(*), @CleanTimestamp, 'SUCCESS'
    FROM cln.HiringManager;

    /* Lieferant */
    INSERT INTO cln.Lieferant
    (
        LieferantID,
        Lieferantenname
    )
    SELECT
        TRY_CAST(LieferantID AS INT),
        NULLIF(TRIM(Lieferantenname), '')
    FROM stg.Lieferant;

    INSERT INTO etl.LoadLog (EntityName, RowsLoaded, LoadTimestamp, Status)
    SELECT 'cln.Lieferant', COUNT(*), @CleanTimestamp, 'SUCCESS'
    FROM cln.Lieferant;

    /* Kandidat */
    INSERT INTO cln.Kandidat
    (
        KandidatID,
        LieferantID,
        Vorname,
        Nachname
    )
    SELECT
        TRY_CAST(KandidatID AS INT),
        TRY_CAST(LieferantID AS INT),
        NULLIF(TRIM(Vorname), ''),
        COALESCE(NULLIF(TRIM(Nachname), ''), 'Unbekannt')
    FROM stg.Kandidat;

    INSERT INTO etl.LoadLog (EntityName, RowsLoaded, LoadTimestamp, Status)
    SELECT 'cln.Kandidat', COUNT(*), @CleanTimestamp, 'SUCCESS'
    FROM cln.Kandidat;

    /* Anfrage */
    INSERT INTO cln.Anfrage
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
        TRY_CAST(AnfrageID AS INT),
        TRY_CAST(HiringManagerID AS INT),
        NULLIF(TRIM(Titel), ''),
        TRY_CAST(AnzahlPositionen AS INT),

        TRY_CAST(
            REPLACE(
                REPLACE(
                    REPLACE(
                        REPLACE(
                            REPLACE(NULLIF(TRIM(MaxTagessatz), ''), 'EUR', ''),
                        '€', ''),
                    '$', ''),
                ' ', ''),
            ',', '.')
        AS DECIMAL(8,2)),

        COALESCE(
            TRY_CONVERT(DATETIME2, NULLIF(TRIM(VersendetAm), ''), 23),
            TRY_CONVERT(DATETIME2, NULLIF(TRIM(VersendetAm), ''), 104),
            TRY_CONVERT(DATETIME2, NULLIF(TRIM(VersendetAm), ''), 111),
            TRY_CONVERT(DATETIME2, NULLIF(TRIM(VersendetAm), ''), 101)
        ),

        COALESCE(
            TRY_CONVERT(DATETIME2, NULLIF(TRIM(GewuenschterStart), ''), 23),
            TRY_CONVERT(DATETIME2, NULLIF(TRIM(GewuenschterStart), ''), 104),
            TRY_CONVERT(DATETIME2, NULLIF(TRIM(GewuenschterStart), ''), 111),
            TRY_CONVERT(DATETIME2, NULLIF(TRIM(GewuenschterStart), ''), 101)
        ),

        CASE LOWER(TRIM(Status))
            WHEN 'open' THEN 'open'
            WHEN 'closed' THEN 'closed'
            ELSE NULLIF(LOWER(TRIM(Status)), '')
        END
    FROM stg.Anfrage;

    INSERT INTO etl.LoadLog (EntityName, RowsLoaded, LoadTimestamp, Status)
    SELECT 'cln.Anfrage', COUNT(*), @CleanTimestamp, 'SUCCESS'
    FROM cln.Anfrage;

    /* AnfrageKandidat */
    INSERT INTO cln.AnfrageKandidat
    (
        AnfrageID,
        KandidatID,
        Uebermittlungsdatum,
        Kandidatenstatus,
        TagessatzAngebot
    )
    SELECT
        TRY_CAST(AnfrageID AS INT),
        TRY_CAST(KandidatID AS INT),

        COALESCE(
            TRY_CONVERT(DATETIME2, NULLIF(TRIM(Uebermittlungsdatum), ''), 23),
            TRY_CONVERT(DATETIME2, NULLIF(TRIM(Uebermittlungsdatum), ''), 104),
            TRY_CONVERT(DATETIME2, NULLIF(TRIM(Uebermittlungsdatum), ''), 111),
            TRY_CONVERT(DATETIME2, NULLIF(TRIM(Uebermittlungsdatum), ''), 101)
        ),

        CASE LOWER(TRIM(Kandidatenstatus))
            WHEN 'shortlisted' THEN 'shortlisted'
            WHEN 'interviewed' THEN 'interviewed'
            WHEN 'selected' THEN 'selected'
            WHEN 'rejected' THEN 'rejected'
            WHEN 'zurückgezogen' THEN 'zurückgezogen'
            WHEN 'übermittelt' THEN 'übermittelt'
            ELSE NULLIF(LOWER(TRIM(Kandidatenstatus)), '')
        END,

        TRY_CAST(
            REPLACE(
                REPLACE(
                    REPLACE(
                        REPLACE(
                            REPLACE(NULLIF(TRIM(TagessatzAngebot), ''), 'EUR', ''),
                        '€', ''),
                    '$', ''),
                ' ', ''),
            ',', '.')
        AS DECIMAL(8,2))
    FROM stg.AnfrageKandidat;

    INSERT INTO etl.LoadLog (EntityName, RowsLoaded, LoadTimestamp, Status)
    SELECT 'cln.AnfrageKandidat', COUNT(*), @CleanTimestamp, 'SUCCESS'
    FROM cln.AnfrageKandidat;

    /* Interview */
    INSERT INTO cln.Interview
    (
        HiringManagerID,
        KandidatID,
        Interviewdatum,
        Interviewergebnis
    )
    SELECT
        TRY_CAST(HiringManagerID AS INT),
        TRY_CAST(KandidatID AS INT),

        COALESCE(
            TRY_CONVERT(DATETIME2, NULLIF(TRIM(Interviewdatum), ''), 23),
            TRY_CONVERT(DATETIME2, NULLIF(TRIM(Interviewdatum), ''), 104),
            TRY_CONVERT(DATETIME2, NULLIF(TRIM(Interviewdatum), ''), 111),
            TRY_CONVERT(DATETIME2, NULLIF(TRIM(Interviewdatum), ''), 101)
        ),

        CASE LOWER(TRIM(Interviewergebnis))
            WHEN 'bestanden' THEN 'bestanden'
            WHEN 'abgelehnt' THEN 'abgelehnt'
            WHEN 'pending' THEN 'pending'
            ELSE NULLIF(LOWER(TRIM(Interviewergebnis)), '')
        END
    FROM stg.Interview;

    INSERT INTO etl.LoadLog (EntityName, RowsLoaded, LoadTimestamp, Status)
    SELECT 'cln.Interview', COUNT(*), @CleanTimestamp, 'SUCCESS'
    FROM cln.Interview;

    /* WorkOrder */
    INSERT INTO cln.WorkOrder
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
        TRY_CAST(WorkOrderID AS INT),
        TRY_CAST(AnfrageID AS INT),
        TRY_CAST(KandidatID AS INT),
        TRY_CAST(HiringManagerID AS INT),
        TRY_CAST(LieferantID AS INT),

        COALESCE(
            TRY_CONVERT(DATETIME2, NULLIF(TRIM(ErstelltAm), ''), 23),
            TRY_CONVERT(DATETIME2, NULLIF(TRIM(ErstelltAm), ''), 104),
            TRY_CONVERT(DATETIME2, NULLIF(TRIM(ErstelltAm), ''), 111),
            TRY_CONVERT(DATETIME2, NULLIF(TRIM(ErstelltAm), ''), 101)
        ),

        COALESCE(
            TRY_CONVERT(DATETIME2, NULLIF(TRIM(Startdatum), ''), 23),
            TRY_CONVERT(DATETIME2, NULLIF(TRIM(Startdatum), ''), 104),
            TRY_CONVERT(DATETIME2, NULLIF(TRIM(Startdatum), ''), 111),
            TRY_CONVERT(DATETIME2, NULLIF(TRIM(Startdatum), ''), 101)
        ),

        TRY_CAST(
            REPLACE(
                REPLACE(
                    REPLACE(
                        REPLACE(
                            REPLACE(NULLIF(TRIM(TagessatzFinal), ''), 'EUR', ''),
                        '€', ''),
                    '$', ''),
                ' ', ''),
            ',', '.')
        AS DECIMAL(8,2)),

        CASE LOWER(TRIM(Status))
            WHEN 'aktiv' THEN 'aktiv'
            WHEN 'active' THEN 'aktiv'
            WHEN 'closed' THEN 'closed'
            ELSE NULLIF(LOWER(TRIM(Status)), '')
        END
    FROM stg.WorkOrder;

    INSERT INTO etl.LoadLog (EntityName, RowsLoaded, LoadTimestamp, Status)
    SELECT 'cln.WorkOrder', COUNT(*), @CleanTimestamp, 'SUCCESS'
    FROM cln.WorkOrder;

END;
GO