SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PS3NOTSCOREGDSCOPE_CHECK]
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
    @opt  int,
    @Settleno int

  select @Stat = STAT from PS3NOTSCOREGDSCOPE(nolock) where NUM = @Num
  select @Settleno = max(no) from MONTHSETTLE

  if @Stat <> 0
  begin
    set @Msg = '不是未审核的单据，不能进行审核操作.'
    return(1)
  end

  --检查明细中是否存在重叠的数据,如果有,根据选项自动删除或者给出提示
  Exec @vRet = PS3ChkDup_NotScore @Num, @Cls, @Msg OutPut
  If @vRet <> 0
    Return 1

  update PS3NOTSCOREGDSCOPE
    set STAT = @ToStat, SETTLENO = @Settleno, CHKDATE = GETDATE(), CHECKER = @Oper, LSTUPDTIME = getdate(), LSTUPDOPER = @oper
  where NUM = @num and CLS = @Cls

  IF @Stat = 0
  begin
    exec @VRET = PS3NOTSCOREGDSCOPE_OCR  @NUM, @CLS, @OPER, @MSG
    IF @VRET <> 0 RETURN(@VRET)
  end

  EXEC OPTREADINT 5144, 'PS3_CHKTOSEND', 0, @opt OUTPUT
  if @opt = 1
    exec PS3NOTSCOREGDSCOPE_SEND @CLS, @NUM, @OPER, @ToStat, @MSG

  exec PS3NOTSCOREGDSCOPE_ADD_LOG @Num, @Cls, @ToStat, '审核', @Oper
  return(0)
end
GO
