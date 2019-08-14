SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[OVFDLT](
  @old_num varchar(10),
  @p_oper int,
  @ChkFlag smallint = 0  /*调用标志，1表示WMS调用，缺省为0*/
) with encryption as
begin
  declare
    @return_status int,
    @old_stat smallint,
    @neg_num char(10),
    @max_num char(10),
    @conflict smallint

  select @old_stat = STAT from OVF where NUM = @old_num
  if @old_stat <> 1 begin
    raiserror('被删除的不是已审核过的单据', 16, 1)
    return(1)
  end

  --ShenMin
  declare
    @Oper char(30),@WRH INT,
    @msg varchar(255)
  set @Oper = Convert(Char(1), @ChkFlag)
  SELECT @WRH = WRH FROM ovf(NOLOCK) WHERE NUM = @old_num
  exec @return_status = WMSFILTER 'OVF', '', @old_num, 2, @Oper,@WRH, 1, 1, @msg output
  if @return_status <> 0
    begin
    	raiserror(@msg, 16, 1)
    	return(1)
    end

  /* find the @neg_num */
  select @conflict = 1, @max_num = @old_num
  while @conflict = 1
  begin
    execute NEXTBN @max_num, @neg_num output
    if exists (select * from OVF where NUM = @neg_num)
      select @max_num = @neg_num, @conflict = 1
    else
      select @conflict = 0
  end

  execute @return_status = OVFDLTNUM @old_num, @p_oper, @neg_num
  update OVF set STAT = 2 where NUM = @old_num
  update OVF set STAT = 4 where NUM = @neg_num
  return @return_status
end
GO
