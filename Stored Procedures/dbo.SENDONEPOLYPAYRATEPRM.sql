SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[SENDONEPOLYPAYRATEPRM]
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

  insert into NPOLYPAYRATEPRM (ID, SRC, NUM, CLS, STAT, FILDATE, FILLER, CHKDATE, CHECKER, SNDTIME,
    PRNTIME, LSTUPDTIME, LSTUPDOPER, NOTE, RECCNT,
    RCV, RCVTIME, TYPE, NSTAT, NNOTE, SETTLENO, TOPIC, PSETTLENO)
  select @id, @src, NUM, CLS, STAT, FILDATE, FILLER, CHKDATE, CHECKER, getdate(),
    PRNTIME, LSTUPDTIME, LSTUPDOPER, NOTE, RECCNT,
    @rcv, NULL, 0, 0, '', SETTLENO, TOPIC, PSETTLENO
  from POLYPAYRATEPRM(nolock)
    where num = @num and cls = @cls

  if @cls = '批量联销率'
    insert into NPOLYPAYRATEPRMDTL(SRC, ID, NUM, CLS, LINE, DEPT, VENDOR, BRAND, ASTART, AFINISH, POLYPAYRATE, NOTE)
    select @src, @id, NUM, CLS, LINE, DEPT, VENDOR, BRAND, ASTART, AFINISH, POLYPAYRATE, NOTE
    from POLYPAYRATEPRMDTL(nolock)
      where num = @num and cls = @cls
  else if @cls = '商品折扣'
    insert into NPOLYPAYRATEPRMDTL(SRC, ID, NUM, CLS, LINE, DEPT, VENDOR, BRAND, STARTDIS, FINISHDIS, ASTART, AFINISH,
      POLYPAYRATE, NOTE)
    select @src, @id, NUM, CLS, LINE, DEPT, VENDOR, BRAND, STARTDIS, FINISHDIS, ASTART, AFINISH,
      POLYPAYRATE, NOTE
    from POLYPAYRATEPRMDTL(nolock)
      where num = @num and cls = @cls

    return 0
end
GO
