USE MSP_DWH;
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'etl')
    EXEC('CREATE SCHEMA etl');
GO

CREATE OR ALTER PROCEDURE etl.usp_Load_Dimensions
AS
BEGIN
    SET NOCOUNT ON;

    -- Full Load: Fact zuerst leeren, damit Dimensionen neu geladen werden können
    DELETE FROM dwh.FactMSP;

    DELETE FROM dwh.DimZeit;
    DELETE FROM dwh.DimLieferant;
    DELETE FROM dwh.DimAnfrage;
    DELETE FROM dwh.DimKandidat;
    DELETE FROM dwh.DimHiringManager;

    /* DimZeit */
    ;WITH Datumswerte AS
    (
        SELECT CAST(VersendetAm AS DATE) AS Datum
        FROM MSP_BusinessDB.vms.Anfrage
        WHERE VersendetAm IS NOT NULL

        UNION

        SELECT CAST(GewuenschterStart AS DATE)
        FROM MSP_BusinessDB.vms.Anfrage
        WHERE GewuenschterStart IS NOT NULL

        UNION

        SELECT CAST(ErstelltAm AS DATE)
        FROM MSP_BusinessDB.vms.WorkOrder
        WHERE ErstelltAm IS NOT NULL

        UNION

        SELECT CAST(Startdatum AS DATE)
        FROM MSP_BusinessDB.vms.WorkOrder
        WHERE Startdatum IS NOT NULL
    )
    INSERT INTO dwh.DimZeit
    (
        ZeitID,
        Datum,
        Tag,
        Woche,
        Monat,
        Quartal,
        Jahr
    )
    SELECT
        CAST(CONVERT(CHAR(8), Datum, 112) AS INT) AS ZeitID,
        Datum,
        DATEPART(DAY, Datum) AS Tag,
        DATEPART(ISO_WEEK, Datum) AS Woche,
        DATEPART(MONTH, Datum) AS Monat,
        DATEPART(QUARTER, Datum) AS Quartal,
        DATEPART(YEAR, Datum) AS Jahr
    FROM Datumswerte;

    /* DimLieferant */
    INSERT INTO dwh.DimLieferant
    (
        LieferantID,
        Lieferantenname,
        Ansprechpartner,
        Email
    )
    SELECT
        LieferantID,
        Lieferantenname,
        NULL AS Ansprechpartner,
        NULL AS Email
    FROM MSP_BusinessDB.vms.Lieferant;

    /* DimAnfrage */
    INSERT INTO dwh.DimAnfrage
    (
        AnfrageID,
        Titel,
        AnzahlPositionen,
        GewuenschterStart,
        MaximalerTagessatz,
        Status
    )
    SELECT
        AnfrageID,
        Titel,
        AnzahlPositionen,
        GewuenschterStart,
        MaxTagessatz,
        Status
    FROM MSP_BusinessDB.vms.Anfrage;

    /* DimKandidat */
    INSERT INTO dwh.DimKandidat
    (
        KandidatID,
        Name,
        Email,
        Skillset
    )
    SELECT
        KandidatID,
        CONCAT(Vorname, ' ', Nachname) AS Name,
        NULL AS Email,
        NULL AS Skillset
    FROM MSP_BusinessDB.vms.Kandidat;

    /* DimHiringManager */
    INSERT INTO dwh.DimHiringManager
    (
        HiringManagerID,
        Name,
        Email,
        Abteilung
    )
    SELECT
        HiringManagerID,
        CONCAT(Vorname, ' ', Nachname) AS Name,
        NULL AS Email,
        Abteilung
    FROM MSP_BusinessDB.vms.HiringManager;

END;
GO