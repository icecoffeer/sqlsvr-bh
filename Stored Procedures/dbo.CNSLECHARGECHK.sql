SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[CNSLECHARGECHK]
(
  @Oper varchar(30),
  @CHARGEDATE varchar(10),
  @intAutoSnd smallint,
  @MSG VARCHAR(255) OUTPUT
) As
begin
	declare
	  @vRet int,
	  @SumShouldRcvTotalT0 money,
	  @SumShouldRcvTotalT1 money,
	  @SumRcvTotal money,
	  @SumOtherTotal money,
	  @ChgChkNum varchar(14),
	  @PayCls int,
	  @DtlLine int,
	  @DtlDtlLine int,
	  @DtlDtlCODE VARCHAR(13),
	  @DtlDtlNAME VARCHAR(50),
	  @DtlDtlCHKNO VARCHAR(100),
	  @DtlDtlSumTotal money,
	  @NewNum VARCHAR(14),
	  @NewNote varchar(1000),
	  @PayCls2 int

  set @vRet = 0;

  if (select count(1) from CHARGECHK where CHARGEDATE = @CHARGEDATE and STAT = 100) = 0
    begin
      set @MSG = '该日期下没有状态为已审核的收银审核单! ';
      return(1)
    end;
  select @SumShouldRcvTotalT0 = ISNULL(Sum(SHOULDRCVTOTALT0), 0), @SumShouldRcvTotalT1 = ISNULL(Sum(SHOULDRCVTOTALT1), 0), @SumRcvTotal = ISNULL(Sum(RCVTOTAL), 0), @SumOtherTotal = ISNULL(Sum(OTHERTOTAL), 0)
  from CHARGECHK
  where CHARGEDATE = @CHARGEDATE
    and STAT = 100;
  if @SumRcvTotal <> @SumShouldRcvTotalT0 + @SumShouldRcvTotalT1 + @SumOtherTotal
    begin
      set @MSG = '该日期下所有已审核收银审核单的实收总额不等于应收总额 + 其它业务总额，不允许合并';
      return(2)
    end;

  exec @vRet = GenNextBillNumEx '', 'CHARGECHK', @NewNum output;

  declare cur_ChgChkCls cursor for
    select distinct DTL.PAYCLS from CHARGECHKDTL DTL(nolock), CHARGECHK MST(nolock)
    where mst.chargedate = @CHARGEDATE
      and mst.stat = 100
      and mst.num = dtl.num
      and mst.SALETYPE in (0, 1)

  set @DtlLine = 1;
  Open cur_ChgChkCls;
  fetch next from cur_ChgChkCls into @PayCls;
  while @@Fetch_Status = 0
    begin
    	declare cur_ChgChkDtlDtl cursor for
        select DTL.CODE, DTL.NAME, DTL.CHKNO, IsNull(sum(DTL.total), 0) from CHARGECHKDTLDTL DTL(nolock), CHARGECHK MST(nolock)
        where mst.chargedate = @CHARGEDATE
          and mst.stat = 100
          and mst.num = dtl.num
          and mst.SALETYPE in (0, 1)
          and dtl.dtlcls = @PayCls
        group by DTL.CODE, DTL.NAME, DTL.CHKNO
      Open cur_ChgChkDtlDtl
      fetch next from cur_ChgChkDtlDtl into @DtlDtlCODE, @DtlDtlNAME, @DtlDtlChkNo, @DtlDtlSumTotal;
      set @DtlDtlLine = 1;
      while @@Fetch_Status = 0
        begin
        	insert into CHARGECHKDTLDTL(NUM, LINE, DTLDTLLINE, DTLCLS, CODE, NAME, CHKNO, TOTAL, NOTE)
        	values(@NewNum, @DtlLine, @DtlDtlLine, @PayCls, @DtlDtlCODE,@DtlDtlNAME, @DtlDtlChkNo, @DtlDtlSumTotal, NULL);
        	set @DtlDtlLine = @DtlDtlLine + 1;
        	fetch next from cur_ChgChkDtlDtl into @DtlDtlCODE, @DtlDtlNAME, @DtlDtlChkNo, @DtlDtlSumTotal;
        end;
      close cur_ChgChkDtlDtl;
      deallocate cur_ChgChkDtlDtl;
      insert into CHARGECHKDTL(NUM, LINE, PAYCLS, SHOULDRCVTOTAL, RCVTOTAL, NOTE)
      select @NewNum, @DtlLine, @PayCls, IsNull(sum(DTL.SHOULDRCVTOTAL), 0), IsNull(SUM(DTL.RCVTOTAL), 0), NULL
      from CHARGECHKDTL DTL(nolock), CHARGECHK MST(nolock)
      where mst.chargedate = @CHARGEDATE
        and mst.stat = 100
        and mst.num = dtl.num
        and mst.SALETYPE in (0, 1)
        and DTL.PAYCLS = @PayCls
      set @DtlLine = @DtlLine + 1;
      fetch next from cur_ChgChkCls into @PayCls;
    end;
    close cur_ChgChkCls;
    deallocate cur_ChgChkCls;

 --Dtl2
  declare cur_ChgChkCls2 cursor for
    select distinct DTL.PAYCLS from CHARGECHKDTL2 DTL(nolock), CHARGECHK MST(nolock)
    where mst.chargedate = @CHARGEDATE
      and mst.stat = 100
      and mst.num = dtl.num
      and mst.SALETYPE in (0, 1)
  set @DtlLine = 1;
  Open cur_ChgChkCls2;
  fetch next from cur_ChgChkCls2 into @PayCls2;
  while @@Fetch_Status = 0
    begin
    	declare cur_ChgChkDtl2Dtl cursor for
        select DTL.CODE, DTL.NAME, DTL.CHKNO, IsNull(sum(DTL.total), 0) from CHARGECHKDTL2DTL DTL(nolock), CHARGECHK MST(nolock)
        where mst.chargedate = @CHARGEDATE
          and mst.stat = 100
          and mst.num = dtl.num
          and mst.SALETYPE in (0, 1)
          and dtl.dtlcls = @PayCls2
        group by DTL.CODE, DTL.NAME, DTL.CHKNO
      Open cur_ChgChkDtl2Dtl
      fetch next from cur_ChgChkDtl2Dtl into @DtlDtlCODE, @DtlDtlNAME, @DtlDtlChkNo, @DtlDtlSumTotal;
      set @DtlDtlLine = 1;
      while @@Fetch_Status = 0
        begin
        	insert into CHARGECHKDTL2DTL(NUM, LINE, DTLDTLLINE, DTLCLS, CODE, NAME, CHKNO, TOTAL, NOTE)
        	values(@NewNum, @DtlLine, @DtlDtlLine, @PayCls2, @DtlDtlCODE,@DtlDtlNAME, @DtlDtlChkNo, @DtlDtlSumTotal, NULL);
        	set @DtlDtlLine = @DtlDtlLine + 1;
        	fetch next from cur_ChgChkDtl2Dtl into @DtlDtlCODE, @DtlDtlNAME, @DtlDtlChkNo, @DtlDtlSumTotal;
        end;
      close cur_ChgChkDtl2Dtl;
      deallocate cur_ChgChkDtl2Dtl;

      insert into CHARGECHKDTL2(NUM, LINE, PAYCLS, TOTAL, NOTE)
      select @NewNum, @DtlLine, @PayCls2, IsNull(SUM(DTL.TOTAL), 0), NULL
      from CHARGECHKDTL2 DTL(nolock), CHARGECHK MST(nolock)
      where mst.chargedate = @CHARGEDATE
        and mst.stat = 100
        and mst.num = dtl.num
        and mst.SALETYPE in (0, 1)
        and DTL.PAYCLS = @PayCls2
      set @DtlLine = @DtlLine + 1;
      fetch next from cur_ChgChkCls2 into @PayCls2;
    end;
    close cur_ChgChkCls2;
    deallocate cur_ChgChkCls2;


  set @NewNote = '';
  declare cur_ChgChkNum cursor for
    select NUM
    from CHARGECHK(nolock)
    where CHARGEDATE = @CHARGEDATE
      and STAT = 100
      and SALETYPE in (0, 1);
  Open cur_ChgChkNum;
  fetch next from cur_ChgChkNum into @ChgChkNum;
  while @@Fetch_Status = 0
    begin
    	if @NewNote = ''
      	set @NewNote = '由以下单据合并而来：' + @ChgChkNum;
      else
      	set @NewNote = @NewNote + ', ' + @ChgChkNum;
      fetch next from cur_ChgChkNum into @ChgChkNum;
    end;
  close cur_ChgChkNum;
  deallocate cur_ChgChkNum;

 --Mst
  insert into CHARGECHK(NUM, CHARGEDATE, SALETYPE, STAT, FILLER, FILDATE, CHECKER, CHKDATE, LSTUPDTIME, SHOULDRCVTOTALT0, SHOULDRCVTOTALT1, RCVTOTAL, OTHERTOTAL, NOTE)
  select @NewNum, @CHARGEDATE, 2, 100, @Oper, getdate(), @Oper, getdate(), getdate(), IsNull(sum(SHOULDRCVTOTALT0), 0), IsNull(sum(SHOULDRCVTOTALT1), 0),IsNull(SUM(RCVTOTAL), 0), IsNull(SUM(OTHERTOTAL), 0), @NewNote
  from CHARGECHK(nolock)
  where chargedate = @CHARGEDATE
    and stat = 100
    and SALETYPE in (0, 1);

  declare cur_ChgChkNum cursor for
    select NUM
    from CHARGECHK(nolock)
    where CHARGEDATE = @CHARGEDATE
      and STAT = 100
      and SALETYPE in (0, 1);
  Open cur_ChgChkNum;
  fetch next from cur_ChgChkNum into @ChgChkNum;
  while @@Fetch_Status = 0
    begin
    	update CHARGECHK set STAT = 1400, LSTUPDTIME = getdate() where NUM = @ChgChkNum;
      fetch next from cur_ChgChkNum into @ChgChkNum;
    end;
  close cur_ChgChkNum;
  deallocate cur_ChgChkNum;

  if @intAutoSnd = 1
    exec @vRet = CHARGECHKSEND @NewNum, 1, @oper, @MSG output

  return(@vRet);
end;
GO
