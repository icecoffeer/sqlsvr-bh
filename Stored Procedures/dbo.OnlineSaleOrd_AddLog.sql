SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[OnlineSaleOrd_AddLog](
  @Num char(14),
  @ToStat smallint,
  @Modifier int,
  @Action varchar(100)
)
as
begin
  insert into OnlineSaleOrdLog(NUM, STAT, TIME, MODIFIER, ACTION)
    select @Num, @ToStat, getdate(), @Modifier, @Action
  return(0)
end
GO
