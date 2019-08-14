SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[OnlineSaleBckOrd_On_Modify](
  @Num char(14),
  @ToStat smallint,
  @Oper int,
  @Msg varchar(255) output
)
as
begin
  declare @return_status smallint

  set @return_status = 0
  if @ToStat = 3200
    exec @return_status = OnlineSaleBckOrd_On_Modify_To_3200 @Num, @ToStat, @Oper, @Msg output

  return(@return_status)
end
GO
