SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PAYDLT](
  @num char(10),
  @oper int
) with encryption as
begin
  declare
    @max_num char(10),
    @neg_num char(10),
    @return_status int,
    @conflict smallint
  select @conflict = 1, @max_num = @num
  while @conflict = 1
  begin
    execute NEXTBN @max_num, @neg_num output
    if exists (select * from PAY where NUM = @neg_num)
      select @conflict = 1, @max_num = @neg_num
    else
      select @conflict = 0
  end
  execute @return_status = PAYDLTNUM @num, @oper, @neg_num
  return (@return_status)
end
GO
