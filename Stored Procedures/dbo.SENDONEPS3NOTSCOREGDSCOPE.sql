SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[SENDONEPS3NOTSCOREGDSCOPE]
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
    insert into NPS3NOTSCOREGDSCOPE (ID, SRC, NUM, CLS, STAT, FILDATE, FILLER, SNDTIME, PRNTIME, CHKDATE, CHECKER, LSTUPDTIME, LSTUPDOPER, NOTE, SETTLENO, RECCNT, RCV, RCVTIME, TYPE, NSTAT, NNOTE)
    select @id, @src, NUM, CLS, STAT, FILDATE, FILLER, getdate(), PRNTIME, CHKDATE, CHECKER, LSTUPDTIME, LSTUPDOPER, NOTE, SETTLENO, RECCNT, @rcv, NULL, 0, 0, ''
    from PS3NOTSCOREGDSCOPE(nolock)
    where num = @num and cls = @cls

    insert into NPS3NOTSCOREGDSCOPEDTL(SRC, ID, NUM, CLS, LINE, DEPT, VENDOR, SORT, BRAND, GDGID, BEGINDATE, ENDDATE, NOTE)
    select @src, @id, NUM, CLS, LINE, DEPT, VENDOR, SORT, BRAND, GDGID, BEGINDATE, ENDDATE, NOTE
    from PS3NOTSCOREGDSCOPEDTL(nolock)
    where num = @num and cls = @cls
    return 0
end
GO
