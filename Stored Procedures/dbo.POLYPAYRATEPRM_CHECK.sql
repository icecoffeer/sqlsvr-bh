SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[POLYPAYRATEPRM_CHECK]  
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
  
  select @Stat = STAT from POLYPAYRATEPRM(nolock) where NUM = @Num and CLS = @Cls  
  select @Settleno = max(no) from MONTHSETTLE  
  
  if @Stat <> 0  
  begin  
    set @Msg = '不是未审核的单据，不能进行生效操作.'  
    return(1)  
  end  
  
  update POLYPAYRATEPRM  
  set STAT = @ToStat, SETTLENO = @Settleno, CHKDATE = GETDATE(), CHECKER = @Oper, LSTUPDTIME = getdate(), LSTUPDOPER = @oper  
  where NUM = @num and CLS = @Cls  
  
  IF @Stat = 0  
  begin  
    exec @VRET = POLYPAYRATEPRM_OCR  @NUM, @CLS, @OPER, @MSG  
    IF @VRET <> 0 RETURN(@VRET)  
  end  
  
  exec POLYPAYRATEPRM_ADD_LOG @Num, @Cls, @ToStat, '生效', @Oper;  
  return(0)  
end  
GO
