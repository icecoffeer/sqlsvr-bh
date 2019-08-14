SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[MXFDMD_CHKTO300]
(
  @Num varchar(14),
  @Oper varchar(20),
  @ToStat int,
  @Msg varchar(255) output
) as
begin

  declare @vRet int,
          @Stat int,
          @XCHGSTORE int,
          @EXP DATETIME

  select @Stat = STAT, @XCHGSTORE = XCHGSTORE, @EXP = EXPDATE from MXFDMD(nolock) where NUM = @Num

  if @Stat <> 400
  begin
    set @Msg = '不是总部批准的单据，不能进行完成操作.'
    return(1)
  end

  update MXFDMD
  set STAT = @ToStat, LSTUPDTIME = getdate(), LSTUPDOPER = @oper
  where NUM = @num

  exec MXFDMD_ADD_LOG @Num, @ToStat, '完成', @Oper;
end
GO
