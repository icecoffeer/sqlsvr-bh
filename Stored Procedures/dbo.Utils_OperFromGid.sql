SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[Utils_OperFromGid](
  @EmpGid int,
  @Oper varchar(30) output
) as
/* 根据员工的 GID（EMPLOYEE.GID），获取其名称。如获取不到，则返回名称“未知[-]”。
传出参数 @Oper 的形式：NAME[CODE]。*/
begin
  if exists(select 1 from EMPLOYEEH(nolock) where GID = @EmpGid)
  begin
    select @Oper = rtrim(NAME) + '[' + rtrim(CODE) + ']'
      from EMPLOYEEH(nolock)
      where GID = @EmpGid
  end
  else begin
    set @Oper = '未知[-]'
  end

  return(0)
end
GO
