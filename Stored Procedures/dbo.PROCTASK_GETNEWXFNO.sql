SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PROCTASK_GETNEWXFNO] (
  @Abn varchar(10),
  @Newbn varchar(10) output               
) as
begin
  exec nextbn @Abn, @Newbn output
end
GO
