SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[CntrDptBillChgStat] (
  @cls  char(10),
  @num  char(14),
  @tostat int,
  @oper	varchar(50),
  @msg varchar(255) output
)
as
begin
  declare @fromstat int
  declare @return_status int
  declare @SRC int
  declare @CLECENT int
  declare @USERGID int

  select @fromstat = stat, @SRC = SRC, @CLECENT = CLECENT
   from CntrDptBill
  where num = @num and cls = @cls
  
  if @fromstat is null
  begin
    if @cls = '收'
      raiserror('压库金额收款单%s不存在，可能已被删除', 16, 1, @num)
    else
      raiserror('压库金额付款单%s不存在，可能已被删除', 16, 1, @num)
    return 1
  end
  if @tostat = 900 and @cls = '付'
  begin
    if @fromstat <> 100
    begin
      raiserror('压库金额付款单%s不是已审核单据', 16, 1, @num)
      return 1
    end
    else
    begin
      exec @return_status = CntrDptBillOutDoChk @num
      if @return_status <> 0 return @return_status    
    end  
  end
  if @tostat = 1800 and @cls = '收'
  begin
    if @fromstat <> 100
    begin
      raiserror('压库金额收款单%s不是已审核单据', 16, 1, @num)
      return 1
    end
    else
    begin
      exec @return_status = CntrDptBillInDoChk @num
      if @return_status <> 0 return @return_status    
    end  
  end
  if (@tostat = 100) and (@fromstat <> 0)
  begin
    if @cls = '收'
        raiserror('压库金额收款单%s不是未审核单据', 16, 1, @num)
      else
        raiserror('压库金额付款单%s不是未审核单据', 16, 1, @num)
      return 1
  end;
  
  SELECT @USERGID = USERGID FROM FASYSTEM(NOLOCK)
  --SET @SRC = NULL
  --SET @CLECENT = NULL
  
  if @tostat in (900, 1800)
  begin 
    update CntrDptBill set stat = @tostat, payer = @oper 
      where cls = @cls and num = @num
    
    IF @SRC = @USERGID RETURN 0 --计算中心付款操作不发送
    IF @CLS = '收'
      EXEC @return_status = DepIn_SEND @NUM, @OPER, @MSG
    ELSE
      EXEC @return_status = DepOut_SEND @NUM, @OPER, @MSG
	  IF @return_status <> 0 RETURN @return_status
  end
  else
  begin
    update CntrDptBill set stat = @tostat, checker = @oper 
      where cls = @cls and num = @num
    
    IF @SRC IS NULL RETURN 0
    IF @USERGID = @SRC
    BEGIN  
      IF @CLECENT IS NULL OR @CLECENT = @USERGID
        RETURN 0
    END
    if @cls = '收'
      EXEC @return_status = DepIn_SEND @NUM, @OPER, @MSG
    else
      EXEC @return_status = DepOut_SEND @NUM, @OPER, @MSG
	   IF @return_status <> 0 RETURN @return_status
  end
  
  --Fanduoyi 1298 
  insert into CNTRDPTBILLLOG(cls, num, stat, modifier, time)
    values(@cls, @num, @tostat, @oper, getdate())
end
GO
