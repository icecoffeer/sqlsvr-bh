SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[AutoEmpGroupRcv]
 @SRC int,
 @ID int,
 @ErrMsg varchar(200) output
as
begin
  declare @Result int
  exec @Result =EmpGroupRcv @SRC,@ID,1
  return @Result
end

GO
