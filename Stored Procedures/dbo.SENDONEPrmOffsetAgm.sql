SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[SENDONEPrmOffsetAgm]
(
  @num      varchar(14),
  @cls      varchar(10),
  @src      int,
  @rcv      int,
  @err_msg  varchar(255) output
)
as
begin
  declare
    @id int
  execute GetNetBillId @id output
  insert into NPrmOffsetAgm (SRC, ID, NUM, SETTLENO, STAT, VDRGID, BEGINDATE,
    ENDDATE, OFFSETVIEW, PSR, DeptLmt, LAUNCH, COVERALL, FILDATE, FILLER,
    CHKDATE, CHECKER, RECCNT, NOTE, LSTUPDTIME, SNDTIME, PRNTIME,
    RCV, RCVTIME, TYPE, NSTAT, NNOTE)
  select @src, @ID, NUM, SETTLENO, STAT, VDRGID, BEGINDATE,
    ENDDATE, OFFSETVIEW, PSR, DeptLmt, LAUNCH, COVERALL, FILDATE, FILLER,
    CHKDATE, CHECKER, RECCNT, NOTE, LSTUPDTIME, GETDATE(), PRNTIME,
    @rcv, NULL, 0, 0, ''
  from PrmOffsetAgm(nolock)
  where num = @num
  insert into NPrmOffsetAgmDTL(SRC, ID, NUM, LINE, GDGID, MUNIT, QPC, QPCSTR,
    AGMCNTINPRC, AGMPRC, DIFFPRC, TOPQTY, TOPAMT, ASTART, AFINISH, NOTE)
  select @src, @id, NUM, LINE, GDGID, MUNIT, QPC, QPCSTR,
    AGMCNTINPRC, AGMPRC, DIFFPRC, TOPQTY, TOPAMT, ASTART, AFINISH, NOTE
  from PrmOffsetAgmDTL(nolock)
  where num = @num
  return 0
end
GO
