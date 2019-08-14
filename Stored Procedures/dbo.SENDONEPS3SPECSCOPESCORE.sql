SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[SENDONEPS3SPECSCOPESCORE]
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
    insert into NPS3SPECSCOPESCORE (ID, SRC, NUM, CLS, STAT, FILDATE, FILLER, SNDTIME, PRNTIME, CHKDATE, CHECKER, LSTUPDTIME, LSTUPDOPER, NOTE, SETTLENO, RECCNT, RCV, RCVTIME, TYPE, NSTAT, NNOTE)
    select @id, @src, NUM, CLS, STAT, FILDATE, FILLER, getdate(), PRNTIME, CHKDATE, CHECKER, LSTUPDTIME, LSTUPDOPER, NOTE, SETTLENO, RECCNT, @rcv, NULL, 0, 0, ''
    from PS3SPECSCOPESCORE(nolock)
    where num = @num and cls = @cls

    insert into NPS3SPECSCOPESCOREDTL(SRC, ID, NUM, CLS, LINE, DEPT, VENDOR, SORT, BRAND, MINAMOUNT, AMOUNT, SCORESORT, SCORE, NSCORE, MAXDISCOUNT, BEGINDATE, ENDDATE, NOTE)
    select @src, @id, NUM, CLS, LINE, DEPT, VENDOR, SORT, BRAND, MINAMOUNT, AMOUNT, SCORESORT, SCORE, NSCORE, MAXDISCOUNT, BEGINDATE, ENDDATE, NOTE
    from PS3SPECSCOPESCOREDTL(nolock)
    where num = @num and cls = @cls

    insert into NPS3SPECSCOPESCOREPROMSUBJOUTDTL(SRC, ID, NUM, CLS, LINE, SUBJCODE, SUBJCLS)
    select @src, @id, NUM, CLS, LINE, SUBJCODE, SUBJCLS
    from PS3SPECSCOPESCOREPROMSUBJOUTDTL(nolock)
    where num = @num and cls = @cls
    return 0
end
GO
