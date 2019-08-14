SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[CHGCLIENTPRERCV] (
    @piNum VARCHAR(14),
    @piToStat INT,
    @piOper VARCHAR(30),
    @poErrMsg VARCHAR(255) OUTPUT       --出错信息
  )
  AS
  begin
    declare @Stat INT,
            @Rtn INT
    select @Stat = stat from CLIENTPRERCV where NUM = @piNum
    if @@Rowcount = 0 or @Stat is Null
    begin
      set @poErrMsg = '读单据状态失败,单据不存在.'
      return 1
    end
    if @Stat = 0 and @piToStat = 100 
    begin
      EXEC @Rtn = CHKCLIENTPRERCV @piNum, @piOper, @poErrMsg output 
      if @Rtn <> 0 
        return @Rtn
      EXEC ADDCLIENTPRERCVLOG @piNum, @Stat, @piToStat, @piOper
      return 0
    end
    if @Stat = 100 and @piToStat = 110 
    begin
      EXEC @Rtn = CANCELCLIENTPRERCV @piNum, @piOper, @poErrMsg output 
      if @Rtn <> 0 
        return @Rtn
      EXEC ADDCLIENTPRERCVLOG @piNum, @Stat, @piToStat, @piOper
      return 0
    end
    set @poErrMsg = '目标状态不正确.'
    return 1
  end
GO
