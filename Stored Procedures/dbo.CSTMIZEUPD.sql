SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[CSTMIZEUPD](
  @new_num char(10)
) with encryption as
begin
  declare
    @ret_status int,
    @temp_num char(10),
    @neg_num char(10),
    @old_num char(10),
    @new_stat smallint,
    @new_checker int,
    @old_stat int

  select @ret_status = 0
  select @new_stat = STAT, @old_num = MODNUM, @new_checker = CHECKER
    from CSTMIZE where NUM = @new_num
  select @old_stat = STAT from CSTMIZE where NUM = @old_num

  if @new_stat <> 0
  begin
    raiserror('修改单不是未审核的单据', 16, 1)
    return(1)
  end
  if @old_stat not in (1,11)
  begin
    raiserror('被修改的不是已审核或已批准的单据', 16, 1)
    return(1)
  end

  execute NEXTBN @new_num, @neg_num output
  while exists (select * from CSTMIZE where NUM = @neg_num)
  begin
    select @temp_num = @neg_num
    execute NEXTBN @temp_num, @neg_num output
  end

  if @old_stat = 1
     execute @ret_status = CSTMIZECHK @new_num, 1
  else
     execute @ret_status = CSTMIZECHK @new_num, 3

  /* 在某种未知的情况下,调用过程中的RAISERROR不能被CLIENT捕获.
  这里再RAISE一次 */
  if @ret_status <> 0 
  begin
    raiserror('处理单据时发生错误.', 16, 1)
    return (@ret_status)
  end

  if @old_stat = 1
      execute @ret_status=CSTMIZEDLTNUM @old_num, 1, @new_checker, @neg_num
  else
      execute @ret_status=CSTMIZEDLTNUM @old_num, 2, @new_checker, @neg_num

  update CSTMIZE set STAT = 3 where NUM = @neg_num

  /* 在某种未知的情况下,调用过程中的RAISERROR不能被CLIENT捕获.
  这里再RAISE一次 */
  if @ret_status <> 0 
  begin
    raiserror('处理单据时发生错误.', 16, 1)
    return (@ret_status)
  end

  update BILLAPDX set NUM = @new_num
  where BILL = 'CSTMIZE' and NUM = @old_num

end
GO
