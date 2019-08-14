SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GFTSND_IMPORTSALE]
(
  @piCls varchar(10),
  @piPosNo varchar(10),
  @piFlowNo varchar(14),
  @piMode int,        --处理方式, 0=清空, 1=追加
  @poErrMsg varchar(255) output
)
as
begin
  declare @vRet int
  declare @vPosNo varchar(10)
  declare @vFlowNo varchar(14)

  if @piMode = 0
    delete from TMPGFTSNDSALE where SPID = @@spid

  if @piCls = '收银条'
  begin
    exec @vRet = GFTSND_IMPORTBUY @piPosNo, @piFlowNo, @poErrMsg output
    if @vRet <> 0 return(@vRet)
  end
  else if @piCls = '普通发票'
  begin
    exec HDDEALLOCCURSOR 'c_rtlinv' --确保游标被释放
    declare c_rtlinv cursor for
      select distinct d.POSNO, d.FLOWNO
      from RTLINV m(nolock), RTLINVDTL d(nolock)
      where m.NUM = d.NUM
      and m.NUM = @piFlowNo
    open c_rtlinv
    fetch next from c_rtlinv into @vPosNo, @vFlowNo
    while @@fetch_status = 0
    begin
      exec @vRet = GFTSND_IMPORTBUY @vPosNo, @vFlowNo, @poErrMsg output
      if @vRet <> 0
      begin
        close c_rtlinv
        deallocate c_rtlinv
        return(@vRet)
      end
      fetch next from c_rtlinv into @vPosNo, @vFlowNo
    end
    close c_rtlinv
    deallocate c_rtlinv
  end
  else if @piCls = '预售收银条'
  begin
    exec @vRet = GFTSND_IMPORTPREBUY @piPosNo, @piFlowNo, @poErrMsg output
    if @vRet <> 0 return(@vRet)
  end

  return(0)
end
GO
