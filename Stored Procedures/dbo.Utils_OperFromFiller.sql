SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[Utils_OperFromFiller](
  @Filler int,
  @Oper varchar(30) output
) as
/* 通过老式单据中的 FILLER 字段的值（EMPLOYEE.GID），获取其对应的员工的名称。如
获取不到，则获取当前数据库登录用户的名称。传出参数 @Oper 的形式：NAME[CODE]。*/
begin
  if exists(select 1 from EMPLOYEEH(nolock) where GID = @Filler)
  begin
    select @Oper = rtrim(NAME) + '[' + rtrim(CODE) + ']'
      from EMPLOYEEH(nolock)
      where GID = @Filler
  end
  else begin
    exec Utils_OperFromSuser_Sname @Oper output
  end

  return(0)
end
GO
