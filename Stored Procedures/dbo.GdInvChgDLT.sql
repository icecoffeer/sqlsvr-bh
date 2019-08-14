SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GdInvChgDLT]
  @num char(10),
  @new_oper int,
  @errmsg varchar(200) = '' output
with encryption as
begin
  declare
    @max_num char(10),    @neg_num char(10),         @return_status int,
    @conflict smallint
  select @conflict = 1, @max_num = @num
  while @conflict = 1
  begin
    execute NEXTBN @max_num, @neg_num output
    if exists (select * from GDINVCHG where NUM = @neg_num)
      select @max_num = @neg_num, @conflict = 1
    else
      select @conflict = 0
  end
  execute @return_status = GdInvChgDLTNum @num, @new_oper, @neg_num, @errmsg output
  return @return_status
end
GO
