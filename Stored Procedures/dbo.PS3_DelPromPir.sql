SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PS3_DelPromPir](
  @Cls char(10),
  @PrmName char(30),
  @Num char(14)
)
as
begin
  declare
    @opt_UsePromPir smallint

  exec OPTREADINT 0, 'PS3_UsePromPriority', 0, @opt_UsePromPir OutPut
  if @opt_UsePromPir <> 1
    return 0

  --删除促销单优先级信息
  delete from PROMPIR Where (CLS = @Cls) and (PRMNAME = @PrmName) and (NUM = @Num)

  return 0
end
GO
