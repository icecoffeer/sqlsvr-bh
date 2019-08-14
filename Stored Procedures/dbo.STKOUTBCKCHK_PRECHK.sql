SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[STKOUTBCKCHK_PRECHK](
  @cls char(10),
  @num char(10),
  @ChkFlag smallint = 0,  /*调用标志，1表示WMS调用，缺省为0*/
  @poMsg varchar(255) = null output
) as
begin
  declare
    @return_status int, @Oper char(30)
  set @Oper = Convert(Char(1), @ChkFlag)
  exec @return_status = WMSSTKOUTBCKCHKFILTER @piCls = @Cls, @piNum = @Num, @piToStat = 7, @piOper = @Oper, @piTag = 0, @piAct = null, @poMsg = @poMsg Output
  if @return_status <> 0 return -1
  update STKOUTBCK set STAT = 7 where cls = @cls and num = @num
  exec @return_status = WMSSTKOUTBCKCHKFILTERBCK @piCls = @Cls, @piNum = @Num, @piToStat = 7, @piOper = @Oper, @piTag = 0, @piAct = null, @poMsg = null
  return 0
end
GO
