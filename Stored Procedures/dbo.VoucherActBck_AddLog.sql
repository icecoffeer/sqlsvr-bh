SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[VoucherActBck_AddLog](
  @Num char(14),
  @ToStat smallint,
  @Modifier varchar(30),
  @Action varchar(255)
)
as
begin
  insert into VOUCHERACTBCKLOG(NUM, STAT, MODIFIER, TIME, ACTION)
    select @Num, @ToStat, @Modifier, getdate(), @Action
  return(0)
end
GO
