SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[WMS_STKOUTDLT](
  @old_cls char(10),
  @old_num char(10),
  @new_oper int,
  @ChkFlag smallint = 0,  /*调用标志，1表示WMS调用，缺省为0*/
  @poMsg varchar(255) = null output
) with encryption as
begin
  declare
    @return_status int,
    @max_num char(10),
    @neg_num char(10),
    @conflict smallint,
    @OptionValue_RCPCST char(1)

  declare @Oper char(30)
  set @Oper = Convert(Char(1), @ChkFlag)
  exec @return_status = WMSSTKOUTCHKFILTER @piCls = @old_cls, @piNum = @old_num, @piToStat = 4, @piOper = @Oper, @piTag = 0, @piAct = null, @poMsg = @poMsg OUTPUT
  if @return_status <> 0 return -1
  /* find the @neg_num */
  select @conflict = 1, @max_num = @old_num
  while @conflict = 1
  begin
    execute NEXTBN @max_num, @neg_num output
    if exists (select * from STKOUT(nolock) where CLS = @old_cls and NUM = @neg_num)
      select @max_num = @neg_num, @conflict = 1
    else
      select @conflict = 0
  end

  execute @return_status = STKOUTDLTNUM @old_cls, @old_num, @new_oper, @neg_num, @errmsg = @poMsg OUTPUT

  /* 在某种未知的情况下,调用过程中的RAISERROR不能被CLIENT捕获.
  这里再RAISE一次 */
  if @return_status <> 0
  begin
    --raiserror('处理单据时发生错误.', 16, 1)
    return (@return_status)
  end
  --add by cyb
  if @OLD_cls = '批发'
  begin
          select @OptionValue_RCPCST = OptionValue from HDOption(nolock) where  moduleNo = 0  and OptionCaption = 'RCPCST'
          if @OptionValue_RCPCST is null
             select @OptionValue_RCPCST = '0'
          if @OptionValue_RCPCST = '1'
          begin
                delete from CSTBILL WHERE OUTNUM = @OLD_NUM AND CLS = @OLD_CLS
          end
  end

  if @return_status <> 0 return @return_status

  exec @return_status = WMSSTKOUTCHKFILTERBCK @piCls = @old_cls, @piNum = @old_num, @piToStat = 4, @piOper = @Oper, @piTag = 0, @piAct = null, @poMsg = null
  return 0
end
GO
