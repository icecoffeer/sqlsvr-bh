SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[edcChk_ICCardBlkLst] (
    @SendDate	datetime,
    @src	int,
    @tgt	int,
	@cls	varchar(50),
    @num	char(10)
)
as
begin
  declare @checkint1 int,
    @usergid int,
    @zbgid int

  select @usergid = usergid, @zbgid = zbgid from system(nolock)
  if @usergid = @zbgid return 0
  
	select @checkint1 = checkint1 from shouldexchgdatadtl(nolock)
	where senddate = @senddate 
		and src = @src and tgt = @tgt
		and cls = @cls and num = @num
    if @@rowcount = 0 return 0
	if (select count(*) from ICCARDBLKLST (nolock)) <> @checkint1 
		update shouldexchgdatadtl set finished = 0, note = @cls + '[' + @num + ']和本地记录数不一致'
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
