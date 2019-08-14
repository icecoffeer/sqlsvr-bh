SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[AutoCURRENCY_RCV]
(
  @SRC int,
  @ID int,
  @ErrMsg varchar(200) output
)
as
begin
  declare @vRet int
  exec @vRet = CURRENCY_RCVONE @SRC, @ID, '交换服务'
  return @vRet
end
GO
