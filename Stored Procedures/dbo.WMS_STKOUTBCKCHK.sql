SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[WMS_STKOUTBCKCHK](
  @cls char(10),
  @num char(10),
  @VStat smallint = 1,   /* add By jinlei 2005.5.18*/  
  @errmsg varchar(200) = '' output,
  @ChkFlag smallint = 0,  /*调用标志，1表示WMS调用，缺省为0*/ 
  @poMsg varchar(255) = null output
)  as
begin
  declare
    @return_status int,    @bstat smallint, @optvalue_Chk int
  exec OPTREADINT 69, 'ChkStatDwFunds', 0, @optvalue_Chk output    
  
  if @cls <> '批发'
    set @optvalue_chk = 0
  if @optvalue_Chk = 0
  begin
    if @VStat <> 1 and @VStat <> 7
    begin
      set @poMsg = '复核选项未开启，传入VSTAT参数错误'
      return 1
    end
  end
  select @bstat = stat from stkoutbck where num like @num and cls like @cls
  if @VStat = 7  --预审
  begin
    exec @return_status = STKOUTBCKCHK_PRECHK
      @CLS = @cls, @NUM = @num, @ChkFlag = @ChkFlag, @poMsg = @poMsg OUTPUT
  end
  else if @VStat = 1
  begin
    exec @return_status = STKOUTBCKCHKex 
      @CLS = @cls,  @NUM = @num, @VStat = @VStat, @ChkFlag = @ChkFlag, @poMsg = @poMsg OUTPUT  
  end 
  else if @VStat = 6 
  begin
    if @bStat = 0
    begin
      exec @return_status = STKOUTBCKCHKex 
        @CLS = @cls,  @NUM = @num,  @VStat = 1, @ChkFlag = @ChkFlag, @poMsg = @poMsg OUTPUT
      if @return_status <> 0 return @return_status
    end
    exec @return_status = STKOUTBCKCHKCHKex 
      @CLS = @cls,  @NUM = @num, @VStat = @VStat, @ChkFlag = @ChkFlag, @poMsg = @poMsg OUTPUT  
    if @bStat = 0 begin if @return_status < 0 return 0 end
    else if @return_status <> 0 return @return_status
  end else
  begin
    set @return_status = 1
    set @poMsg = '未知的VSTAT参数值。'
  end
  return @return_status
end
GO
