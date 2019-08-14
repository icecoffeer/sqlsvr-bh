SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[PROMCHK]
(
  @NUM     VARCHAR(14),
  @CLS     VARCHAR(10),
  @OPER     VARCHAR(30),
  @TOSTAT  int,
  @MSG  VARCHAR(255) OUTPUT
)
AS
BEGIN
  declare
    @VRET INT,
    @VSTAT INT,
    @VModuleId int,
    @VAutoSnd int

  if @CLS = '客单价' set @VModuleId = 708
  else if @CLS = '客单量' set @VModuleId = 710
  else if @CLS = '捆绑' set @VModuleId = 683
  else if @CLS = '总额' set @VModuleId = 8015
  else if @CLS = '总量' set @VModuleId = 8017

  exec OPTREADINT @VModuleId, 'AutoSnd', 0, @VAutoSnd OutPut;

  set @VRET = 0
  SELECT @VSTAT = STAT FROM PROM WHERE NUM = @NUM AND CLS = @CLS
  IF @TOSTAT <> 100 OR @VSTAT <> 0 OR @TOSTAT <= @VSTAT
    begin
      set @MSG = '目标状态不对' + CHAR(@TOSTAT)
      RETURN(1)
    end
  IF @VSTAT = 0
  begin
    exec @VRET = LOADPROMTO50 @CLS, @NUM, @OPER, @MSG
    IF @VRET <> 0 RETURN(@VRET)
    --更新促销单优先级数据
    if (@CLS = '捆绑') or (@CLS = '总量') or (@CLS = '总额')
    begin
      declare @PRMNAME char(30)
      set @PRMNAME = @CLS + '促销'
      Exec @VRET = PS3_UpdPromPir 'PROM', @CLS, @NUM, 'Promote', '组合'
      if @VRET <> 0
        RETURN @VRET
    end
  end

  UPDATE PROM
  SET STAT = @TOSTAT, FILDATE = getdate(),
      LSTUPDTIME = getdate()
  WHERE NUM = @NUM AND CLS = @CLS

  --Added by Zhuhaohui 2007.12.14 审核消息提醒
  if (@TOSTAT = 100)
  begin
    declare @title varchar(500),
            @event varchar(100)
    --触发提醒
    set @title = @CLS + '促销单[' + @NUM + ']在' + Convert(varchar, getdate(), 20) + '被审核了。'
    set @event = @CLS + '促销单审核提醒'
    execute PROMCHKPROMPT @NUM, @CLS, @title, @event, @OPER
  end
  --end of 促销单审核提醒

  INSERT INTO PROMLOG (NUM, CLS, STAT, FILLER, FILDATE)
  VALUES(@NUM, @CLS, 100, @OPER, getdate())
  if @VAutoSnd = 1
    EXEC @VRET = PROMSEND @NUM = @NUM, @CLS = @CLS, @OPER = @OPER, @TOSTAT = 0, @MSG = @MSG;

  --  IF @VRET <> 0 RETURN(1)
  RETURN(0)
END
GO
