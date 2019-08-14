SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PAYUPD](
  @new_num char(10)
) with encryption as
begin
  declare
    @return_status int,
    @new_checker int,
    @new_stat int,
    @old_num char(10),
    @max_num char(10),
    @neg_num char(10),
    @conflict smallint,
    --zz 090402
    @pytotal money,
    @src int,
    @usergid int,
    @clecent int,
    @sndtime datetime

  select @usergid = usergid from system --zz 090402
  select
    @return_status = 0,
    @new_checker = CHECKER,
    @new_stat = STAT,
    @old_num = MODNUM
    from PAY where NUM = @new_num
--zz 090402
  select
    @pytotal = pytotal,
    @src = src,
    @sndtime = sndtime,
    @clecent = isnull(clecent, @usergid)
    from PAY where NUM = @old_num

  if @new_stat <> 0 begin
    raiserror('修改单不是未审核的单据', 16, 1)
    return(1)
  end
--zz 090402
  if @pytotal <> 0 begin
    raiserror('结算单已被付款单引用并回写,不能修正', 16, 1)
    return(2)
  end
  
  if @sndtime is not null and @src = @usergid and @clecent <> @usergid begin
    raiserror('结算单已发送到结算中心,不能修正', 16, 1)
    return(3)
  end

  if @src <> @usergid and @clecent = @usergid begin
    raiserror('结算中心不能修正门店结算单,只允许冲单', 16, 1)
    return(4)
  end
--end
  select @conflict = 1, @max_num = @new_num
  while @conflict = 1
  begin
    execute NEXTBN @max_num, @neg_num output
    if exists (select * from PAY where NUM = @neg_num)
      select @conflict = 1, @max_num = @neg_num
    else
      select @conflict = 0
  end

  execute @return_status = PAYDLTNUM @old_num, @new_checker, @neg_num
  if @return_status <> 0 return(@return_status)
  update PAY set STAT = 3 where NUM = @neg_num

  execute @return_status = PAYCHK @new_num

  /* 2000-07-17 */
  IF @RETURN_STATUS <> 0 RETURN(@RETURN_STATUS)
  UPDATE PAY SET STAT=2 WHERE NUM=@OLD_NUM

  return(@return_status)
end

GO
