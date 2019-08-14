SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create Procedure [dbo].[PrmOffsetDebit_Add]
(
        @piSettleNo int,           --期号
        @piWrh int,                --仓位
        @piVdrGid int,             --供应商
        @piGdGid int,              --商品
        @piStore int,              --门店
        @piDate datetime,          --日期
        @piAddRQty decimal(24, 4), --应补差数增量
        @piRecal int,              --重算标记 0-不重算; 1-重算
        @piCls varchar(10) = '零售', --销售类型 可选值：'零售'、'批发'
        @PoErrMsg varchar(255) output    --出错信息
) as
begin
  declare
    @opt_PrmOffsetWritetoRpt int,
    @piNum varchar(14),
    @piLine int,
    @piAddRAmt money,
    @piVdrDrptAddAmt money

--先检查补差数是否为零，为零则退出
  if @piAddRQty = 0
    return (0)

--先检查该日对于本商品有没有生效的促销补差协议，没有则退出
  select @piNum = NUM, @piLine = LINE, @piAddRAmt = @piAddRQty * DIFFPRC from PRMOFFSETAGMLAC(nolock)
  where gdgid = @piGdGid
    and store = @piStore
    and rbdate <= @piDate
    and redate >= @piDate
    and DIFFPRC > 0   --补差必须大于0,否则直接退出 WUDIPING ADD 091103
  if @@rowcount = 0
    return (0)

--读取促销补差单审核时是否生成费用单选项。optionvalue = 2 需要记录账款
  exec OptReadInt 727, 'CreateOnCheck', 0, @opt_PrmOffsetWritetoRpt OUTPUT

--若促销补差应结表中不存在对应记录，则插入
  if not exists (select * from PRMOFFSETDEBIT
                 where DATE = @piDate
                 and GDGID = @piGdGid
                 and STORE = @piStore
                 and CLS = @piCls)
  begin
    insert into PRMOFFSETDEBIT(GDGID, STORE, NUM, LINE, DATE, SAMT, SQTY, RECAL, SNDFLAG, CLS)
    values (@piGdGid, @piStore, @piNum, @piLine, @piDate, @piAddRAmt, @piAddRQty, @piRecal, 0, @piCls);
  end
  else begin
  --若促销补差应结表中存在对应记录，则更新
    update PRMOFFSETDEBIT
    set SAMT = SAMT + @piAddRAmt,
        SQTY = SQTY + @piAddRQty,
        NUM = @piNum
    where GDGID = @piGdGid
      and STORE = @piStore
      and DATE = @piDate
      and CLS = @piCls
    if @piRecal = 1
      update PRMOFFSETDEBIT
      set RECAL = @piRecal
      where GDGID = @piGdGid
        and STORE = @piStore
        and DATE = @piDate
        and CLS = @piCls
  end;

  --若选项设置为通过供应商结算单计算，则记录供应商账款报表
  if @opt_PrmOffsetWritetoRpt = 2
  begin
    select @piVdrDrptAddAmt = - @piAddRAmt;
    --记录出货日报(记录DI1-零售核算额)
    if  @piCls = '零售'
      insert into XS (ASETTLENO, ADATE, BWRH, BGDGID, LS_I_B, PARAM)
      values (@piSettleNo, @piDate, @piWrh, @piGdGid, @piVdrDrptAddAmt, 0)
    else if @piCls = '批发'
      insert into XS (ASETTLENO, ADATE, BWRH, BGDGID, WC_I_B, PARAM)
      values (@piSettleNo, @piDate, @piWrh, @piGdGid, @piVdrDrptAddAmt, 0)
    --记录账款报表(记录DT3-应结额)
    exec AppUpdVdrDrpt @store = @piStore, @settleno = @piSettleNo, @date = @piDate, @vdrgid = @piVdrGid,
         @wrh = @piWrh, @gdgid = @piGdGid, @dq1 = 0, @dq2 = 0, @dq3 = 0, @dq4 = 0, @dq5 = 0, @dq6 = 0,
      @dt1 = 0, @dt2 = 0, @dt3 = @piVdrDrptAddAmt, @dt4 = 0, @dt5 = 0, @dt6 = 0, @dt7 = 0, @di2 = @piVdrDrptAddAmt
    --记录库存调整报表(记录DI3-核算调价额)
    if @piVdrDrptAddAmt <> 0
      insert into KC ( ADATE, ASETTLENO, BWRH, BGDGID, TJ_Q, TJ_I )
      values (@piDate, @piSettleNo, @piWrh, @piGdGid, @piAddRQty, @piVdrDrptAddAmt)
  end;
end
GO
