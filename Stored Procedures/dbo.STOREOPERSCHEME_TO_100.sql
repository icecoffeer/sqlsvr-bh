SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[STOREOPERSCHEME_TO_100]
(
  @Num varchar(14),
  @Oper varchar(20),
  @ToStat int,
  @Msg varchar(255) output
) as
begin
  declare
    @vRet int,
    @Stat int,
    @Settleno int

  select @Stat = STAT from STOREOPERSCHEME(nolock) where NUM = @Num
  select @Settleno = max(no) from MONTHSETTLE

  if @Stat <> 0
  begin
    set @Msg = '不是未审核的单据，不能进行审核操作.'
    return(1)
  end

  update STOREOPERSCHEME
    set STAT = @ToStat, SETTLENO = @Settleno, CHKDATE = GETDATE(), CHECKER = @Oper, LSTUPDTIME = getdate(), LSTUPDOPER = @oper
  where NUM = @Num

  IF @Stat = 0
  begin
    exec @VRET = STOREOPERSCHEME_OCR @NUM, @OPER, @MSG
    IF @VRET <> 0 RETURN(@VRET)
  end

  exec STOREOPERSCHEME_ADD_LOG @Num, @ToStat, '审核', @Oper
  return(0)
end
GO
