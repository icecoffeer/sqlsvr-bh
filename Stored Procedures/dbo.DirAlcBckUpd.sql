SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[DirAlcBckUpd]
  @cls char(10), @num char(10)
with encryption as
begin
  declare @return_status int, @errmsg varchar(200) /* 2000-8-13 */
  execute @return_status = DirUpd @cls, @num, @errmsg output
  /* 2000-8-13 */
  if @return_status <> 0
    raiserror(@errmsg, 16, 1)
  return @return_status
end
GO
