SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[edcChk_StkIn] (
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
    @newnum char(10),
    @realint1 int,
    @realint2 int,
    @realdata1 money,
    @checkint1 int,
    @checkint2 int,
    @checkdata1 money,
    @note varchar(255)

  select @usergid = usergid, @zbgid = zbgid from system(nolock)
  if @usergid <> @zbgid return 0
  
    select @checkint1 = checkint1, @checkint2 = checkint2, @checkdata1 = checkdata1
    from shouldexchgdatadtl(nolock)
    where senddate = @senddate 
    	and src = @src and tgt = @tgt
    	and cls = @cls and num = @num
    select @realint1 = reccnt, @realint2 = stat, @realdata1 = total
    from stkout(nolock)
    where src = @src and srcnum = @num and cls = '配货'
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
GO
