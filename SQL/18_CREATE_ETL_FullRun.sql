USE MSP_DWH;
GO

CREATE OR ALTER PROCEDURE etl.usp_Run_Full_ETL
AS
BEGIN
    SET NOCOUNT ON;

    EXEC MSP_BusinessDB.etl.usp_Extract_Staging
        @FolderPath = 'C:\MSP_VMS_Testdaten\';

    EXEC MSP_BusinessDB.etl.usp_Transform_Data;

    EXEC MSP_BusinessDB.etl.usp_Load_VMS;

    EXEC MSP_DWH.etl.usp_Load_Dimensions;

    EXEC MSP_DWH.etl.usp_Load_FactMSP;
END;
GO