SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[BalVdrBEPAdj](
  @num varchar(14),
  @Cls varchar(10),
  @oper varchar(30),
  @TOStat int,
  @msg varchar(255) output
)with encryption
as
begin
  delete from VDRBEP where BILLNUM = @num
  update VDRBEPADJ set STAT = @TOStat where NUM = @num;
  exec VDRBEPADJ_ADD_LOG @num, @TOStat, '作废', @Oper;
  return 0
end
GO
