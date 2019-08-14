SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[edcChk_CstDRpt] (
    @SendDate	datetime,
    @src	int,
    @tgt	int,
	@cls	varchar(50),
    @num	char(10)
)
as
begin
  declare 
    @usergid int,
    @zbgid int,
    @realint1 int,
    @realint2 int,
    @realint3 int,
    @checkint1 int,
    @checkint2 int,
    @checkint3 int,
    @realdata1 money,
    @realdata2 money,
    @realdata3 money,
    @checkdata1 money,
    @checkdata2 money,
    @checkdata3 money,
    @note varchar(255) 

  select @usergid = usergid, @zbgid = zbgid from system(nolock)
  if @usergid <> @zbgid return 0
  
    select @checkint1 = checkint1, @checkdata1 = checkdata1, @checkdata2 = checkdata2
    from shouldexchgdatadtl(nolock)
    where senddate = @senddate 
    	and src = @src and tgt = @tgt
    	and cls = @cls and num = @num
    select @realint1 = count(adate), 
    	@realdata1 = convert(decimal(20,2),sum(dq1+dq2+dq3)),
    	@realdata2 = convert(decimal(20,2),sum(dt1+dt2+dt3))
    from cstdrpt(nolock)
    where astore = @src and adate = @senddate
    group by adate
    if @@rowcount = 0 return 0

    if @realint1 <> @checkint1
    	update shouldexchgdatadtl set finished = 0, note = @cls + '[' + @num + ']和本地明细数不一致'
	    where senddate = @senddate 
    		and src = @src and tgt = @tgt
    		and cls = @cls and num = @num
    else if (@realdata1 <> @checkdata1) or (@realdata2 <> @checkdata2)
    	update shouldexchgdatadtl set finished = 0, note = @cls + '[' + @num + ']和本地金额不一致'
	    where senddate = @senddate 
    		and src = @src and tgt = @tgt
    		and cls = @cls and num = @num
    else
    	update shouldexchgdatadtl set finished = 1
	    where senddate = @senddate 
    		and src = @src and tgt = @tgt
    		and cls = @cls and num = @num
end
GO
