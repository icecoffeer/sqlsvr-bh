SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create Procedure [dbo].[VOUCHERBCKSTGRCV_DOREMOVE]
(
  @Num varchar(14),         --单号
  @Msg varchar(255) output  --错误信息
) as
begin
  delete from VOUCHERBCKSTGRCV where NUM = @Num
  delete from VOUCHERBCKSTGRCVDTL where NUM = @Num
  delete from VOUCHERBCKSTGRCVDTL2 where NUM = @Num
  delete from VOUCHERBCKSTGRCVGOODS where NUM = @Num
  set @Msg = ''
  return(0)
end
GO
