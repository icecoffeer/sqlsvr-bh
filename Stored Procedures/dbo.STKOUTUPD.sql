SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[STKOUTUPD](
  @cls char(10),
  @new_num char(10),
  @ChkFlag smallint = 0  /*调用标志，1表示WMS调用，缺省为0*/
) with encryption as
begin
  declare
    @return_status int,    @max_num char(10),        @neg_num char(10),
    @old_num char(10),     @new_checker int,         @conflict smallint,
    @new_stat int,         @poMsg varchar(255)
  declare
    @old_dsp_num char(10), @old_invnum char(10),     @new_dsp_num char(10),@OptionValue_RCPCST char(1)

  select
    @return_status = 0,
    @new_stat = STAT,
    @old_num = MODNUM,
    @new_checker = CHECKER
    from STKOUT(nolock) where CLS = @cls and NUM = @new_num

  declare @Oper char(30)
  set @Oper = Convert(Char(1), @ChkFlag)
  exec @return_status = WMSSTKOUTCHKFILTER @piCls = @Cls, @piNum = @old_num, @piToStat = 2, @piOper = @Oper, @piTag = 0, @piAct = null, @poMsg = @poMsg OUTPUT
  if @return_status <> 0 return -1

  if @new_stat <> 0 begin
    raiserror('修改单不是未审核的单据', 16, 1)
    return(1)
  end
  if (select STAT from STKOUT(nolock) where CLS = @cls and NUM = @old_num) <> 1
  begin
    raiserror('被修改的不是已审核的单据', 16, 1)
    return(1)
  end

  /* find the @neg_num */
  select @conflict = 1, @max_num = @new_num
  while @conflict = 1
  begin
    execute NEXTBN @max_num, @neg_num output
    if exists (select * from STKOUT(nolock) where CLS = @cls and NUM = @neg_num)
      select @max_num = @neg_num, @conflict = 1
    else
      select @conflict = 0
  end

  execute @return_status = STKOUTDLTNUM @cls, @old_num, @new_checker, @neg_num, @errmsg = @poMsg OUTPUT
  --add by cyb
  if @cls = '批发'
  begin
	  select @OptionValue_RCPCST = OptionValue from HDOption(nolock) where  moduleNo = 0  and OptionCaption = 'RCPCST'
	  if @OptionValue_RCPCST is null
	     select @OptionValue_RCPCST = '0'
	  if @OptionValue_RCPCST = '1'
	  begin
		delete from CSTBILL WHERE OUTNUM = @OLD_NUM AND CLS = @CLS
	  end
  end
  /* 在某种未知的情况下,调用过程中的RAISERROR不能被CLIENT捕获.
  这里再RAISE一次 */
  if @return_status <> 0
  begin
    raiserror('处理单据时发生错误.', 16, 1)
    return (@return_status)
  end

  update STKOUT set STAT = 3 where CLS = @cls and NUM = @neg_num

  execute @return_status = STKOUTCHK @cls, @new_num

  /* 在某种未知的情况下,调用过程中的RAISERROR不能被CLIENT捕获.
  这里再RAISE一次 */
  if @return_status <> 0
  begin
    raiserror('处理单据时发生错误.', 16, 1)
    return (@return_status)
  end

  /* 2000-1-8 李希明：删除原来已经作废的提货单，修改新的提货单为原来的单号。 */
  if @return_status = 0
    and exists (select 1 from DSP
      where CLS = 'STKOUT' and POSNOCLS = @cls and FLOWNO = @old_num)
  begin
    select @old_dsp_num = NUM, @old_invnum = INVNUM
      from DSP
      where CLS = 'STKOUT' and POSNOCLS = @cls and FLOWNO = @old_num
    delete from DSPDTL where NUM = @old_dsp_num
    delete from DSP where NUM = @old_dsp_num
  /* by CQH 2000-11-23  select @new_dsp_num = NUM
      from DSP
      where CLS = 'STKOUT' and POSNOCLS = @cls and FLOWNO = @new_num
    update DSPDTL set NUM = @old_dsp_num
      where NUM = @new_dsp_num
    update DSP set
      NUM = @old_dsp_num, INVNUM = @old_invnum
      where NUM = @new_dsp_num	*/
  end

  /* 2000-1-25: 单据附件 */
  update BILLAPDX set NUM = @new_num
  where BILL = 'STKOUT' and CLS = @cls and NUM = @old_num

  /* 2000-8-17 */
  UPDATE STKOUTDTL SET RCPQTY=0, RCPAMT=0 WHERE CLS=@CLS AND NUM=@NEW_NUM

  if @return_status <> 0 return @return_status

  exec @return_status = WMSSTKOUTCHKFILTERBCK @piCls = @Cls, @piNum = @old_num, @piToStat = 2, @piOper = @Oper, @piTag = 0, @piAct = null, @poMsg = null
  return 0

end
GO
