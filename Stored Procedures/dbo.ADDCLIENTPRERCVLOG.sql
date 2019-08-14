SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[ADDCLIENTPRERCVLOG] (
    @piNum VARCHAR(14),
    @piFromStat INT,
    @piToStat INT,
    @piOper VARCHAR(30)
  )
  AS
  begin
    declare @Rtn INT
    select @Rtn = Max(ITEMNO) from CLIENTPRERCVLOG where NUM = @piNum
    if @Rtn is NULL 
      set @Rtn = 1
    else
      set @Rtn = @Rtn + 1
    insert into CLIENTPRERCVLOG (NUM, ITEMNO, FROMSTAT, TOSTAT, OPER, OPERTIME) values
      (@piNum, @Rtn, @piFromStat, @piToStat, @piOper, GETDATE())
    return 0
  end
GO
