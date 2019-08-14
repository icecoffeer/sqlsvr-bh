SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[EcStkinBckSnd]
  @condstr varchar(255)
as
begin
  declare @ssqlstr varchar(800)
  
  select @ssqlstr = 'insert into EVDRRTN(Num, Flag)'
     + 'select num ,0 from STKINBCK where num not in (select num from EVDRRTN(nolock))'
     + ' and stat <> 0 and cls = ''自营'''
   if isNull(@condstr, '') <> '' 
   	select @ssqlstr = @ssqlstr + ' and ' + @condstr
   exec(@ssqlstr)      
end
GO
