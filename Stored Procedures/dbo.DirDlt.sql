SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[DirDlt]
  @cls char(10),
  @num char(10),
  @new_oper int,
  @errmsg varchar(200) = '' output          /* 2000-8-13 */
with encryption as
begin
  declare
    @max_num char(10),    @neg_num char(10),         @return_status int,
    @conflict smallint
  select @conflict = 1, @max_num = @num
  while @conflict = 1
  begin
    execute NEXTBN @max_num, @neg_num output
    if exists (select * from DIRALC where CLS = @cls and NUM = @neg_num)
      select @max_num = @neg_num, @conflict = 1
    else
      select @conflict = 0
  end
  if @cls = '直配进'
  begin
    execute @return_status = DLTDECORDQTY 'DIRALC', @cls, @num
    if @return_status <> 0 return @return_status
  end

  execute @return_status = DirDltNum @cls, @num, @new_oper, @neg_num, @errmsg output    /* 2000-8-13 */
  return @return_status
end
GO
