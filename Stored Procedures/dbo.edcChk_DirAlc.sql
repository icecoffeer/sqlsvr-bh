SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[edcChk_DirAlc] (
    @SendDate	datetime,
    @src	int,
    @tgt	int,
    @cls	varchar(50),
    @num	char(10)
)
as
begin
  declare
    @newnum char(10),
    @realint1 int,
    @realint2 int,
    @realdata1 money,
    @checkint1 int,
    @checkint2 int,
    @checkdata1 money,
    @note varchar(255),
    @usergid int,
    @zbgid int,
    @realcls char(10)

  if @cls = '直配进'
    set @realcls = '直配出'
  else if @cls = '直配出'
    set @realcls = '直配进'
  else if @cls = '直配进退'
    set @realcls = '直配出退'
  else if @cls = '直配出退'
    set @realcls = '直配进退'

  select @usergid = usergid, @zbgid = zbgid from system(nolock)
  if (@cls in ('直配进', '直配进退') and @usergid = @zbgid)    
    or (@cls in ('直配出', '直配出退') and @usergid <> @zbgid)
  begin
    select @checkint1 = checkint1, @checkint2 = checkint2, @checkdata1 = checkdata1
    from shouldexchgdatadtl(nolock)
    where senddate = @senddate 
    	and src = @src and tgt = @tgt
    	and cls = @cls and num = @num
    select @realint1 = reccnt, @realint2 = stat, @realdata1 = total
    from diralc(nolock)
    where src = @src and srcnum = @num and cls = @realcls
    if @@rowcount = 0
    	update shouldexchgdatadtl set finished = 0, note = @cls + '[' + @num + ']未收到'
	    where senddate = @senddate 
    		and src = @src and tgt = @tgt
    		and cls = @cls and num = @num
    else if @realint1 <> @checkint1
    	update shouldexchgdatadtl set finished = 0, note = @cls + '[' + @num + ']和本地状态不一致'
	    where senddate = @senddate 
    		and src = @src and tgt = @tgt
    		and cls = @cls and num = @num
    else if @realint2 <> @checkint2
    	update shouldexchgdatadtl set finished = 0, note = @cls + '[' + @num + ']和本地明细数不一致'
	    where senddate = @senddate 
    		and src = @src and tgt = @tgt
    		and cls = @cls and num = @num
    else if @realdata1 <> @checkdata1
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
end
GO
