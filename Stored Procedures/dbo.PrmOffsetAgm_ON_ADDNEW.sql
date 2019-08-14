SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PrmOffsetAgm_ON_ADDNEW](
  @Num varchar(14),            --协议号
  @Oper varchar(30),           --操作人
  @Msg varchar(255) output  --错误信息
) as
begin

  Return 0;
end
GO
