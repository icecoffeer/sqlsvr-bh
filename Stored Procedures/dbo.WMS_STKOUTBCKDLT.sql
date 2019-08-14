SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[WMS_STKOUTBCKDLT]
  @cls char(10),
  @num char(10),
  @oper int,
  @ChkFlag smallint = 0,  /*调用标志，1表示WMS调用，缺省为0*/ 
  @poMsg varchar(255) = null output
with encryption as
begin
  declare
    @max_num char(10),
    @neg_num char(10),
    @return_status int,
    @OptionValue_RCPCST CHAR(1),/*2002.08.01*/
    @UseGftPrm varchar(10), @gftprmbcknum varchar(14), 
    @pioper char(30), @errmsg varchar(255)
    exec optreadint 0,'UseGftPrm',0,@UseGftPrm output

  declare @WMSOper char(30)
  set @WMSOper = Convert(Char(1), @ChkFlag)
  exec @return_status = WMSSTKOUTBCKCHKFILTER @piCls = @cls, @piNum = @num, @piToStat = 4, @piOper = @WMSOper, @piTag = 0, @piAct = null, @poMsg = @poMsg OUTPUT
  if @return_status <> 0 return -1
  
  /* find the @neg_num */
  execute NEXTBN @num, @neg_num output
  while exists (select * from STKOUTBCK where CLS = @cls and NUM = @neg_num)
  begin
    select @max_num = @neg_num
    execute NEXTBN @max_num, @neg_num output
  end

  execute @return_status = STKOUTBCKDLTNUM @cls, @num, @oper, @neg_num, @errmsg = @poMsg output
  --Fanduoyi 2004.10.19 增加赠品回收单自动冲单的过程
  if @cls = '零售' and @return_status=0 and @UseGftPrm = 1
  begin
    set @gftprmbcknum = ''
    select @pioper = convert(char(30),rtrim(emp.name)+'['+rtrim(emp.code)+']')  
        from employee emp(nolock) where gid = @oper
    select @gftprmbcknum = num from gftprmbck where gennum = @num and stat = 100
    if @gftprmbcknum <> ''
    begin
        exec @return_status = gftprmbck_delbill @gftprmbcknum, @pioper, '', -1, @errmsg output
        if @return_status <> 0 
        begin
                set @poMsg = @errmsg
                return @return_status
        end
    end
  end
  --add by cyb 
  if @cls = '批发' 
  begin	
	  select @OptionValue_RCPCST = OptionValue from HDOption where  moduleNo = 0  and OptionCaption = 'RCPCST'
	  if @OptionValue_RCPCST is null 
	     select @OptionValue_RCPCST = '0'
	  if @OptionValue_RCPCST = '1'
	  begin
		delete from CSTBILL WHERE OUTNUM = @NUM AND CLS = '批发退'
	  end
  end
  
  if @return_status <> 0 return @return_status
  
  exec @return_status = WMSSTKOUTBCKCHKFILTERBCK @piCls = @cls, @piNum = @num, @piToStat = 4, @piOper = @Oper, @piTag = 0, @piAct = null, @poMsg = null
  return 0
end
GO
