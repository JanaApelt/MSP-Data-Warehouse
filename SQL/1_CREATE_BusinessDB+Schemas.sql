/* ============================================================
   MSP / VMS Business-Datenbank
   Teil 1: Datenbank, Schemas und leere Tabellen
   ============================================================ */

CREATE DATABASE MSP_BusinessDB;
GO

USE MSP_BusinessDB;
GO

/* Schemas */
CREATE SCHEMA stg; -- für Rohdaten, werden nicht geändert
GO
CREATE SCHEMA cln; -- für zu bearbeitende Daten 
GO
CREATE SCHEMA vms; -- gereinigte Daten, die dann ins DWH geladen werden
GO
CREATE SCHEMA etl; -- für die Stored Procedures
GO

/* ============================================================
   1. STAGING AREA: Rohdaten, alle Felder als NVARCHAR
   ============================================================ */

CREATE TABLE stg.Kunde (
    KundeID NVARCHAR(50),
    Kundenname NVARCHAR(200)
);
GO

CREATE TABLE stg.HiringManager (
    HiringManagerID NVARCHAR(50),
    KundeID NVARCHAR(50),
    Vorname NVARCHAR(100),
    Nachname NVARCHAR(100),
    Abteilung NVARCHAR(100)
);
GO

CREATE TABLE stg.Lieferant (
    LieferantID NVARCHAR(50),
    Lieferantenname NVARCHAR(200)
);
GO

CREATE TABLE stg.Kandidat (
    KandidatID NVARCHAR(50),
    LieferantID NVARCHAR(50),
    Vorname NVARCHAR(100),
    Nachname NVARCHAR(100)
);
GO

CREATE TABLE stg.Anfrage (
    AnfrageID NVARCHAR(50),
    HiringManagerID NVARCHAR(50),
    Titel NVARCHAR(200),
    AnzahlPositionen NVARCHAR(50),
    MaxTagessatz NVARCHAR(50),
    VersendetAm NVARCHAR(50),
    GewuenschterStart NVARCHAR(50),
    Status NVARCHAR(50)
);
GO

CREATE TABLE stg.AnfrageKandidat (
    AnfrageID NVARCHAR(50),
    KandidatID NVARCHAR(50),
    Uebermittlungsdatum NVARCHAR(50),
    Kandidatenstatus NVARCHAR(50),
    TagessatzAngebot NVARCHAR(50)
);
GO

CREATE TABLE stg.Interview (
    HiringManagerID NVARCHAR(50),
    KandidatID NVARCHAR(50),
    Interviewdatum NVARCHAR(50),
    Interviewergebnis NVARCHAR(50)
);
GO

CREATE TABLE stg.WorkOrder (
    WorkOrderID NVARCHAR(50),
    AnfrageID NVARCHAR(50),
    KandidatID NVARCHAR(50),
    HiringManagerID NVARCHAR(50),
    LieferantID NVARCHAR(50),
    ErstelltAm NVARCHAR(50),
    Startdatum NVARCHAR(50),
    TagessatzFinal NVARCHAR(50),
    Status NVARCHAR(50)
);
GO

/* ============================================================
   2. CLEANING AREA: bereinigte und typisierte Daten
   ============================================================ */

CREATE TABLE cln.Kunde (
    KundeID INT,
    Kundenname NVARCHAR(200)
);
GO

CREATE TABLE cln.HiringManager (
    HiringManagerID INT,
    KundeID INT,
    Vorname NVARCHAR(100),
    Nachname NVARCHAR(100),
    Abteilung NVARCHAR(100)
);
GO

CREATE TABLE cln.Lieferant (
    LieferantID INT,
    Lieferantenname NVARCHAR(200)
);
GO

CREATE TABLE cln.Kandidat (
    KandidatID INT,
    LieferantID INT,
    Vorname NVARCHAR(100),
    Nachname NVARCHAR(100)
);
GO

CREATE TABLE cln.Anfrage (
    AnfrageID INT,
    HiringManagerID INT,
    Titel NVARCHAR(200),
    AnzahlPositionen INT,
    MaxTagessatz DECIMAL(8,2),
    VersendetAm DATETIME2,
    GewuenschterStart DATETIME2,
    Status NVARCHAR(50)
);
GO

CREATE TABLE cln.AnfrageKandidat (
    AnfrageID INT,
    KandidatID INT,
    Uebermittlungsdatum DATETIME2,
    Kandidatenstatus NVARCHAR(50),
    TagessatzAngebot DECIMAL(8,2)
);
GO

CREATE TABLE cln.Interview (
    HiringManagerID INT,
    KandidatID INT,
    Interviewdatum DATETIME2,
    Interviewergebnis NVARCHAR(50)
);
GO

CREATE TABLE cln.WorkOrder (
    WorkOrderID INT,
    AnfrageID INT,
    KandidatID INT,
    HiringManagerID INT,
    LieferantID INT,
    ErstelltAm DATETIME2,
    Startdatum DATETIME2,
    TagessatzFinal DECIMAL(8,2),
    Status NVARCHAR(50)
);
GO

/* ============================================================
   3. VMS-SCHEMA: finales relationales Modell mit PK/FK
   ============================================================ */

CREATE TABLE vms.Kunde (
    KundeID INT NOT NULL PRIMARY KEY,
    Kundenname NVARCHAR(200) NOT NULL
);
GO

CREATE TABLE vms.HiringManager (
    HiringManagerID INT NOT NULL PRIMARY KEY,
    KundeID INT NOT NULL,
    Vorname NVARCHAR(100),
    Nachname NVARCHAR(100),
    Abteilung NVARCHAR(100),
    CONSTRAINT FK_HiringManager_Kunde
        FOREIGN KEY (KundeID) REFERENCES vms.Kunde(KundeID)
);
GO

CREATE TABLE vms.Lieferant (
    LieferantID INT NOT NULL PRIMARY KEY,
    Lieferantenname NVARCHAR(200) NOT NULL
);
GO

CREATE TABLE vms.Kandidat (
    KandidatID INT NOT NULL PRIMARY KEY,
    LieferantID INT NOT NULL,
    Vorname NVARCHAR(100),
    Nachname NVARCHAR(100),
    CONSTRAINT FK_Kandidat_Lieferant
        FOREIGN KEY (LieferantID) REFERENCES vms.Lieferant(LieferantID)
);
GO

CREATE TABLE vms.Anfrage (
    AnfrageID INT NOT NULL PRIMARY KEY,
    HiringManagerID INT NOT NULL,
    Titel NVARCHAR(200),
    AnzahlPositionen INT,
    MaxTagessatz DECIMAL(8,2),
    VersendetAm DATETIME2,
    GewuenschterStart DATETIME2,
    Status NVARCHAR(50),
    CONSTRAINT FK_Anfrage_HiringManager
        FOREIGN KEY (HiringManagerID) REFERENCES vms.HiringManager(HiringManagerID)
);
GO

CREATE TABLE vms.AnfrageKandidat (
    AnfrageID INT NOT NULL,
    KandidatID INT NOT NULL,
    Uebermittlungsdatum DATETIME2,
    Kandidatenstatus NVARCHAR(50),
    TagessatzAngebot DECIMAL(8,2),
    CONSTRAINT PK_AnfrageKandidat
        PRIMARY KEY (AnfrageID, KandidatID),
    CONSTRAINT FK_AnfrageKandidat_Anfrage
        FOREIGN KEY (AnfrageID) REFERENCES vms.Anfrage(AnfrageID),
    CONSTRAINT FK_AnfrageKandidat_Kandidat
        FOREIGN KEY (KandidatID) REFERENCES vms.Kandidat(KandidatID)
);
GO

CREATE TABLE vms.Interview (
    HiringManagerID INT NOT NULL,
    KandidatID INT NOT NULL,
    Interviewdatum DATETIME2 NOT NULL,
    Interviewergebnis NVARCHAR(50),
    CONSTRAINT PK_Interview
        PRIMARY KEY (HiringManagerID, KandidatID, Interviewdatum),
    CONSTRAINT FK_Interview_HiringManager
        FOREIGN KEY (HiringManagerID) REFERENCES vms.HiringManager(HiringManagerID),
    CONSTRAINT FK_Interview_Kandidat
        FOREIGN KEY (KandidatID) REFERENCES vms.Kandidat(KandidatID)
);
GO

CREATE TABLE vms.WorkOrder (
    WorkOrderID INT NOT NULL PRIMARY KEY,
    AnfrageID INT NOT NULL,
    KandidatID INT NOT NULL,
    HiringManagerID INT NOT NULL,
    LieferantID INT NOT NULL,
    ErstelltAm DATETIME2,
    Startdatum DATETIME2,
    TagessatzFinal DECIMAL(8,2),
    Status NVARCHAR(50),
    CONSTRAINT FK_WorkOrder_Anfrage
        FOREIGN KEY (AnfrageID) REFERENCES vms.Anfrage(AnfrageID),
    CONSTRAINT FK_WorkOrder_Kandidat
        FOREIGN KEY (KandidatID) REFERENCES vms.Kandidat(KandidatID),
    CONSTRAINT FK_WorkOrder_HiringManager
        FOREIGN KEY (HiringManagerID) REFERENCES vms.HiringManager(HiringManagerID),
    CONSTRAINT FK_WorkOrder_Lieferant
        FOREIGN KEY (LieferantID) REFERENCES vms.Lieferant(LieferantID)
);
GO


-- LoadTimestamp hinzufügen --

ALTER TABLE stg.Kunde
ADD LoadTimestamp DATETIME2 NULL;
GO

ALTER TABLE stg.HiringManager
ADD LoadTimestamp DATETIME2 NULL;
GO

ALTER TABLE stg.Lieferant
ADD LoadTimestamp DATETIME2 NULL;
GO

ALTER TABLE stg.Kandidat
ADD LoadTimestamp DATETIME2 NULL;
GO

ALTER TABLE stg.Anfrage
ADD LoadTimestamp DATETIME2 NULL;
GO

ALTER TABLE stg.AnfrageKandidat
ADD LoadTimestamp DATETIME2 NULL;
GO

ALTER TABLE stg.Interview
ADD LoadTimestamp DATETIME2 NULL;
GO

ALTER TABLE stg.WorkOrder
ADD LoadTimestamp DATETIME2 NULL;
GO

-- Log-Tabelle erstellen --

CREATE TABLE etl.LoadLog
(
    LoadID INT IDENTITY(1,1) PRIMARY KEY,
    EntityName NVARCHAR(100),
    RowsLoaded INT,
    LoadTimestamp DATETIME2 DEFAULT GETDATE(),
    Status NVARCHAR(20)
);
GO