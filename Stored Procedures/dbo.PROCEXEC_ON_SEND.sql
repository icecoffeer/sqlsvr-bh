SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PROCEXEC_ON_SEND]
(
  @piNum varchar(14),
  @piOper varchar(30),
  @poErrMsg varchar(255) output        --出错信息
) as
begin
  declare
    @nID int,
    @nSrc int,
    @nRcvGid int


  select @nRcvGid = ZBGid, @nSrc = UserGid from FASystem(nolock)
  if @@RowCount = 0
  begin
  	set @poErrMsg = '系统信息访问出错。'
    return(1)
  end
  delete from NProcExec where Num = @piNum
  delete from NProcExecRaw where Num = @piNum
  delete from NProcExecProd where Num = @piNum

  exec @nID = SEQNEXTVALUE 'NPROCEXEC'
  insert into NProcExec(ID, SndTime, Rcv, FrcChk, NType, NStat, Num, Bocls, TaskNum,
    Stat, BgnTime, EndTime, Filler, FilDate, ChkTime, ChkEmp, Subject,
    Modifier, LstUpdTime, Note, Algavgtag, SettleNo, Src, PrnTime, Mode)
    select @nID, getdate(), @nRcvGid, 1, 0, 0, Num, Bocls, TaskNum,
      Stat, BgnTime, EndTime, Filler, FilDate, ChkTime, ChkEmp, Subject,
      Modifier, LstUpdTime, Note, Algavgtag, SettleNo, @nSrc, PrnTime, Mode
    from ProcExec(nolock) where Num = @piNum
  insert into NProcExecProd(Src, ID, Num, Line, PscpCode, PscpQty, GdGid, Qty,
    Total, CstPrc, InPrc, RtlPrc, GenQty, Wrh, PscpGid)
    select @nSrc, @nID, Num, Line, PscpCode, PscpQty, GdGid, Qty,
      Total, CstPrc, InPrc, RtlPrc, GenQty, Wrh, PscpGid
    from ProcExecProd(nolock) where Num = @piNum
  insert into NProcExecRaw(Src, ID, Num, Line, PscpCode, PscpQty, GdGid, Qty,
    Total, CstPrc, InvPrc, RtlPrc, MoveQty, Wrh, PscpGid)
    select @nSrc, @nID, Num, Line, PscpCode, PscpQty, GdGid, Qty,
      Total, CstPrc, InvPrc, RtlPrc, MoveQty, Wrh, PscpGid
    from ProcExecRaw(nolock) where Num = @piNum
 --记录发送时间
  update PROCEXEC set SndTime = getdate()
  where NUM = @piNum;
  return (0)
end
GO
