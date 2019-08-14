SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[OVFUPD](
  @new_num varchar(10),
  @ChkFlag smallint = 0  /*调用标志，1表示WMS调用，缺省为0*/
) with encryption as
begin
  declare
    @return_status int,
    @max_num char(10),
    @neg_num char(10),
    @conflict smallint,
    @new_stat smallint,
    @new_oper int,
    @old_num char(10),
    @old_stat smallint,
    @WRH INT

  select
    @return_status = 0

  select
    @new_stat = STAT,
    @old_num = MODNUM,
    @new_oper = FILLER
    from OVF where NUM = @new_num
  if @new_stat <> 0 begin
    raiserror('修改单不是未审核的单据.', 16, 1)
    return(1)
  end

  select @old_stat = STAT from OVF where NUM = @old_num
  if @old_stat <> 1 and @old_stat <> 6 begin
    raiserror('被修改的不是已审核或已复核的单据.', 16, 1)
    return(1)
  end

 --ShenMin
  declare
    @Oper char(30),
    @msg varchar(255)
  set @Oper = Convert(Char(1), @ChkFlag)
  exec @return_status = WMSFILTER 'OVF', @piCls = '', @piNum = @old_num, @piToStat = 2, @piOper = @Oper,@piWrh = @WRH, @piTag = 0, @piAct = null, @poMsg = @msg OUTPUT
  if @return_status <> 0
    begin
    	raiserror(@msg, 16, 1)
    	return -1
    end

  execute @return_status = OVFCHK @p_num = @new_num
  if @return_status <> 0 return @return_status

  /* find the @neg_num */
  select @conflict = 1, @max_num = @new_num
  while @conflict = 1
  begin
    execute NEXTBN @max_num, @neg_num output
    if exists (select * from OVF where NUM = @neg_num)
      select @max_num = @neg_num, @conflict = 1
    else
      select @conflict = 0
  end

  execute @return_status = OVFDLTNUM @old_num, @new_oper, @neg_num
  update OVF set STAT = 2 where NUM = @old_num
  update OVF set STAT = 3 where NUM = @neg_num

  /* 在某种未知的情况下,调用过程中的RAISERROR不能被CLIENT捕获.
  这里再RAISE一次 */
  if @return_status <> 0
  begin
    raiserror('处理单据时发生错误.', 16, 1)
    return (@return_status)
  end

  return @return_status
end
GO
