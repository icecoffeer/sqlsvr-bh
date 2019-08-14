SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[DELCLIENTPRERCV] (
    @piNum VARCHAR(14),
    @poErrMsg VARCHAR(255) OUTPUT       --出错信息
  )
  AS
  begin
    declare @Stat INT
    select @Stat = stat from CLIENTPRERCV where NUM = @piNum
    if @@Rowcount = 0 or @Stat is Null
    begin
      set @poErrMsg = '读单据状态失败,单据不存在.'
      return 1
    end
    if @Stat <> 0
    begin
      set @poErrMsg = '不是未审核状态的单据不允许删除.'
      return 1
    end
    delete from CLIENTPRERCVLOG where NUM = @piNum
    delete from CLIENTPRERCV where NUM = @piNum
    return 0
  end
GO
