SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[PFA_SYS_GETCUROPERNAMECODE]
(
  @poOper  varchar(255) output
)
as
begin
  declare @v_Oper varchar(255), @v_UserCode varchar(10),  @v_UserName varchar(20)

  set @v_UserCode = '-'
  set @v_UserName = '未知'
  set @v_Oper = rtrim(SUSER_SNAME());

  set @v_UserCode = substring(@v_Oper, CHARINDEX('_', @v_Oper) + 1, 10)

  if exists (select 1 from EMPLOYEE where CODE = @v_UserCode)
    select @v_UserName = rtrim(NAME) from EMPLOYEE where CODE = @v_UserCode

  set @v_Oper = @v_UserName + '[' + @v_UserCode + ']'

  set @poOper = @v_Oper
  return
end
GO
