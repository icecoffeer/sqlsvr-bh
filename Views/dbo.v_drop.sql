SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create view [dbo].[v_drop] as select count(*) cnt from [NetFTPGROUPDTL]
GO
