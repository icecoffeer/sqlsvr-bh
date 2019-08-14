SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GFTPRMSND_BINDBUY]
(
  @piNum varchar(14),
  @piPosNo varchar(10),
  @piFlowNo varchar(14),
  @poErrMsg varchar(255) output
) as
begin
  declare @vLine int
  declare @vGdGid int
  declare @vQty money
  declare @vAmt money
  declare @vFildate datetime

  select @vLine = isnull(max(LINE), 0) from GFTPRMSNDSALE(nolock) where NUM = @piNum;
  exec HDDEALLOCCURSOR 'c_bindsale' --确保游标被释放
  declare c_bindsale cursor for
  select b2.GID, b2.QTY, b2.REALAMT, b1.FILDATE
  from BUY1 b1(nolock), BUY2 b2(nolock)
  where b1.POSNO = @piPosNo and b1.FLOWNO = @piFlowNo
    and b1.POSNO = b2.POSNO and b1.FLOWNO = b2.FLOWNO
  open c_bindsale
  fetch next from c_bindsale into @vGdGid, @vQty, @vAmt, @vFildate
  while @@fetch_status = 0
  begin
    set @vLine = @vLine + 1
    insert into GFTPRMSNDSALE(NUM, LINE, CLS, POSNO, FLOWNO, GDGID, QTY, AMT, SALETIME)
    values(@piNum, @vLine, '收银条', @piPosNo, @piFlowNo, @vGdGid, @vQty, @vAmt, @vFildate)

    fetch next from c_bindsale into @vGdGid, @vQty, @vAmt, @vFildate
  end
  close c_bindsale
  deallocate c_bindsale
  return(0)
end
GO
