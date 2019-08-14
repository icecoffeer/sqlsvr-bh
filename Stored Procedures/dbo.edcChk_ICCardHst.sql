SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[edcChk_ICCardHst] (
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
    @checkdata3 money

  select @usergid = usergid, @zbgid = zbgid from system(nolock)
  if @usergid <> @zbgid return 0
  
    select @checkint1 = checkint1, @checkint2 = checkint2, @checkint3 = checkint3,
    	@checkdata1 = checkdata1, @checkdata2 = checkdata2, @checkdata3 = checkdata3
    from shouldexchgdatadtl(nolock)
    where senddate = @senddate 
    	and src = @src and tgt = @tgt
    	and cls = @cls and num = @num
	select @Realint1 = isnull(sum(case ih.action when '消费' then 1 else 0 end), 0),
		@Realint2 = isnull(sum(case ih.action when '充值' then 1 else 0 end), 0),
		@Realint3 = isnull(sum(case ih.action when '转储' then 1 else 0 end), 0),
		@Realdata1 = isnull(sum(case ih.action when '消费' then occur else 0 end), 0),
		@RealData2 = isnull(sum(case ih.action when '充值' then occur else 0 end), 0),
		@RealData3 = isnull(sum(case ih.action when '转储' then occur else 0 end), 0)
	from iccardhst ih (nolock)
	where store = @src and cardnum = @num 
		and ih.fildate >= @SendDate and ih.fildate < DATEADD(day, 1, @SendDate)
	group by ih.cardnum
	if @Realint1 + @Realint2 + @Realint3 <> 0 
	begin
		if @Realint1 <> @Checkint1 or @Realint2 <> @Checkint2
			or @Realint3 <> @Checkint3 or @RealData1 <> @CheckData1
			or @RealData2 <> @Checkdata2 or @RealData3 <> @CheckData3
		begin
	    	update shouldexchgdatadtl set finished = 0, note = @cls + '[' + @num + ']和本地数据不一致'
		    where senddate = @senddate 
    			and src = @src and tgt = @tgt
    			and cls = @cls and num = @num
		end else
	    	update shouldexchgdatadtl set finished = 1
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
