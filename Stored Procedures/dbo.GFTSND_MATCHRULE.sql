SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GFTSND_MATCHRULE]
(
  @piCode varchar(18),
  @poErrMsg varchar(255) output
)
as
begin
  declare @vCls varchar(10)
  declare @vPosNo varchar(10)
  declare @vFlowNo varchar(14)
  declare @vBeginTime datetime
  declare @vEndTime datetime
  declare @vTotal money
  declare @vFavTotal money
  declare @vFavRate money
  declare @vCanSum int
  declare @vCount int

  select @vBeginTime = BEGINTIME, @vEndTime = ENDTIME
  from GFTPRMRULE(nolock) where CODE = @piCode;

  --取小票是否可以累计的约束，缺省为'是'
  if exists(select 1 from GFTPRMRULELMTDTL(nolock) where RCODE = @piCode and LMTNO = 1 and VALUE = '0') --小票不能累计
    set @vCanSum = 0  --Fanduoyi 1->0 2004.11.15
  else
    set @vCanSum = 1;
  update TMPGFTSNDSALE set TAG = 0 where SPID = @@spid;

  --对小票及其商品进行检查和扣除
  exec HDDEALLOCCURSOR 'c_gftprmsale' --确保游标被释放
  declare c_gftprmsale cursor for
  select distinct CLS, POSNO, FLOWNO from TMPGFTSNDSALE where SPID = @@spid
  open c_gftprmsale
  fetch next from c_gftprmsale into @vCls, @vPosNo, @vFlowNo
  while @@fetch_status = 0
  begin
    --小票折扣额限制
    select @vFavRate = convert(money, VALUE) from GFTPRMRULELMTDTL(nolock)
    where RCODE = @piCode and LMTNO = 3;
    if (@@rowcount <> 0) and (@vFavRate > 0) and @vCls = '收银条'
    begin
      select @vTotal = sum(REALAMT)
      from BUY2(nolock) where POSNO = @vPosNo and FLOWNO = @vFlowNo
      select @vFavTotal = sum(FAVAMT)
      from BUY21(nolock) where POSNO = @vPosNo and FLOWNO = @vFlowNo and FAVTYPE in ('09', '12')
      if @vFavTotal/(@vTotal + @vFavTotal) > 1 - @vFavRate / 100
      begin
        insert into TMPGFTSNDHINT(SPID, ATIME, RCODE, CONTENT)
        values(@@spid, getdate(), @piCode, '小票[收银机号=' + rtrim(@vPosNo) + ', 流水号=' + rtrim(@vFlowNo)
          + ']折扣率低于' + rtrim(convert(varchar, @vFavRate)) + '，规则不生效');
        fetch next from c_gftprmsale into @vCls, @vPosNo, @vFlowNo
        continue;
      end;
    end;

    --消费卡约束
    if exists(select 1 from HDOPTION(NOLOCK) where MODULENO = 0 and OPTIONCAPTION = 'MemRunMode' and OPTIONVALUE = 'HDCRM')
    begin
      if exists(select 1 from GFTPRMRULELMTDTL l, BUY1 b, CRMCARD c, CRMCARDTYPE d
        where l.RCODE = @piCode and l.LMTNO = 5
          and l.NAME = d.name and l.VALUE = '2'
          and b.CARDCODE = c.CARDNUM
          and b.POSNO = @vPosNo and b.FLOWNO = @vFlowNo
          and d.code = c.CardType)
      begin
        insert into TMPGFTSNDHINT(SPID, ATIME, RCODE, CONTENT)
        select @@spid, getdate(), @piCode, '小票[收银机号=' + rtrim(@vPosNo) + ', 流水号=' + rtrim(@vFlowNo)
          + ']存在消费卡类型=' + rtrim(d.NAME) + '，规则不生效'
        from GFTPRMRULELMTDTL l, BUY11 b, CRMCARD c, CRMCARDTYPE d
        where l.RCODE = @piCode and l.LMTNO = 5
          and l.NAME = d.name and l.VALUE = '2'
          and b.CARDCODE = c.CARDNUM and c.CARDTYPE = d.code
          and b.POSNO = @vPosNo and b.FLOWNO = @vFlowNo;
        fetch next from c_gftprmsale into @vCls, @vPosNo, @vFlowNo
        continue;
      end;
    end else begin
      if exists(select 1 from GFTPRMRULELMTDTL l, BUY1 b, CARD c
        where l.RCODE = @piCode and l.LMTNO = 5
          and l.NAME = c.CARDTYPE and l.VALUE = '2'
          and b.GUEST = c.GID
          and b.POSNO = @vPosNo and b.FLOWNO = @vFlowNo)
      begin
        insert into TMPGFTSNDHINT(SPID, ATIME, RCODE, CONTENT)
        select @@spid, getdate(), @piCode, '小票[收银机号=' + rtrim(@vPosNo) + ', 流水号=' + rtrim(@vFlowNo)
          + ']存在消费卡类型=' + rtrim(t.NAME) + '，规则不生效'
        from GFTPRMRULELMTDTL l, BUY11 b, CARD c, CARDTYPE t
        where l.RCODE = @piCode and l.LMTNO = 5
          and l.NAME = c.CARDTYPE and l.VALUE = '2'
          and b.CARDCODE = c.CODE and c.CARDTYPE = t.CARDTYPE
          and b.POSNO = @vPosNo and b.FLOWNO = @vFlowNo;
        fetch next from c_gftprmsale into @vCls, @vPosNo, @vFlowNo
        continue;
      end;
    end;

    --对于促销标记约束
    update TMPGFTSNDSALE set TAG = 1
    where SPID = @@spid and CLS = @vCls and POSNO = @vPosNo and FLOWNO = @vFlowNo
      and isnull(PRMTAG, '') not in (select NAME from GFTPRMRULELMTDTL
        where RCODE = @piCode and LMTNO = 6 and VALUE = '2')
    select @vCount = isnull(count(1), 0) from TMPGFTSNDSALE
    where SPID = @@spid and CLS = @vCls and POSNO = @vPosNo and FLOWNO = @vFlowNo and TAG = 0
    if @vCount > 0
      insert into TMPGFTSNDHINT(SPID, ATIME, RCODE, CONTENT)
      values(@@spid, getdate(), @piCode, '小票[收银机号=' + rtrim(@vPosNo) + ', 流水号=' + rtrim(@vFlowNo)
        + ']有' + rtrim(convert(varchar, @vCount)) + '条商品因促销标记约束被扣除')

    --如果小票不能累计，则立刻计算，否则累计完成后计算
    if @vCanSum = 0
    begin
      delete from TMPGFTSNDGOODS where SPID = @@spid;
      insert into TMPGFTSNDGOODS(SPID, GDGID, QTY, AMT)
      select @@spid, GDGID, sum(QTY), sum(AMT-DEDUCTAMT)
      from TMPGFTSNDSALE(nolock)
      where SPID = @@spid
        and SALETIME >= @vBeginTime
        and SALETIME <= @vEndTime
        and CLS = @vCls
        and POSNO = @vPosNo
        and FLOWNO = @vFlowNo
        and TAG = 1
      group by GDGID;
      exec GFTSND_MATCHONERULE @piCode
    end

    fetch next from c_gftprmsale into @vCls, @vPosNo, @vFlowNo
  end
  close c_gftprmsale
  deallocate c_gftprmsale

  --如果小票可以累计
  if @vCanSum = 1
  begin
    delete from TMPGFTSNDGOODS where SPID = @@spid;
    insert into TMPGFTSNDGOODS(SPID, GDGID, QTY, AMT) select @@spid, GDGID, sum(QTY), sum(AMT-DEDUCTAMT)
    from TMPGFTSNDSALE(nolock)
    where spid = @@spid
      and SALETIME >= @vBeginTime
      and SALETIME <= @vEndTime
      and TAG = 1
      group by GDGID;
    exec GFTSND_MATCHONERULE @piCode
  end;

  return(0)
end
GO
