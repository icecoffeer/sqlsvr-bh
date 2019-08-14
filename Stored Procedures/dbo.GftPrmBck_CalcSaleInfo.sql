SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GftPrmBck_CalcSaleInfo]
(
  @piGftSndNum varchar(14),
  @piCls varchar(10),
  @piPosNo varchar(10),
  @piFlowNo varchar(14),
  @poErrMsg varchar(255) output
)
as
begin
  declare @GftSndNum varchar(14)
  declare @ret int
  declare @tPosno varchar(10)
  declare @tFlowno varchar(14)

  set @ret = 0

  select Top 1 @GftSndNum = a.num from gftprmsndbill a(nolock), GFTPRMSND b(nolock), GFTPRMSNDGIFT c(nolock)
  where a.num = @piGftSndNum and a.cls = @piCls and a.PosNo = @piPosNo and a.FlowNo = @piFlowNo
    and a.num = b.num and b.stat = 100
    and a.num = c.num and not exists (select 1 from GFTPRMSNDGIFT(nolock) where BCKQTY <> 0 and num = a.num)
  order by b.LSTUPDTIME

  declare c_sndbill cursor for select posno, flowno from gftprmsndbill where num = @GftSndNum
  open c_sndbill
  fetch next from c_sndbill into @tPosno, @tFlowno
  while @@fetch_status = 0
  begin
    EXEC @ret = GFTSND_IMPORTBUY @tPosno, @tFlowno, @poErrMsg output
    if @ret <> 0
    begin
      break
    end
    fetch next from c_sndbill into @tPosno, @tFlowno
  end
  close c_sndbill
  deallocate c_sndbill

  return(@ret)
end
GO
