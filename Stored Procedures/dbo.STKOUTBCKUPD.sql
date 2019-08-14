SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[STKOUTBCKUPD](
  @cls char(10),
  @new_num char(10),
  @ChkFlag smallint = 0  /*调用标志，1表示WMS调用，缺省为0*/
) with encryption as
begin
  declare
    @return_status int,
    @temp_num char(10),
    @neg_num char(10),
    @old_num char(10),
    @new_stat smallint,
    @new_checker int,
    @OptionValue_RCPCST CHAR(1),
    @UseGftPrm varchar(10), @gftprmbcknum varchar(14),
    @pioper char(30), @errmsg varchar(255), @poMsg varchar(255)

    exec optreadint 0,'UseGftPrm',0,@UseGftPrm output

  declare @Oper char(30)
  set @Oper = Convert(Char(1), @ChkFlag)
  exec @return_status = WMSSTKOUTBCKCHKFILTER @piCls = @Cls, @piNum = @old_num, @piToStat = 2, @piOper = @Oper, @piTag = 0, @piAct = null, @poMsg = @poMsg output
  if @return_status <> 0 return -1

  select @return_status = 0
  select @new_stat = STAT, @old_num = MODNUM, @new_checker = CHECKER
    from STKOUTBCK where CLS = @cls and NUM = @new_num
  /* 99-12-29 */
  if @new_stat not in (0,7)
  begin
    raiserror('修改单不是未审核的单据', 16, 1)
    return(1)
  end
  if (select STAT from STKOUTBCK where CLS = @cls and NUM = @old_num) <> 1
  begin
    raiserror('被修改的不是已审核的单据', 16, 1)
    return(1)
  end

  execute NEXTBN @new_num, @neg_num output
  while exists (select * from STKOUTBCK where CLS = @cls and NUM = @neg_num)
  begin
    select @temp_num = @neg_num
    execute NEXTBN @temp_num, @neg_num output
  end

  execute @return_status = STKOUTBCKCHK @cls, @new_num

  /* 在某种未知的情况下,调用过程中的RAISERROR不能被CLIENT捕获.
  这里再RAISE一次 */
  if @return_status <> 0
  begin
    raiserror('处理单据时发生错误.', 16, 1)
    return (@return_status)
  end


  execute @return_status=STKOUTBCKDLTNUM @cls, @old_num, @new_checker, @neg_num, @errmsg = @poMsg output
  --Fanduoyi 2004.10.19 2004.12.29 增加赠品回收单自动冲单的过程
  if @cls = '零售' and @return_status=0 and @UseGftPrm = 1
  begin
    set @gftprmbcknum = ''
    select @pioper = convert(char(30),rtrim(emp.name)+'['+rtrim(emp.code)+']')
        from employee emp(nolock) where gid = (select filler from stkoutbck where num = @new_num and cls = '零售')
    select @gftprmbcknum = num from gftprmbck where gennum = @old_num and stat = 100
    if @gftprmbcknum <> ''
        exec @return_status = gftprmbck_delbill @gftprmbcknum, @pioper, '', -1, @errmsg output
    /* 取消－审核赠品回收单
    select @gftprmbcknum = num from gftprmbck where gennum = @new_num
    if @gftprmbcknum <> ''
        exec @return_status = gftprmbck_check @gftprmbcknum, @pioper, '', 100, @errmsg output
    */
  end
  --add by cyb
  if @cls = '批发'
  begin
	  select @OptionValue_RCPCST = OptionValue from HDOption where  moduleNo = 0  and OptionCaption = 'RCPCST'
	  if @OptionValue_RCPCST is null
	     select @OptionValue_RCPCST = '0'
	  if @OptionValue_RCPCST = '1'
	  begin
		delete from CSTBILL WHERE OUTNUM = @OLD_NUM AND CLS = '批发退'
	  end
  end
  update STKOUTBCK set STAT = 3 where CLS = @cls and NUM = @neg_num

  /* 在某种未知的情况下,调用过程中的RAISERROR不能被CLIENT捕获.
  这里再RAISE一次 */
  if @return_status <> 0
  begin
    raiserror('处理单据时发生错误.', 16, 1)
    return (@return_status)
  end

  /* 2000-1-25: 单据附件 */
  update BILLAPDX set NUM = @new_num
  where BILL = 'STKOUTBCK' and CLS = @cls and NUM = @old_num

  /* 2000-8-17 */
  UPDATE STKOUTBCKDTL SET RCPQTY=0, RCPAMT=0 WHERE CLS=@CLS AND NUM=@NEW_NUM

  if @return_status <> 0 return @return_status

  exec @return_status = WMSSTKOUTBCKCHKFILTERBCK @piCls = @Cls, @piNum = @old_num, @piToStat = 2, @piOper = @Oper, @piTag = 0, @piAct = null, @poMsg = null
  return 0
end
GO
