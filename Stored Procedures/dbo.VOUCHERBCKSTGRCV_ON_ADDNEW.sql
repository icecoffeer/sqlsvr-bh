SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[VOUCHERBCKSTGRCV_ON_ADDNEW]
(
  @Num varchar(14),            --单号
  @Oper varchar(30),           --操作人
  @Msg varchar(255) output     --错误信息
)
as
begin
  update VOUCHERBCKSTGRCV set LSTUPDOPER = @Oper, LSTUPDTIME = getdate() where Num = @Num;
  exec VOUCHERBCKSTGRCV_ADD_LOG @Num, 0, '新增', @Oper;
  return(0)
end
GO
