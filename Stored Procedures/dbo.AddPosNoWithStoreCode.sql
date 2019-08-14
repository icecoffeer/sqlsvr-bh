SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[AddPosNoWithStoreCode](
  @poErrMsg varchar(255) output
) as
begin
  declare
    @v_UserCode varchar(10),
    @v_Name varchar(32)

  select @v_UserCode = UserCode from System
  Set @v_Name = 'POS' + RTrim(@v_UserCode)

  if not Exists(Select 1 from Workstation where No = @v_UserCode)
    Insert Into WorkStation(No, Name, ComputerName)
      Values(@v_UserCode, @v_Name, @v_Name)

  Return 0
end
GO
