USE MSP_BusinessDB;
GO

CREATE OR ALTER PROCEDURE etl.usp_Extract_Staging
    @FolderPath NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @LoadTimestamp DATETIME2 = SYSDATETIME();
    DECLARE @sql NVARCHAR(MAX);

    IF RIGHT(@FolderPath, 1) <> '\'
        SET @FolderPath = @FolderPath + '\';

    TRUNCATE TABLE stg.WorkOrder;
    TRUNCATE TABLE stg.Interview;
    TRUNCATE TABLE stg.AnfrageKandidat;
    TRUNCATE TABLE stg.Anfrage;
    TRUNCATE TABLE stg.Kandidat;
    TRUNCATE TABLE stg.Lieferant;
    TRUNCATE TABLE stg.HiringManager;
    TRUNCATE TABLE stg.Kunde;

    DELETE FROM etl.LoadLog
    WHERE LoadTimestamp = @LoadTimestamp;

    /* Kunde */
    SET @sql = '
    BULK INSERT stg.Kunde
    FROM ''' + @FolderPath + 'Kunde.csv''
    WITH (
        FORMAT = ''CSV'',
        FIRSTROW = 2,
        FIELDTERMINATOR = '','',
        FIELDQUOTE = ''"'',
        ROWTERMINATOR = ''0x0a'',
        CODEPAGE = ''65001'',
        TABLOCK
    );';
    EXEC (@sql);

    INSERT INTO etl.LoadLog (EntityName, RowsLoaded, LoadTimestamp, Status)
    SELECT 'Kunde', COUNT(*), @LoadTimestamp, 'SUCCESS'
    FROM stg.Kunde;

    /* HiringManager */
    SET @sql = '
    BULK INSERT stg.HiringManager
    FROM ''' + @FolderPath + 'HiringManager.csv''
    WITH (
        FORMAT = ''CSV'',
        FIRSTROW = 2,
        FIELDTERMINATOR = '','',
        FIELDQUOTE = ''"'',
        ROWTERMINATOR = ''0x0a'',
        CODEPAGE = ''65001'',
        TABLOCK
    );';
    EXEC (@sql);

    INSERT INTO etl.LoadLog (EntityName, RowsLoaded, LoadTimestamp, Status)
    SELECT 'HiringManager', COUNT(*), @LoadTimestamp, 'SUCCESS'
    FROM stg.HiringManager;

    /* Lieferant */
    SET @sql = '
    BULK INSERT stg.Lieferant
    FROM ''' + @FolderPath + 'Lieferant.csv''
    WITH (
        FORMAT = ''CSV'',
        FIRSTROW = 2,
        FIELDTERMINATOR = '','',
        FIELDQUOTE = ''"'',
        ROWTERMINATOR = ''0x0a'',
        CODEPAGE = ''65001'',
        TABLOCK
    );';
    EXEC (@sql);

    INSERT INTO etl.LoadLog (EntityName, RowsLoaded, LoadTimestamp, Status)
    SELECT 'Lieferant', COUNT(*), @LoadTimestamp, 'SUCCESS'
    FROM stg.Lieferant;

    /* Kandidat */
    SET @sql = '
    BULK INSERT stg.Kandidat
    FROM ''' + @FolderPath + 'Kandidat.csv''
    WITH (
        FORMAT = ''CSV'',
        FIRSTROW = 2,
        FIELDTERMINATOR = '','',
        FIELDQUOTE = ''"'',
        ROWTERMINATOR = ''0x0a'',
        CODEPAGE = ''65001'',
        TABLOCK
    );';
    EXEC (@sql);

    INSERT INTO etl.LoadLog (EntityName, RowsLoaded, LoadTimestamp, Status)
    SELECT 'Kandidat', COUNT(*), @LoadTimestamp, 'SUCCESS'
    FROM stg.Kandidat;

    /* Anfrage */
    SET @sql = '
    BULK INSERT stg.Anfrage
    FROM ''' + @FolderPath + 'Anfrage.csv''
    WITH (
        FORMAT = ''CSV'',
        FIRSTROW = 2,
        FIELDTERMINATOR = '','',
        FIELDQUOTE = ''"'',
        ROWTERMINATOR = ''0x0a'',
        CODEPAGE = ''65001'',
        TABLOCK
    );';
    EXEC (@sql);

    INSERT INTO etl.LoadLog (EntityName, RowsLoaded, LoadTimestamp, Status)
    SELECT 'Anfrage', COUNT(*), @LoadTimestamp, 'SUCCESS'
    FROM stg.Anfrage;

    /* AnfrageKandidat */
    SET @sql = '
    BULK INSERT stg.AnfrageKandidat
    FROM ''' + @FolderPath + 'AnfrageKandidat.csv''
    WITH (
        FORMAT = ''CSV'',
        FIRSTROW = 2,
        FIELDTERMINATOR = '','',
        FIELDQUOTE = ''"'',
        ROWTERMINATOR = ''0x0a'',
        CODEPAGE = ''65001'',
        TABLOCK
    );';
    EXEC (@sql);

    INSERT INTO etl.LoadLog (EntityName, RowsLoaded, LoadTimestamp, Status)
    SELECT 'AnfrageKandidat', COUNT(*), @LoadTimestamp, 'SUCCESS'
    FROM stg.AnfrageKandidat;

    /* Interview */
    SET @sql = '
    BULK INSERT stg.Interview
    FROM ''' + @FolderPath + 'Interview.csv''
    WITH (
        FORMAT = ''CSV'',
        FIRSTROW = 2,
        FIELDTERMINATOR = '','',
        FIELDQUOTE = ''"'',
        ROWTERMINATOR = ''0x0a'',
        CODEPAGE = ''65001'',
        TABLOCK
    );';
    EXEC (@sql);

    INSERT INTO etl.LoadLog (EntityName, RowsLoaded, LoadTimestamp, Status)
    SELECT 'Interview', COUNT(*), @LoadTimestamp, 'SUCCESS'
    FROM stg.Interview;

    /* WorkOrder */
    SET @sql = '
    BULK INSERT stg.WorkOrder
    FROM ''' + @FolderPath + 'WorkOrder.csv''
    WITH (
        FORMAT = ''CSV'',
        FIRSTROW = 2,
        FIELDTERMINATOR = '','',
        FIELDQUOTE = ''"'',
        ROWTERMINATOR = ''0x0a'',
        CODEPAGE = ''65001'',
        TABLOCK
    );';
    EXEC (@sql);

    INSERT INTO etl.LoadLog (EntityName, RowsLoaded, LoadTimestamp, Status)
    SELECT 'WorkOrder', COUNT(*), @LoadTimestamp, 'SUCCESS'
    FROM stg.WorkOrder;

END;
GO