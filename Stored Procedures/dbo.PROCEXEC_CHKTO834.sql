SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PROCEXEC_CHKTO834]
(
  @Num varchar(14),
  @Oper varchar(30),
  @Cls varchar(10),
  @ToStat int,
  @Msg varchar(255) output
) as
begin
  declare
    @vStat int,
    @vNewNum varchar(14),
    @vRet int,
    @vMode int,
    @vLine int,
    @vAddNote varchar(255),
    @vPscpCode varchar(40),
    @GdGid int,
    @Qty money,
    @Total money,
    @CstPrc money,
    @InvPrc money,
    @InPrc money,
    @RtlPrc money,
    @Wrh int,
    @Pscpgid int

  select @vStat = Stat  from ProcExec(nolock) where Num = @Num
  if @@RowCount = 0
  begin
    Set @Msg = '取加工入库单(' + @Num + ')失败！'
    return(1)
  end

  if @vStat <> 100
  begin
    Set @Msg = '此单据不是审核单据, 不能变更！'
    return(1)
  end

  select @vMode = Mode from ProcExec(nolock) where Num = @Num
  if @vMode = 0
  begin
    Set @Msg = '混合型模式单据, 不能拆分！'
    return(1)
  end

  declare @raw int,@prod int
  select @raw=count(distinct pscpgid) from ProcExecRaw(nolock) where Num = @Num
  select @prod=count(distinct pscpgid) from ProcExecProd(nolock) where Num = @Num
  if @raw=1 and @prod=1
  begin
    Set @Msg = '此单据不必拆分，请直接发送!'
    return(1)
  end

  declare c_Recipe cursor for select distinct PscpCode from ProcExecRaw(nolock) where Num = @Num
  open c_Recipe
  fetch next from c_Recipe into @vPscpCode
  while @@fetch_status = 0
  begin
    exec @vRet = GenNextBillNumEx '', 'ProcExec', @vNewNum output
    if @vRet <> 0
    begin
      Set @Msg = '生成加工入库单单号失败！'
      close c_Recipe
      deallocate c_Recipe
      return(1)
    end
    if @vAddNote = ''
      set @vAddNote = @vNewNum + ';'
    else
      set @vAddNote = @vAddNote + @vNewNum + ';'

    insert into ProcExec(Num, BoCls, TaskNum, Stat, BgnTime, EndTime,
      Filler, FilDate, Mode, Subject, Note, Algavgtag,
      SettleNo, Modifier, LstUpdTime, Src, Chkemp, ChkTime)
      select @vNewNum, BoCls, TaskNum, 300, BgnTime, EndTime,
      Filler, FilDate, Mode, Subject, Note + '(从任务单：' + @Num + ' 拆分而来)', Algavgtag,
      SettleNo, Modifier, LstUpdTime, Src, Chkemp, ChkTime
      from ProcExec(nolock) where Num = @Num
    set @vLine = 1
    declare c_Raw cursor for select GdGid, Qty, Total, CstPrc, InvPrc, RtlPrc, Wrh, PscpGid from ProcExecRaw(nolock) where Num = @Num and PscpCode = @vPscpCode
    open c_Raw
    fetch next from c_Raw into @GdGid, @Qty, @Total, @CstPrc, @InvPrc, @RtlPrc, @Wrh, @Pscpgid
    while @@fetch_status = 0
    begin
      insert into ProcExecRaw(Num, Line, PscpCode, GdGid, Qty, Total, CstPrc, InvPrc, RtlPrc, Wrh, PscpGid)
        values(@vNewNum, @vLine, @vPscpCode, @GdGid, @Qty, @Total, @CstPrc, @InvPrc, @RtlPrc, @Wrh, @Pscpgid)
      set @vLine = @vLine + 1
      fetch next from c_Raw into @GdGid, @Qty, @Total, @CstPrc, @InvPrc, @RtlPrc, @Wrh, @Pscpgid
    end
    close c_Raw
    deallocate c_Raw

    set @vLine = 1
    declare c_Product cursor for select GdGid, Qty, Total, CstPrc, InPrc, RtlPrc, Wrh, PscpGid from ProcExecProd(nolock) where Num = @Num and PscpCode = @vPscpCode
    open c_Product
    fetch next from c_Product into @GdGid, @Qty, @Total, @CstPrc, @InPrc, @RtlPrc, @Wrh, @Pscpgid
    while @@fetch_status = 0
    begin
      insert into ProcExecProd(Num, Line, PscpCode, GdGid, Qty, Total, CstPrc, InPrc, RtlPrc, Wrh, Pscpgid)
        values(@vNewNum, @vLine, @vPscpCode, @GdGid, @Qty, @Total, @CstPrc, @InPrc, @RtlPrc, @Wrh, @Pscpgid)
      set @vLine = @vLine + 1
      fetch next from c_Product into @GdGid, @Qty, @Total, @CstPrc, @InPrc, @RtlPrc, @Wrh, @Pscpgid
    end
    close c_Product
    deallocate c_Product

    fetch next from c_Recipe into @vPscpCode
  end
  close c_Recipe
  deallocate c_Recipe

  --更新单据信息
  update ProcExec set Stat = 834, Modifier = @Oper, LstUpdTime = Getdate(), Note = Note + '(拆分成单据：' + @vAddNote + ')'
  where Num = @Num
  exec PROCEXEC_ADD_LOG @Num, 100, 834, @Oper, ''
  return(0)
end
GO
