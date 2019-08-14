SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PS3SPECGDSCORE_CHECK]
(
  @Num varchar(14),
  @Cls varchar(10),
  @Oper varchar(20),
  @ToStat int,
  @Msg varchar(255) output
) as
begin
  declare
    @vRet int,
    @Stat int,
    @Settleno int

  select @Stat = STAT from PS3SPECGDSCORE(nolock)
    where NUM = @Num And CLS = @Cls
  select @Settleno = max(no) from MONTHSETTLE

  if @Stat <> 0
  begin
    set @Msg = '不是未审核的单据，不能进行审核操作.'
    return(1)
  end

  update PS3SPECGDSCORE
    set STAT = @ToStat, SETTLENO = @Settleno, CHKDATE = GETDATE(), CHECKER = @Oper,
        LSTUPDTIME = getdate(), LSTUPDOPER = @oper
  where NUM = @num and CLS = @Cls

  IF @Stat = 0
  begin
    exec @VRET = PS3SPECGDSCORE_OCR @NUM, @CLS, @OPER, @MSG
    IF @VRET <> 0 RETURN(@VRET)
  end

  exec PS3SPECGDSCORE_ADD_LOG @Num, @Cls, @ToStat, '审核', @Oper

  Return(0)
end
GO
