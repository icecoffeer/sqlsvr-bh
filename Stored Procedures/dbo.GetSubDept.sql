SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GetSubDept](@Code varchar(10))
AS
begin
  delete from SubDeptByCode where spid = @@spid
  if not exists (select 1 from dept(nolock) where code = @Code) 
    return 0
  insert into SubDeptByCode (spid, code) values(@@spid, @Code)  
  exec GetSubDeptEx @Code
end
GO
