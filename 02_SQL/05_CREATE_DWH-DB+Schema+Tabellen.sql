CREATE DATABASE MSP_DWH;
GO

USE MSP_DWH;
GO

CREATE SCHEMA dwh;
GO


/* ============================
   Dimension: Zeit
   ============================ */
CREATE TABLE dwh.DimZeit (
    ZeitID INT NOT NULL PRIMARY KEY,
    Datum DATE NOT NULL,
    Tag INT NOT NULL,
    Woche INT NOT NULL,
    Monat INT NOT NULL,
    Quartal INT NOT NULL,
    Jahr INT NOT NULL
);
GO

/* ============================
   Dimension: Lieferant
   ============================ */
CREATE TABLE dwh.DimLieferant (
    LieferantID INT NOT NULL PRIMARY KEY,
    Lieferantenname NVARCHAR(200),
    Ansprechpartner NVARCHAR(100),
    Email NVARCHAR(100)
);
GO

/* ============================
   Dimension: Anfrage
   ============================ */
CREATE TABLE dwh.DimAnfrage (
    AnfrageID INT NOT NULL PRIMARY KEY,
    Titel NVARCHAR(200),
    AnzahlPositionen INT,
    GewuenschterStart DATETIME2,
    MaximalerTagessatz DECIMAL(8,2),
    Status NVARCHAR(50)
);
GO

/* ============================
   Dimension: Kandidat
   ============================ */
CREATE TABLE dwh.DimKandidat (
    KandidatID INT NOT NULL PRIMARY KEY,
    Name NVARCHAR(200),
    Email NVARCHAR(100),
    Skillset NVARCHAR(200)
);
GO

/* ============================
   Dimension: Hiring Manager
   ============================ */
CREATE TABLE dwh.DimHiringManager (
    HiringManagerID INT NOT NULL PRIMARY KEY,
    Name NVARCHAR(200),
    Email NVARCHAR(100),
    Abteilung NVARCHAR(100)
);
GO

/* ============================
   Faktentabelle: FactMSP
   ============================ */
CREATE TABLE dwh.FactMSP (
    FactMSPID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,

    ZeitID INT NOT NULL,
    LieferantID INT NOT NULL,
    AnfrageID INT NOT NULL,
    KandidatID INT NOT NULL,
    HiringManagerID INT NOT NULL,

    TimeToHireDays INT NULL,
    TagessatzAngebot DECIMAL(8,2) NULL,
    TagessatzFinal DECIMAL(8,2) NULL,
    DeltaAngebotZuMax DECIMAL(8,2) NULL,
    DeltaFinalZuMax DECIMAL(8,2) NULL,
    AnzahlUebermittlungen INT NULL,
    AnzahlInterviews INT NULL,
    AnzahlSelected INT NULL,
    WorkOrderCount INT NULL,

    CONSTRAINT FK_FactMSP_DimZeit
        FOREIGN KEY (ZeitID) REFERENCES dwh.DimZeit(ZeitID),

    CONSTRAINT FK_FactMSP_DimLieferant
        FOREIGN KEY (LieferantID) REFERENCES dwh.DimLieferant(LieferantID),

    CONSTRAINT FK_FactMSP_DimAnfrage
        FOREIGN KEY (AnfrageID) REFERENCES dwh.DimAnfrage(AnfrageID),

    CONSTRAINT FK_FactMSP_DimKandidat
        FOREIGN KEY (KandidatID) REFERENCES dwh.DimKandidat(KandidatID),

    CONSTRAINT FK_FactMSP_DimHiringManager
        FOREIGN KEY (HiringManagerID) REFERENCES dwh.DimHiringManager(HiringManagerID)
);
GO