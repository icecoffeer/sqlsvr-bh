SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[edcChk_Buy] (
    @SendDate	datetime,
    @src	int,
    @tgt	int,
	@cls	varchar(50),
    @num	char(10)
)
as
begin
  declare 
    @checkint1 int,
    @realint1 int,
	@usergid	int,
	@zbgid	int
	
  select @usergid = usergid, @zbgid = zbgid from system(nolock)
  if @usergid <> @zbgid return 0

  select @checkint1 = checkint1 from shouldexchgdatadtl(nolock)
  where senddate = @senddate 
    and src = @src and tgt = @tgt
    and cls = @cls and num = @num
  select @realint1 = count(*) from storebuy1(nolock) 
  where storegid = @src
  if @@rowcount = 0 return 0

  if @realint1 <> @checkint1
  	update shouldexchgdatadtl set finished = 0, note = @cls + '[' + @num + ']和本地明细数不一致'
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
