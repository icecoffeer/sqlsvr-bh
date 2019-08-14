SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GFTSND_IMPORTBUY]
(
  @piPosNo varchar(10),
  @piFlowNo varchar(14),
  @poErrMsg varchar(255) output
)
as
begin
  declare @vGdGid int
  declare @vQty money
  declare @vTotal money

  delete from TMPGFTSNDSALE where SPID = @@spid and POSNO = @piPosNo and FLOWNO = @piFlowNo;
  insert into TMPGFTSNDSALE(SPID, CLS, POSNO, FLOWNO, GDGID, QTY, AMT, SALETIME, TAG, DEDUCTAMT, PRMTAG)
  select @@spid, '收银条', @piPosNo, @piFlowNo, b2.GID, sum(b2.QTY), sum(b2.REALAMT), b1.FILDATE, 0, 0, b2.PRMTAG
  from BUY1 b1(nolock), BUY2 b2(nolock)
  where b1.POSNO = @piPosNo and b1.FLOWNO = @piFlowNo
    and b1.POSNO = b2.POSNO and b1.FLOWNO = b2.FLOWNO
  group by b1.FILDATE, b2.GID, b2.PRMTAG

  --扣除退货金额
  exec HDDEALLOCCURSOR 'c_bck' --确保游标被释放
  declare c_bck cursor for
  select d.GDGID, d.QTY, d.TOTAL
  from STKOUTBCK m(nolock), STKOUTBCKDTL d(nolock)
  where m.CLS = d.CLS and m.NUM = d.NUM
    and m.CLS = '零售' and m.GENBILL = 'BUY1'
    and m.GENCLS = @piPosNo and m.GENNUM = @piFlowNo
    and m.STAT = 1
  open c_bck
  fetch next from c_bck into @vGdGid, @vQty, @vTotal
  while @@fetch_status = 0
  begin
    update TMPGFTSNDSALE set
      QTY = QTY - @vQty,
      AMT = AMT - @vTotal
    where SPID = @@spid and POSNO = @piPosNo
      and FLOWNO = @piFlowNo and GDGID = @vGdGid

    fetch next from c_bck into @vGdGid, @vQty, @vTotal
  end
  close c_bck
  deallocate c_bck

  return(0)
end
GO
