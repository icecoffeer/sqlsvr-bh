SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GFTSND_RULECOST]
(
  @piCode varchar(50),
  @poCost money output
) as
begin
  declare @vGroupID int
  declare @vQty money
  declare @vAmt money
  declare @vCost money

  set @poCost = 0
  exec HDDEALLOCCURSOR 'c_group' --确保游标被释放
  declare c_group cursor for
    select GROUPID, QTY, AMT from GFTPRMGIFT(nolock) where RCODE = @piCode
  open c_group
  fetch next from c_group into @vGroupID, @vQty, @vAmt
  while @@fetch_status = 0
  begin
    if @vQty > 0
    begin
      select @vCost = max(g.MKTINPRC - d.PAYPRC) * @vQty
      from GFTPRMGIFTDTL d(nolock), GOODS g(nolock)
      where d.RCODE = @piCode
        and d.GROUPID = @vGroupID
        and d.GFTGID = g.GID
    end else if @vAmt > 0
    begin
      set @vCost = @vAmt
    end else
    begin
      select @vCost = isnull(max((g.MKTINPRC - d.PAYPRC) * d.QTY), 0)
      from GFTPRMGIFTDTL d(nolock), GOODS g(nolock)
      where d.RCODE = @piCode
        and d.GROUPID = @vGroupID
        and d.GFTGID = g.GID
    end
    set @poCost = @poCost + @vCost

    fetch next from c_group into @vGroupID, @vQty, @vAmt
  end
  close c_group
  deallocate c_group

  return(0)
end
GO
