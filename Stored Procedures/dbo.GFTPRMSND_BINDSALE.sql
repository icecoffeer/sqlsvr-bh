SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GFTPRMSND_BINDSALE]
(
  @piNum varchar(14),
  @piCls varchar(10),
  @piPosNo varchar(10),
  @piFlowNo varchar(14),
  @poErrMsg varchar(255) output
)
as
begin
  declare @vRet int
  declare @vLine int
  declare @vPosNo varchar(10)
  declare @vFlowNo varchar(14)
  declare @vAmt money

  if @piCls = '收银条'
  begin
    --判断是否被其他发放单据引用
    if exists(select 1 from GFTPRMSND m(nolock), GFTPRMSNDBILL b(nolock)
      where m.NUM = b.NUM and m.STAT = 100
      and m.NUM <> @piNum and b.CLS = @piCls
      and b.POSNO = @piPosNo and b.FLOWNO = @piFlowNo)
    begin
      set @poErrMsg = '收银条' + rtrim(@piPosNo) + '-' + rtrim(@piFlowNo) + '已经被其他发放单使用'
      return(1)
    end

    if not exists(select 1 from GFTPRMSND m(nolock), GFTPRMSNDBILL b(nolock)
      where m.NUM = b.NUM and m.STAT = 100
      and m.NUM = @piNum and b.CLS = @piCls
      and b.POSNO = @piPosNo and b.FLOWNO = @piFlowNo)
    begin
      exec @vRet = GFTPRMSND_BINDBUY @piNum, @piPosNo, @piFlowNo, @poErrMsg output
      if @vRet <> 0 return(@vRet)

      select @vLine = isnull(max(LINE), 0) from GFTPRMSNDBILL(nolock) where NUM = @piNum;
      select @vAmt = REALAMT from BUY1 where POSNO = @piPosNo and FLOWNO = @piFlowNo
      insert into GFTPRMSNDBILL(NUM, LINE, CLS, POSNO, FLOWNO, AMT)
      values(@piNum, @vLine + 1, @piCls, @piPosNo, @piFlowNo, @vAmt);
    end else
    begin
      set @poErrMsg = '收银条' + rtrim(@piPosNo) + ', ' + rtrim(@piFlowNo) + '已经包含在发放的销售单据中。'
      return(1)
    end
  end else if @piCls = '普通发票'
  begin
    --判断是否被其他发放单引用
    if exists(select 1 from GFTPRMSNDBILL(nolock) where NUM <> @piNum and CLS = @piCls
      and FLOWNO = @piFlowNo)
    begin
      set @poErrMsg = '普通发票' + rtrim(@piFlowNo) + '已经被其他发放单使用'
      return(1)
    end

    if not exists(select 1 from GFTPRMSNDBILL(nolock) where NUM = @piNum and CLS = @piCls
      and FLOWNO = @piFlowNo)
    begin
      set @vAmt = 0
      exec HDDEALLOCCURSOR 'c_rtlinv' --确保游标被释放
      declare c_rtlinv cursor for
      select distinct POSNO, FLOWNO
      from RTLINVDTL(nolock) where NUM = @piFlowNo
      open c_rtlinv
      fetch next from c_rtlinv into @vPosNo, @vFlowNo
      while @@fetch_status = 0
      begin
        if exists(select 1 from GFTPRMSNDBILL(nolock) where NUM <> @piNum and CLS = '收银条'
          and POSNO = @vPosNo and FLOWNO = @vFlowNo)
        begin
          set @poErrMsg = '收银条' + rtrim(@vPosNo) + '-' + rtrim(@vFlowNo) + '已经被其他发放单使用'
          close c_rtlinv
          deallocate c_rtlinv
          return(1)
        end

        exec @vRet = GFTPRMSND_BINDBUY @piNum, @vPosNo, @vFlowNo, @poErrMsg output
        if @vRet <> 0
        begin
          close c_rtlinv
          deallocate c_rtlinv
          return(@vRet)
        end
        select @vAmt = @vAmt + REALAMT from BUY1 where POSNO = @vPosNo and FLOWNO = @vFlowNo

        fetch next from c_rtlinv into @vPosNo, @vFlowNo
      end
      close c_rtlinv
      deallocate c_rtlinv

      select @vLine = isnull(max(LINE), 0) from GFTPRMSNDBILL(nolock) where NUM = @piNum;
      insert into GFTPRMSNDBILL(NUM, LINE, CLS, POSNO, FLOWNO, AMT)
      values(@piNum, @vLine + 1, @piCls, '', @piFlowNo, @vAmt);
    end else
    begin
      set @poErrMsg = '普通发票' + rtrim(@piFlowNo) + '已经包含在发放的销售单据中。'
      return(1)
    end
  end else if @piCls = '预售收银条'
  begin
    --判断是否被其他发放单据引用
    if exists(select 1 from GFTPRMSND m(nolock), GFTPRMSNDBILL b(nolock)
      where m.NUM = b.NUM and m.STAT = 100
      and m.NUM <> @piNum and b.CLS = @piCls
      and b.POSNO = @piPosNo and b.FLOWNO = @piFlowNo)
    begin
      set @poErrMsg = '预售收银条' + rtrim(@piPosNo) + '-' + rtrim(@piFlowNo) + '已经被其他发放单使用'
      return(1)
    end

    if not exists(select 1 from GFTPRMSND m(nolock), GFTPRMSNDBILL b(nolock)
      where m.NUM = b.NUM and m.STAT = 100
      and m.NUM = @piNum and b.CLS = @piCls
      and b.POSNO = @piPosNo and b.FLOWNO = @piFlowNo)
    begin
      exec @vRet = GFTPRMSND_BINDPREBUY @piNum, @piPosNo, @piFlowNo, @poErrMsg output
      if @vRet <> 0 return(@vRet)

      select @vLine = isnull(max(LINE), 0) from GFTPRMSNDBILL(nolock) where NUM = @piNum;
      select @vAmt = REALAMT from PREBUY1 where POSNO = @piPosNo and FLOWNO = @piFlowNo
      insert into GFTPRMSNDBILL(NUM, LINE, CLS, POSNO, FLOWNO, AMT)
      values(@piNum, @vLine + 1, @piCls, @piPosNo, @piFlowNo, @vAmt);
    end else
    begin
      set @poErrMsg = '预售收银条' + rtrim(@piPosNo) + ', ' + rtrim(@piFlowNo) + '已经包含在发放的销售单据中。'
      return(1)
    end
  end
  return(0)
end
GO
