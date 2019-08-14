SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[DirStkInBckDlt]
  @cls char(10), @num char(10), @new_oper int
with encryption as
begin
  declare @return_status int, @errmsg varchar(200) /* 2000-8-13 */
  execute @return_status = DirDlt @cls, @num, @new_oper, @errmsg output
  /* 2000-8-13 */
  if @return_status <> 0
    raiserror(@errmsg, 16, 1)
  return @return_status
end
GO
