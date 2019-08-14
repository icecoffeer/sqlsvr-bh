SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PAYDLTNUM] (
  @num char(10),
  @oper int,
  @neg_num char(10)
) with encryption as
begin
  declare
    @return_status int,    @cur_date datetime,
    @cur_settleno int,     @UsePayBySale int,
    @optusecntr int,       @PayConstractWithChgBook int,
    --zz 090402
    @pytotal money,        @src int,  @clecentr int, @errmsg VARCHAR(255),
    @usergid int,          @clecent int,  @sndtime datetime
  exec OptReadInt 55, 'UsePayBySale', 0, @UsePayBySale output
  --zz 090402
  select @usergid = usergid from system
  select
    @pytotal = pytotal,
    @src = src,
    @sndtime = sndtime,
    @clecent = isnull(clecent, @usergid),
    @clecentr = clecent
    from PAY where NUM = @num
  --end
  if (select STAT from PAY where NUM = @num) <> 1 begin
    raiserror('被删除的不是已审核的单据', 16, 1)
    return(1)
  end
--zz 090402
  if @pytotal <> 0 begin
    raiserror('结算单已被付款单引用并回写,不能冲单', 16, 1)
    return(2)
  end
  
  if @sndtime is not null and @src = @usergid and @clecent <> @usergid begin
    raiserror('结算单已发送到结算中心,不能冲单', 16, 1)
    return(3)
  end  
--end
  select
    @return_status = 0,
    @cur_date = convert(datetime, convert(char, getdate(), 102)),
    @cur_settleno = (select max(NO) from MONTHSETTLE)
  update PAY set STAT = 2, MODNUM = @neg_num where NUM = @num
  /* 做一张负单,INPRC,RTLPRC为当前值 */
  --为了保证产生的负单不被发生,将CLECENT设置为NULL
  insert into PAY(NUM, SETTLENO, FILDATE, FILLER, CHECKER,
    WRH, BILLTO, AMT, STAT, MODNUM, NOTE, PYTOTAL, FROMCLS, FROMNUM, DEPT, TAXRATELMT, ChkTAG, CLECENT, SRC, SRCNUM)
    select @neg_num, @cur_settleno, getdate(), @oper, @oper,
    WRH, BILLTO, -AMT, 0, @num, NULL, PYTOTAL, FROMCLS, FROMNUM, DEPT, TAXRATELMT, ChkTAG, NULL, SRC, SRCNUM
    from PAY where NUM = @num
  insert into PAYDTL(NUM, LINE, SETTLENO, GDGID,
    NPQTY, NPTOTAL, NPSTOTAL, QTY, TOTAL, STOTAL,
    INPRC, RTLPRC, BNUM, FROMCLS, FROMNUM, FROMLINE, TAX, FROMVDRNUM)
    select @neg_num, LINE, @cur_settleno, GDGID,
    -NPQTY, -NPTOTAL, -NPSTOTAL, -QTY, -TOTAL, -STOTAL,
    GOODSH.INPRC, GOODSH.RTLPRC, BNUM, FROMCLS, FROMNUM, FROMLINE, -TAX, FROMVDRNUM
    from PAYDTL, GOODSH
    where NUM = @num and PAYDTL.GDGID = GOODSH.GID
  /*Added by zhouhui 任务单2001111983072 2002.04.24 YSP ADD ASETTLENO*/
  insert into paydtldtl select @neg_num,LINE,GDGID,ASETTLENO,ADATE,WRH,BVDRGID from paydtldtl where num = @num
  /*End 任务单2001111983072*/
  --added by wang xin 2002-12-02
  insert into PAYTCDTL(NUM, LINE, TCCLS, TCCODE)
     select @neg_num, line, TCCLS, TCCODE
     from PAYTCDTL where NUM = @num
  --added end
  execute @return_status = PAYCHK @neg_num
  update PAY set STAT = 4, CLECENT = @clecentr where NUM = @neg_num --zz 090402
  --如果是在结算中心冲单后需要将原单据发送 zz 090402
  if @usergid = @clecent and @usergid <> @src
   begin
     EXEC @return_status = PAYSND @num, @errmsg output
     IF @return_status <> 0 RETURN @return_status
   end
  --Fanduoyi 1634 2004.02.01 强制删除由于审核负单生成的费用单,当选项 PayConstractWithChgBook打开时
  --2005.02.22
  exec optreadint 0, 'usecntr', 0, @optusecntr output
  --exec optreadint 55, 'PayConstractWithChgBook', 0 , @PayConstractWithChgBook OUTPUT
  if @optusecntr = 1
  begin
    delete from chgbook where srccls = '供应商结算单' and srcnum = @neg_num
  end
  --Fanduoyi 3134 2004.12.02 Wanhua
  if @UsePayBySale = 1
    delete from vdrpaybysaleinv where paynum = @num
  return(@return_status)
end

GO
