SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[AutoTJRcv]
as
begin
  if exists (select 1 from NTJ(nolock))
  begin
  	delete from TJ
	  insert into TJ (TYPE, CODE, NAME, ReMark, QtyName, QtyUnit, AmtName, AmtUnit)
		  select distinct TYPE, CODE, NAME, ReMark, QtyName, QtyUnit, AmtName, AmtUnit
		  from NTJ(nolock) where NTYPE = 1

	  delete from NTJ where NTYPE = 1
  end
  return(0)
end
GO
