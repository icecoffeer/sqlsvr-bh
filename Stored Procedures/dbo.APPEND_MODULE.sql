SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[APPEND_MODULE] (
    @piNO SMALLINT,
    @piNAME CHAR(255),
    @piTYPE SMALLINT,
    @piMEMO CHAR(255),
    @piPROCNAME CHAR(64),
    @piPKGNAME CHAR(64),
    @piUNITNAME CHAR(64),
    @piCATALOG CHAR(64)
) as
begin
    delete from MODULE where NO = @piNO
    insert into MODULE (NO, NAME, TYPE, MEMO, PROCNAME, PKGNAME, UNITNAME, CATALOG)
        values (@piNO, @piNAME, @piTYPE, @piMEMO, @piPROCNAME, @piPKGNAME, @piUNITNAME, @piCATALOG)
end
GO
