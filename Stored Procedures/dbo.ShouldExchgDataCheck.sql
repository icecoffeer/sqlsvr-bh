SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[ShouldExchgDataCheck](
    @SendDate    datetime,
    @src	int,
    @tgt	int,
    @cls    varchar(50),
    @num    varchar(14),
    @ErrMsg	varchar(255) output
)  as  
begin
  declare
    @checksp varchar(30),
    @sqlstring varchar(255)
    
  if not exists(select 1 from ShouldExchgDataDtl 
    where SendDate >= dateadd(day,-7,@senddate) and  src = @src 
    and tgt = @tgt and cls=@cls and num = @num)
       begin
         select @Errmsg = '对应记录在应收清单中不存在'
	     return -1
       end
  
  select @checksp = isnull(checksp, '') from dataexchgsetting(nolock)
  where cls = @cls 
  if (@@rowcount = 0) or (@checksp = '')
  begin
  	select @ErrMsg = '未找到核对子程序'
  	return 1
  end

  set @sqlstring = 'exec ' + @checksp + ' '
    + '''' + convert(varchar(10), @SendDate, 102) + '''' + ', '
    + ltrim(str(@src)) + ', '
    + ltrim(str(@tgt)) + ', '
  	+ '''' + @cls + '''' + ', '
    + '''' + @num + ''''
  exec(@sqlstring)
    
  if not exists(select 1 from ShouldExchgDataDtl (nolock) where SendDate = @SendDate 
    and src = @src and tgt = @tgt and Finished = 0)
	update ShouldExchgData set Finished = 1 
	where  SendDate = @SendDate and src = @src and tgt = @tgt
  else
	update ShouldExchgData set Finished = 0
	where  SendDate = @SendDate and src = @src and tgt = @tgt
end
GO
