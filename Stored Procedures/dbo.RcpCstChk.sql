SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RcpCstChk](
  @num char(10)
) with encryption as
begin
  declare
    @cls char(10),
    @cur_date datetime,
    @cur_settleno int,
    @wrh int,
    @billto int,
    @stat int,
    @pay money,
    @gdgid int,
    @settleno int, 
    @store int,
    @OptionValue_RCPCST char(1) /*2002.08.01*/,
    @inibal money

  select
    @cls = CLS,
    @cur_date = convert(char(10), GETDATE(), 102),
    @cur_settleno = (select max(NO) from MONTHSETTLE),
    @wrh = WRH,
    @billto = CLIENT,
    @stat = STAT,
    @pay = PAY

  from RCPCST
  where NUM = @num
  if @stat <> 0
  begin
    raiserror('审核的不是未审核的单据.', 16, 1)
    return (1)
  end

  select @store = usergid from system

  /*if @cls = '付款'--add by cyb 2002.08.14
  begin
     select @inibal = sum(nptl) from v_cstyrpt where bcstgid = @billto and bwrh = @wrh and astore = @store
     if @pay > @inibal
     begin
     end
  end
 */
  --add by cyb 
  select @OptionValue_RCPCST = OptionValue from HDOption where  moduleNo = 0  and OptionCaption = 'RCPCST'
  if @OptionValue_RCPCST is null 
     select @OptionValue_RCPCST = '0'
  if @OptionValue_RCPCST = '1'
  begin
	  IF @CLS = '付款'
             if @pay < 0 
	     begin
        	  insert into CSTBill (ASETTLENO,ADATE,CLS,CLIENT,OUTNUM,TOTAL,RCPTOTAL,OTOTAL)
			VALUES (@CUR_SETTLENO,GETDATE(),'付款',@billto,@NUM,@PAY,0,@PAY)
		  update RCPCST
		  set FILDATE = GETDATE(), SETTLENO = @cur_settleno, STAT = 1
		  where NUM = @num

		  insert into ZK (ADATE, ASETTLENO, BWRH, BCSTGID, BGDGID, SK_A)
	          values (@cur_date, @cur_settleno, @wrh, @billto, 1, @pay)
	
		return(0) --直接返回
	     end
	     else
                 EXEC CstAccountChk @NUM 
	  IF @CLS = '调整'
	  begin
		insert into CSTBill (ASETTLENO,ADATE,CLS,CLIENT,OUTNUM,TOTAL,RCPTOTAL,OTOTAL)
			VALUES (@CUR_SETTLENO,GETDATE(),@CLS,@billto,@NUM,@PAY,0,@PAY)		
	  end	
  end

  update RCPCST
  set FILDATE = GETDATE(), SETTLENO = @cur_settleno, STAT = 1
  where NUM = @num
  if @cls = '付款'
    insert into ZK (ADATE, ASETTLENO, BWRH, BCSTGID, BGDGID, SK_A)
    values (@cur_date, @cur_settleno, @wrh, @billto, 1, @pay)
  else
    insert into ZK (ADATE, ASETTLENO, BWRH, BCSTGID, BGDGID, YSKT_A)
    values (@cur_date, @cur_settleno, @wrh, @billto, 1, @pay)

  return (0)
end
GO
