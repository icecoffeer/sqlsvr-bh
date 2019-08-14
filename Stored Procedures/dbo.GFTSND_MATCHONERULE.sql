SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GFTSND_MATCHONERULE]
(
  @piCode varchar(18) --规则代码
)
as
begin
  declare @vQty money
  declare @vAmt money
  declare @vRealQty money
  declare @vRealAmt money
  declare @p int
  declare @vCount int
  declare @vGdCond varchar(8000)
  declare @vGdCond2 varchar(8000)
  declare @vSql varchar(8000)
  declare @vPassQty money
  declare @vPassAmt money
  declare @vLow money
  declare @vHigh money

  select @vQty = QTY, @vAmt = AMT, @vPassQty = PassQty, @vPassAmt = PassAmt from GFTPRMRULE(nolock) where CODE = @piCode;

  --满多少数量或金额
  exec GFTSND_CALCQTYAMT null, null, @vRealQty output, @vRealAmt output

  --增加准入条件判断----
  if @vPassQty > 0 and @vRealQty < @vPassQty return(0)
  if @vPassAmt > 0 and @vRealAmt < @vPassAmt return(0)

  if @vQty > 0
  begin
    set @vCount = floor(@vRealQty/@vQty)
    if @vCount = 0 return(0)
  end;
  if @vAmt > 0
  begin
    set @vCount = floor(@vRealAmt/@vAmt)
    if @vCount = 0 return(0)
  end;

  --搜索商品并计算最大满足规则倍数
  if @vQty = 0 and @vAmt = 0
  begin
    exec HDDEALLOCCURSOR 'c_gftprm' --确保游标被释放
    declare c_gftprm cursor for
    select GDCOND, QTY, AMT, LOW, HIGH from GFTPRMGOODS
    where RCODE = @piCode
    open c_gftprm
    fetch c_gftprm into @vGdCond, @vQty, @vAmt, @vLow, @vHigh
    if @@fetch_status <> 0
    begin
      --如果没有数量金额条件，则不满足
      if @vQty <= 0 and @vAmt <= 0
        set @vCount = 0
      else --如果没有买商品，但也会可能送，自动认为满足一次
        set @vCount = 1
    end else
      set @vCount = 99999
    while @@fetch_status = 0
    begin
      if len(@vGdCond) >= 5
        select @vGdCond2 = substring(@vGdCond, 6, len(@vGdCond)-5)
      else
        select @vGdCond2 = ''
      if rtrim(@vGdCond2) = ''
        set @vGdCond2 = null
      exec GFTSND_CALCQTYAMT null, @vGdCond2, @vRealQty output, @vRealAmt output
      if @vLow > 0
      begin
        if @vRealQty < @vLow
          set @vRealQty = 0
        if @vRealAmt < @vLow
          set @vRealAmt = 0
      end
      if @vHigh > 0
      begin
        if @vRealQty > @vHigh
          set @vRealQty = @vHigh
        if @vRealAmt > @vHigh
          set @vRealAmt = @vHigh
      end
      if @vQty > 0 --数量条件
      begin
        set @p = floor(@vRealQty/@vQty)
        if @p < @vCount
          set @vCount = @p
      end else if @vAmt > 0 --金额条件
      begin
        set @p = floor(@vRealAmt/@vAmt)
        if @p < @vCount
          set @vCount = @p
      end;
      if @vCount = 0
      begin
        close c_gftprm
        deallocate c_gftprm
        return(1)
      end;

      fetch c_gftprm into @vGdCond, @vQty, @vAmt, @vLow, @vHigh
    end
    close c_gftprm
    deallocate c_gftprm
  end

  --如果只有总金额满XXXX的条件，则认为只满足一次
  --如果存在每买XXX个商品，总金额满XXXX的条件，则按实际的商品条件计算满足的次数
  if @vCount = 99999
    set @vCount = 1
  if @vCount > 0
  begin
    if exists(select 1 from TMPGFTSNDRESULT where spid = @@spid and RCODE = @piCode)
      update TMPGFTSNDRESULT set [COUNT] = [COUNT] + @vCount where spid = @@spid and RCODE = @piCode;
    else
      insert into TMPGFTSNDRESULT(SPID, RCODE, [COUNT]) values(@@spid, @piCode, @vCount);
  end;

  return(0);
end
GO
