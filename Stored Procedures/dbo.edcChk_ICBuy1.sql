SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[edcChk_ICBuy1] (
    @SendDate	datetime,
    @src	int,
    @tgt	int,
	@cls	varchar(50),
    @num	char(10)
)
as
begin
  declare 
    @Flowno varchar(20),
    @Posno varchar(20),
    @checkint1 int,
    @usergid int,
    @zbgid int
	select @Flowno = substring(@num,1,12)
	select @PosNO = substring(@num,13,20)

  select @usergid = usergid, @zbgid = zbgid from system(nolock)
  if @usergid <> @zbgid return 0
  
	if exists (select 1 from icbuy1 b1 (nolock)
	where b1.store = @src and b1.flowno = @flowno and b1.posno = @posno) 
	begin
	    select @checkint1 = checkint1 from shouldexchgdatadtl(nolock)
	    where senddate = @senddate 
	    	and src = @src and tgt = @tgt
    		and cls = @cls and num = @num
	    if @@rowcount = 0 return 0
		if (select count(*) from icbuy2 (nolock)
			where store = @src and flowno = @flowno and posno = @posno)<>@checkint1
	    	update shouldexchgdatadtl set finished = 0, note = @cls + '[' + @num + ']和本地明细数不一致'
		    where senddate = @senddate 
    			and src = @src and tgt = @tgt
    			and cls = @cls and num = @num
	end else
    	update shouldexchgdatadtl set finished = 1
	    where senddate = @senddate 
    		and src = @src and tgt = @tgt
    		and cls = @cls and num = @num
end
GO
