SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GFTSND_DEDUCTONESALE]
(
  @piPosNo varchar(10),
  @piFlowNo varchar(14),
  @piAmount money
) as
begin
  declare @vGdGid int
  declare @vAmt money
  declare @vDeductAmt money
  declare @vCode varchar(18)
  declare @vCount int
  declare @vCost money

  --扣除规则无关的商品
  exec GFTSND_LOADRULEGOODS null
  exec HDDEALLOCCURSOR 'c_salegd' --确保游标被释放
  declare c_salegd cursor for
    select GDGID, AMT, DEDUCTAMT from TMPGFTSNDSALE(nolock)
    where SPID = @@SPID and DEDUCTAMT < AMT
      and POSNO = @piPosNo and FLOWNO = @piFlowNo and GDGID not in (
      select GDGID from TMPGFTSNDRULEGOODS(nolock)
      where SPID = @@SPID
    )
  open c_salegd
  fetch next from c_salegd into @vGdGid, @vAmt, @vDeductAmt
  while @@fetch_status = 0
  begin
    if @piAmount >= @vAmt - @vDeductAmt
    begin
      set @piAmount = @piAmount - (@vAmt - @vDeductAmt)
      update TMPGFTSNDSALE set DEDUCTAMT = @vAmt where SPID = @@spid and POSNO = @piPosNo and FLOWNO = @piFlowNO and GDGID = @vGdGid;
    end else
    begin
      update TMPGFTSNDSALE set DEDUCTAMT = DEDUCTAMT + @piAmount where SPID = @@spid and POSNO = @piPosNo and FLOWNO = @piFlowNO and GDGID = @vGdGid;
      set @piAmount = 0
    end
    if @piAmount <= 0
    begin
      close c_salegd
      deallocate c_salegd
      return(0);
    end
    fetch next from c_salegd into @vGdGid, @vAmt, @vDeductAmt
  end
  close c_salegd
  deallocate c_salegd
  if @piAmount <= 0 return(0)

  --扣除促销标记约束的商品
  exec HDDEALLOCCURSOR 'c_prmtag' --确保游标被释放
  declare c_prmtag cursor for
    select GDGID, AMT, DEDUCTAMT from TMPGFTSNDSALE(nolock)
    where SPID = @@SPID and DEDUCTAMT < AMT
      and POSNO = @piPosNo and FLOWNO = @piFlowNo
      and isnull(PRMTAG, '') in (select NAME from GFTPRMRULELMTDTL
      where RCODE in (select RCODE from TMPGFTSNDRESULT where SPID = @@spid) and LMTNO = 6 and VALUE = '2')
  open c_prmtag
  fetch next from c_prmtag into @vGdGid, @vAmt, @vDeductAmt
  while @@fetch_status = 0
  begin
    if @piAmount >= @vAmt - @vDeductAmt
    begin
      set @piAmount = @piAmount - (@vAmt - @vDeductAmt)
      update TMPGFTSNDSALE set DEDUCTAMT = @vAmt where SPID = @@spid and POSNO = @piPosNo and FLOWNO = @piFlowNO and GDGID = @vGdGid;
    end else
    begin
      update TMPGFTSNDSALE set DEDUCTAMT = DEDUCTAMT + @piAmount where SPID = @@spid and POSNO = @piPosNo and FLOWNO = @piFlowNO and GDGID = @vGdGid;
      set @piAmount = 0
    end
    if @piAmount <= 0 break
    fetch next from c_prmtag into @vGdGid, @vAmt, @vDeductAmt
  end
  close c_prmtag
  deallocate c_prmtag
  if @piAmount <= 0 return(0)

  --按照规则的价值扣除
  exec HDDEALLOCCURSOR 'c_rule' --确保游标被释放
  declare c_rule cursor for
    select RCODE, COST, [COUNT]
    from TMPGFTSNDRESULT(nolock) where SPID = @@SPID order by [COUNT] * COST
  open c_rule
  fetch next from c_rule into @vCode, @vCost, @vCount
  while @@fetch_status = 0
  begin
    exec GFTSND_LOADRULEGOODS @vCode

    exec HDDEALLOCCURSOR 'c_salegd' --确保游标被释放
    declare c_salegd cursor for
      select GDGID, AMT, DEDUCTAMT from TMPGFTSNDSALE
      where SPID = @@SPID and DEDUCTAMT < AMT
        and POSNO = @piPosNo and FLOWNO = @piFlowNo and GDGID in (
        select GDGID from TMPGFTSNDRULEGOODS
        where SPID = @@SPID
      ) for update
    open c_salegd
    fetch next from c_salegd into @vGdGid, @vAmt, @vDeductAmt
    while @@fetch_status = 0
    begin
      if @vDeductAmt < @vAmt
      begin
        if @piAmount > @vAmt - @vDeductAmt
        begin
          set @piAmount = @piAmount - (@vAmt - @vDeductAmt)
          update TMPGFTSNDSALE set DEDUCTAMT = @vAmt where current of c_salegd
        end else
        begin
          update TMPGFTSNDSALE set DEDUCTAMT = DEDUCTAMT + @piAmount where current of c_salegd
          set @piAmount = 0
        end
        if @piAmount <= 0
        begin
          close c_salegd
          deallocate c_salegd
          close c_rule
          deallocate c_rule
          return(0);
        end
      end
      fetch next from c_salegd into @vGdGid, @vAmt, @vDeductAmt
    end
    close c_salegd
    deallocate c_salegd

    fetch next from c_rule into @vCode, @vCost, @vCount
  end
  close c_rule
  deallocate c_rule
  return(0);
end
GO
