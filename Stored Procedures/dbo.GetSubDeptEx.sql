SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GetSubDeptEx](@Code varchar(10))
AS
begin
  declare @subcode varchar(10)  
  
  declare c_Dept cursor LOCAL for select CODE from DEPT(nolock) where PARENTCODE = @Code
  open c_Dept
  fetch next from c_Dept into @subcode
  while @@fetch_status = 0
  begin
    insert into SubDeptByCode (spid, code) values(@@spid, @subcode)
    exec GetSubDeptEx @subcode
    fetch next from c_Dept into @subcode
  end
  close c_Dept
  deallocate c_Dept
  return 0
end
GO
