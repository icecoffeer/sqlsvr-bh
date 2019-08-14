SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[STKINDLT](
  @cls char(10),
  @num char(10),
  @new_oper int,
  @ChkFlag smallint = 0,  /*调用标志，1表示WMS调用，缺省为0*/
  @errmsg varchar(200) = '' output
) with encryption as
begin
  declare
    @return_status int,
    @max_num char(10),
    @neg_num char(10),
    @conflict smallint,
    @stat smallint

  declare
    @Oper char(30),@wrh int
  set @Oper = Convert(Char(1), @ChkFlag)
  select @wrh = wrh from stkin(nolock) where cls = @cls and num = @num
  exec @return_status = WMSFILTER 'STKIN', @piCls = @cls, @piNum = @num, @piToStat = 2, @piOper = @Oper,@piWrh =@wrh,  @piTag = 0, @piAct = null, @poMsg = @errmsg OUTPUT
  if @return_status <> 0
    begin
    	raiserror(@errmsg, 16, 1)
    	return -1
    end

  declare @RistrictCurDayOpt int, @m_FILDATE DATETIME --CHAR(10) CLASS

  select @m_FILDATE = CONVERT(DATETIME,CONVERT(CHAR(10),fildate,102) )  --DIRALC审核时间
  from STKIN where CLS = @cls and NUM = @num    			--Fanduoyi 1717

  exec optreadint 0, '禁止进货单和进货退货单隔天冲单修正', 0, @RistrictCurDayOpt output
  if @RistrictCurDayOpt = 1
    if @m_FILDATE < CONVERT(DATETIME,CONVERT(CHAR(10),GETDATE(),102) )
    BEGIN
      raiserror('禁止进货单和进货退货单隔天冲单修正！[同名选项]', 16, 1)
      SET @errmsg = '禁止进货单和进货退货单隔天冲单修正！[同名选项]'
      return -1
    END
  /* find the @neg_num */
  select @conflict = 1, @max_num = @num
  while @conflict = 1
  begin
    execute NEXTBN @max_num, @neg_num output
    if exists (select * from STKIN where CLS = @cls and NUM = @neg_num)
      select @max_num = @neg_num, @conflict = 1
    else
      select @conflict = 0
  end

  select
    @stat = STAT
    from STKIN where CLS = @cls and NUM = @num
  if @stat <> 1 and @stat <> 6 begin
    select @errmsg = '删除的不是已审核或已复核的单据'
    select @return_status = 1013
    raiserror(@errmsg, 16, 1)
    return(@return_status)
  end

  execute @return_status = DLTDECORDQTY 'STKIN', @cls, @num
  if @return_status <> 0 return(@return_status)

  execute @return_status =
          STKINDLTNUM @cls, @num, @new_oper, @neg_num, @errmsg output
  update STKIN set STAT = 2 where CLS = @cls and NUM = @num
  update STKIN set STAT = 4 where CLS = @cls and NUM = @neg_num
  return @return_status
end
GO
