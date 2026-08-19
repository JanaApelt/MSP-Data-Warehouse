USE MSP_DWH;
GO

CREATE OR ALTER PROCEDURE etl.usp_Load_FactMSP
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM dwh.FactMSP;

    /* Fehlende Datumswerte ergänzen */
    INSERT INTO dwh.DimZeit (ZeitID, Datum, Tag, Woche, Monat, Quartal, Jahr)
    SELECT DISTINCT
        CAST(CONVERT(CHAR(8), CAST(COALESCE(wo.ErstelltAm, ak.Uebermittlungsdatum, a.VersendetAm) AS DATE), 112) AS INT),
        CAST(COALESCE(wo.ErstelltAm, ak.Uebermittlungsdatum, a.VersendetAm) AS DATE),
        DATEPART(DAY, CAST(COALESCE(wo.ErstelltAm, ak.Uebermittlungsdatum, a.VersendetAm) AS DATE)),
        DATEPART(ISO_WEEK, CAST(COALESCE(wo.ErstelltAm, ak.Uebermittlungsdatum, a.VersendetAm) AS DATE)),
        DATEPART(MONTH, CAST(COALESCE(wo.ErstelltAm, ak.Uebermittlungsdatum, a.VersendetAm) AS DATE)),
        DATEPART(QUARTER, CAST(COALESCE(wo.ErstelltAm, ak.Uebermittlungsdatum, a.VersendetAm) AS DATE)),
        DATEPART(YEAR, CAST(COALESCE(wo.ErstelltAm, ak.Uebermittlungsdatum, a.VersendetAm) AS DATE))
    FROM MSP_BusinessDB.vms.AnfrageKandidat ak
    INNER JOIN MSP_BusinessDB.vms.Anfrage a
        ON ak.AnfrageID = a.AnfrageID
    LEFT JOIN MSP_BusinessDB.vms.WorkOrder wo
        ON ak.AnfrageID = wo.AnfrageID
       AND ak.KandidatID = wo.KandidatID
    WHERE COALESCE(wo.ErstelltAm, ak.Uebermittlungsdatum, a.VersendetAm) IS NOT NULL
      AND NOT EXISTS (
          SELECT 1
          FROM dwh.DimZeit z
          WHERE z.ZeitID =
              CAST(CONVERT(CHAR(8), CAST(COALESCE(wo.ErstelltAm, ak.Uebermittlungsdatum, a.VersendetAm) AS DATE), 112) AS INT)
      );

    /* Faktentabelle laden */
    INSERT INTO dwh.FactMSP
    (
        ZeitID,
        LieferantID,
        AnfrageID,
        KandidatID,
        HiringManagerID,
        TimeToHireDays,
        TagessatzAngebot,
        TagessatzFinal,
        DeltaAngebotZuMax,
        DeltaFinalZuMax,
        AnzahlUebermittlungen,
        AnzahlInterviews,
        AnzahlSelected,
        WorkOrderCount
    )
    SELECT
        CAST(CONVERT(CHAR(8), CAST(COALESCE(wo.ErstelltAm, ak.Uebermittlungsdatum, a.VersendetAm) AS DATE), 112) AS INT) AS ZeitID,
        k.LieferantID,
        ak.AnfrageID,
        ak.KandidatID,
        a.HiringManagerID,

        CASE 
            WHEN wo.ErstelltAm IS NOT NULL AND a.VersendetAm IS NOT NULL
            THEN DATEDIFF(DAY, a.VersendetAm, wo.ErstelltAm)
            ELSE NULL
        END AS TimeToHireDays,

        ak.TagessatzAngebot,
        wo.TagessatzFinal,

        CASE 
            WHEN ak.TagessatzAngebot IS NOT NULL AND a.MaxTagessatz IS NOT NULL
            THEN ak.TagessatzAngebot - a.MaxTagessatz
            ELSE NULL
        END AS DeltaAngebotZuMax,

        CASE 
            WHEN wo.TagessatzFinal IS NOT NULL AND a.MaxTagessatz IS NOT NULL
            THEN wo.TagessatzFinal - a.MaxTagessatz
            ELSE NULL
        END AS DeltaFinalZuMax,

        1 AS AnzahlUebermittlungen,

        CASE 
            WHEN i.KandidatID IS NOT NULL THEN 1 
            ELSE 0 
        END AS AnzahlInterviews,

        CASE 
            WHEN ak.Kandidatenstatus = 'selected' THEN 1 
            ELSE 0 
        END AS AnzahlSelected,

        CASE 
            WHEN wo.WorkOrderID IS NOT NULL THEN 1 
            ELSE 0 
        END AS WorkOrderCount

    FROM MSP_BusinessDB.vms.AnfrageKandidat ak
    INNER JOIN MSP_BusinessDB.vms.Anfrage a
        ON ak.AnfrageID = a.AnfrageID
    INNER JOIN MSP_BusinessDB.vms.Kandidat k
        ON ak.KandidatID = k.KandidatID
    LEFT JOIN MSP_BusinessDB.vms.WorkOrder wo
        ON ak.AnfrageID = wo.AnfrageID
       AND ak.KandidatID = wo.KandidatID
    LEFT JOIN MSP_BusinessDB.vms.Interview i
        ON ak.KandidatID = i.KandidatID
       AND a.HiringManagerID = i.HiringManagerID;
END;
GO