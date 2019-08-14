SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create Procedure [dbo].[PRMOFFSETBAL]
(
  @num varchar(14),
  @cls varchar(10),
  @toStat int,  --110 作废
  @Oper varchar(30),
  @Msg varchar(255) output
) as
begin
  declare
    @return_status int,
    @stat int,
    @m_launch datetime,
    @vdrgid int,
    @igatheringmode int,
    @sgatheringmode varchar(10),
    @intUseCNTR tinyint,
    @AgmTableName varchar(32), --来源促销补差协议类型
    @curdate datetime, --记录到供应商账款的日期
    @settleno int, --记录到供应商账款的期号
    @storegid int, --补差门店
    @gdgid int, --补差商品
    @RAmt money, --补差金额的倒数，用来记录到供应商账款报表
    @PayDirect smallInt, --收付方向 1=收款 -1=付款
    @CreateOnCheck int, --促销补差单审核时是否生成费用单选项。optionvalue = 0-不生成; 1-生成费用单; 2-不生成费用单，但需要记录账款
    @vAgmNum char(14);

  select @return_status = 0;

  exec OptReadInt 0, 'UseCNTR', 0, @intUseCNTR output;
  --读取促销补差单审核时是否生成费用单选项。optionvalue = 0-不生成; 1-生成费用单; 2-不生成费用单，但需要记录账款
  exec OptReadInt 727, 'CreateOnCheck', 0, @CreateOnCheck OUTPUT;

  select
    @stat = STAT,
    @settleno = settleno,
    @curdate = convert(datetime, convert(char,CHKDATE,102)),
    @PayDirect = PAYDIRECT,
    @vdrgid = VDRGID
  from PRMOFFSET(nolock) where NUM = @num;
  if (@stat <> 100)
  begin
    set @Msg = '作废的不是已审核的单据。';
    return(1)
  end

  --取促销补差来源协议号，因目前只有返点协议需要，暂不考虑来源单据有多张的情况
  if @PayDirect = -1
  begin
    select top 1 @AgmTableName = AGMTABLENAME, @vAgmNum = AGMNUM
    from PRMOFFSETDTL(nolock) where NUM = @num;
    --修改来源促销返点协议状态
    if @AgmTableName = 'PRMRTNPNTAGM'
    begin
      update PRMRTNPNTAGM set RTNSTAT = 0 where NUM = @vAgmNum
      update PRMRTNPNTAGM set STAT = 100 where NUM = @vAgmNum
    end
  end

  if @intUseCNTR = 1
  begin
    if exists (
    select 1 from cntrpaycashdtl c, CHGBOOK b, PrmOffset p
      where c.ChgType = '费用单' and c.SrcNum = b.Num and b.SrcCls = '促销补差单' and b.SrcNum = p.Num and p.Num = @num)
    begin
      set @Msg = '相关费用单据已被付款单或交款单录入并回写。';
      return(1)
    end

    --先作废相关费用单
    declare @ChgNum varchar(14)
    declare @ChgStat int
    declare @OperGid int
    declare c_Chg cursor for
      select b.Num from CHGBOOK b, PrmOffset p where b.SrcCls = '促销补差单' and b.SrcNum = p.Num and p.Num = @num
    open c_Chg
    fetch next from c_Chg into @ChgNum
    while @@fetch_status = 0
    begin
      select @OperGid = GID  from EMPLOYEE(nolock) where (rtrim(NAME) + '[' + rtrim(CODE) + ']') = @Oper
      select @ChgStat = STAT from CHGBOOK where NUM = @ChgNum
      if @ChgStat = 500
        exec @return_status = CHGBOOKDLT @ChgNum, @Oper, 'NOSEND', 510, @Msg output
      else if @ChgStat = 0
      begin
        --由于PCT_CHGBOOK_REMOVE不允许删除自动生成的单据，因此只能在此直接删除
        --exec @return_status = PCT_CHGBOOK_REMOVE @ChgNum, @OperGid, @Msg output
        delete from CHGBOOK where NUM = @ChgNum
        delete from CHGBOOKLOG where NUM = @ChgNum
      end
      else if @ChgStat > 0
      begin
        set @Msg = '相关费用单不是未审核或者审核状态，不能删除或者作废。'
        set @return_status = 1
      end
      if @return_status <> 0 break
      fetch next from c_Chg into @ChgNum
    end
    close c_Chg
    deallocate c_Chg
    if @return_status <> 0
    begin
      set @Msg = '作废相关费用单据时出错：' + @Msg
      return(@return_status)
    end
  end;

 /*当CreateOnCheck = 2时，还应在作废时扣减供应商账款报表(应结)，*/
  if @PayDirect = -1 and @CreateOnCheck = 2
  begin
    --若选项设置为通过供应商结算单计算，则记录供应商账款报表
    declare c_Dtl cursor for select STOREGID, GDGID, -RAMT from PRMOFFSETDTLDTL(nolock)
      where NUM = @num
    open c_Dtl
    fetch next from c_Dtl into @storegid, @gdgid, @RAmt
    while @@fetch_status = 0
    begin
      --记录出货日报(记录DI1-零售核算额)
      insert into XS (ASETTLENO, ADATE, BWRH, BGDGID, LS_I_B, PARAM)
      values (@SettleNo, @curdate,1, @gdgid, @RAmt, 0)

      --记录账款报表(记录DT3-应结额)
      exec AppUpdVdrDrpt @store = @StoreGid, @settleno = @SettleNo, @date = @curdate, @vdrgid = @VdrGid,
        @wrh = 1, @gdgid = @gdgid, @dq1 = 0, @dq2 = 0, @dq3 = 0, @dq4 = 0, @dq5 = 0, @dq6 = 0,
        @dt1 = 0, @dt2 = 0, @dt3 = @RAmt, @dt4 = 0, @dt5 = 0, @dt6 = 0, @dt7 = 0, @di2 = @RAmt;

      --记录库存调整报表(记录DI3-核算调价额)
      if @RAmt <> 0
        insert into KC ( ADATE, ASETTLENO, BWRH, BGDGID, TJ_Q, TJ_I )
        values (@curdate, @SettleNo, 1, @gdgid, 0, @RAmt)

      fetch next from c_Dtl into @storegid, @gdgid, @RAmt;
    end
    close c_Dtl
    deallocate c_Dtl
  end;

  --修改已结数据
  exec PRMOFFSETLENDUPD @num, -1;

  --修改状态
  declare @curStat int
  select @curStat = STAT from PrmOffset (nolock) where NUM = @Num
  Update PrmOffset set Stat = 110 where num = @num
  exec PrmOffsetADDLOG @Num, @curStat, 110, @Oper
  return (0)
end
GO
