SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[STKOUTBCKCHK](
  @cls char(10),
  @num char(10),
  @VStat smallint = 1,   /* add By jinlei 2005.5.18*/
  @errmsg varchar(200) = '' output,
  @ChkFlag smallint = 0  /*调用标志，1表示WMS调用，缺省为0*/
)  as
begin
  declare
    @return_status int,    @bstat smallint, @optvalue_Chk int, @poMsg varchar(255)
  exec OPTREADINT 69, 'ChkStatDwFunds', 0, @optvalue_Chk output

  if @cls <> '批发'
    set @optvalue_chk = 0
  if @optvalue_Chk = 0
  begin
    if @VStat <> 1 and @VStat <> 7
      raiserror('复核选项未开启，传入VSTAT参数错误',16,1)
  end
  select @bstat = stat from stkoutbck where num like @num and cls like @cls
  if @VStat = 7  --预审
  begin
    exec @return_status = STKOUTBCKCHK_PRECHK
      @CLS = @cls, @NUM = @num, @ChkFlag = @ChkFlag, @poMsg = @poMsg OUTPUT
    if @return_status <> 0 raiserror(@poMsg,16,1)
  end
  else if @VStat = 1
  begin
    exec @return_status = STKOUTBCKCHKex
      @CLS = @cls,  @NUM = @num, @VStat = @VStat, @ChkFlag = @ChkFlag, @poMsg = @poMsg OUTPUT
    if @return_status <> 0 raiserror(@poMsg,16,1)
  end
  else if @VStat = 6
  begin
    if @bStat = 0
    begin
      exec @return_status = STKOUTBCKCHKex
        @CLS = @cls,  @NUM = @num,  @VStat = 1, @ChkFlag = @ChkFlag, @poMsg = @poMsg OUTPUT
      if @return_status <> 0 raiserror(@poMsg,16,1)
    end
    exec @return_status = STKOUTBCKCHKCHKex
      @CLS = @cls,  @NUM = @num, @VStat = @VStat, @ChkFlag = @ChkFlag, @poMsg = @poMsg OUTPUT
    if @bStat = 0 begin if @return_status < 0 return 0 end
    else if @return_status <> 0 raiserror(@poMsg,16,1)
  end else
  begin
    set @return_status = 1
    raiserror('未知的VSTAT参数值。', 16,1)
  end

  -- Added by zhourong, Q8789 增加待发送退货单处理
  IF @cls = '配货' AND @vStat IN (1, 6, 7)
  BEGIN
    DECLARE @store int, @state int;
    IF @vStat = 7
      SET @state = 0;
    ELSE
      SET @state = 1;
    SELECT @store = Src FROM StkOutBck WHERE Cls = @cls AND Num = @num;
    DELETE EPSSENDRTNTOTAL WHERE Num = @num;
    INSERT EPSSENDRTNTOTAL(Num, Store, State)  VALUES (@num, @store, @state)
  END;

  return @return_status
end
GO
