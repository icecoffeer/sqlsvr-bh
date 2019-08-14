SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[CSTMIZEDLT](
  @num char(10),
  @new_oper int
) with encryption as
begin
  declare
    @ret_status int,
    @stat smallint,
    @max_num char(10),
    @neg_num char(10),
    @conflict smallint,
    @mode int

  select
    @ret_status = 0

  /* find the @neg_num */
  select @conflict = 1, @max_num = @num
  while @conflict = 1
  begin
    execute NEXTBN @max_num, @neg_num output
    if exists (select * from CSTMIZE where NUM = @neg_num)
      select @max_num = @neg_num, @conflict = 1
    else
      select @conflict = 0
  end

  select
    @stat = STAT
    from CSTMIZE where NUM = @num
  if @stat <> 1 and @stat <> 11 begin
    raiserror('删除的不是已审核或已批准的单据.', 16, 1)
    return(1)
  end

  if @stat = 1 
     select @mode = 1
  else
     select @mode = 2

  execute @ret_status = CSTMIZEDLTNUM @num, @mode, @new_oper, @neg_num
  update CSTMIZE set STAT = 2 where NUM = @num
  update CSTMIZE set STAT = 4 where NUM = @neg_num
  return @ret_status
end
GO
