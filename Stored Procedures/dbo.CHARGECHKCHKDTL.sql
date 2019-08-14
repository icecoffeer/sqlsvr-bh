SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[CHARGECHKCHKDTL]
(
  @num varchar(14),
  @ToStat int,
  @Oper Varchar(30),
  @errmsg varchar(200)='' output
) as
begin
  declare
    @return_status int,
    @ShouldRcvTotalT0 money,
    @ShouldRcvTotalT1 money,
    @RcvTotal money,
    @OtherTotal money,
    @old_stat smallint,
    @PayCls int,
    @Line int,
    @DtlDtlTotal money,
    @SaleType int,
    @Dtl2DtlTotal money

  select
    @return_status = 0;

  select @SaleType = SALETYPE, @ShouldRcvTotalT0 = SHOULDRCVTOTALT0, @ShouldRcvTotalT1 = SHOULDRCVTOTALT1, @RcvTotal = RCVTOTAL, @OtherTotal = OTHERTOTAL
  from CHARGECHK
  where NUM = @num;

  if @RcvTotal = @ShouldRcvTotalT0 + @ShouldRcvTotalT1 + @OtherTotal
    update CHARGECHK
    set stat = @TOSTAT, LstUpdTime = Getdate(), checker = @OPER, chkdate = getdate()
    where num = @num;
  else
    begin
      set @errmsg = '实收总额不等于应收总额 + 其它业务总额，不允许审核';
      return(2)
    end;

  select @DtlDtlTotal = ISNULL(SUM(TOTAL), 0) from CHARGECHKDTLDTL(nolock)
  where NUM = @num

  if @DtlDtlTotal <> @RcvTotal
    begin
      set @errmsg = '结算类型' + cast(@PayCls as varchar(20)) + '的二级明细总金额不等于该单据的实收总金额，不允许审核';
      return(3);
    end;

  select @Dtl2DtlTotal = ISNULL(SUM(TOTAL), 0) from CHARGECHKDTL2DTL(nolock)
  where NUM = @num

  if @Dtl2DtlTotal <> @OtherTotal
    begin
      set @errmsg = '其它业务往来' + cast(@PayCls as varchar(20)) + '的二级明细总金额不等于其它业务往来总金额，不允许审核';
      return(4);
    end;

  declare cur_Dtl cursor for
    select LINE, PAYCLS, RCVTOTAL from CHARGECHKDTL(nolock)
    where NUM = @num;
  open cur_Dtl;
  fetch next from cur_Dtl into @Line, @PayCls, @RcvTotal;
  while @@Fetch_Status = 0
    begin
    	select @DtlDtlTotal = ISNULL(SUM(TOTAL), 0) from CHARGECHKDTLDTL(nolock)
    	where NUM = @num
    	  and LINE = @Line
    	  and DTLCLS = @PayCls;
    	if @DtlDtlTotal <> @RcvTotal
    	  begin
          set @errmsg = '结算类型' + cast(@PayCls as varchar(20)) + '的二级明细总金额不等于该结算类型的实收金额，不允许审核';
          return(5);
    	  end;
    	fetch next from cur_Dtl into @Line, @PayCls, @RcvTotal;
    end;
  close cur_Dtl;
  deallocate cur_Dtl;

  declare cur_Dtl2 cursor for
    select LINE, PAYCLS, TOTAL from CHARGECHKDTL2(nolock)
    where NUM = @num;
  open cur_Dtl2;
  fetch next from cur_Dtl2 into @Line, @PayCls, @OtherTotal;
  while @@Fetch_Status = 0
    begin
    	select @Dtl2DtlTotal = ISNULL(SUM(TOTAL), 0) from CHARGECHKDTL2DTL(nolock)
    	where NUM = @num
    	  and LINE = @Line
    	  and DTLCLS = @PayCls;
    	if @Dtl2DtlTotal <> @OtherTotal
    	  begin
          set @errmsg = '其它业务往来的二级明细总金额不等于该其它业务往来的总金额，不允许审核';
          return(5);
    	  end;
    	fetch next from cur_Dtl2 into @Line, @PayCls, @OtherTotal;
    end;
  close cur_Dtl2
  deallocate cur_Dtl2;

  return @return_status
end
GO
