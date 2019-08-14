SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[Utils_OperFromSuser_Sname](
  @Oper varchar(30) output
) as
/* 解析出 suser_sname() 函数的返回值中所包含的登录员工的代码（EMPLOYEE.CODE），
然后利用其来获取员工的名称。传出参数 @Oper 的形式：NAME[CODE]。*/
begin
  declare @StartIndex int
  declare @Length int
  declare @EmpCode varchar(10)
  declare @EmpName varchar(20)

  set @Oper = suser_sname()
  if charindex('_', @Oper) > 0
  begin
    set @StartIndex = charindex('_', @Oper) + 1
    set @Length = len(@Oper) - charindex('_', @Oper)
    set @EmpCode = substring(@Oper, @StartIndex, @Length)
    select @EmpName = rtrim(NAME) from EMPLOYEE(nolock) where CODE = @EmpCode
    if @EmpName is null
      set @EmpName = '未知'
    set @Oper = @EmpName + '[' + @EmpCode + ']'
  end

  return(0)
end
GO
