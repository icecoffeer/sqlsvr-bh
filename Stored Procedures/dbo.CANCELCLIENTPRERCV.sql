SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[CANCELCLIENTPRERCV] (
    @piNum VARCHAR(14),
    @piOper VARCHAR(30),
    @poErrMsg VARCHAR(255) OUTPUT       --出错信息
  )
  AS
  begin
    declare @TOTAL MONEY,
            @CLIENT INT,
            @Rtn INT,
            @BALANCE MONEY
    select @TOTAL = TOTAL, @CLIENT = CLIENT from CLIENTPRERCV where NUM = @piNum
    set @BALANCE = NULL
    select @BALANCE = BALANCE from CLIENT where GID = @CLIENT
    if @BALANCE is NULL 
    begin
      set @poErrMsg = '客户资料有错误.'
      return 1
    end
    if @BALANCE - @TOTAL < 0
    begin
      set @poErrMsg = '当前客户存款余额不足,不能作废单据.'
      return 1
    end
    update CLIENT set BALANCE = BALANCE - @TOTAL where GID = @CLIENT
    select @Rtn = Max(ITEMNO) from CLIENTPRERCVHST where CLIENT = @CLIENT
    if @Rtn is NULL
      set @Rtn = 1
     else
       set @Rtn = @Rtn + 1
     insert into CLIENTPRERCVHST(CLIENT, ITEMNO, OPERDATE, AMT, BALANCE, NUM, OPER, CLS) values
        (@CLIENT, @Rtn, GETDATE(), -1 * @TOTAL, @BALANCE, @piNum, @piOper, '收款')
     update CLIENTPRERCV set STAT = 110
       where NUM = @piNum
     return 0
  end
GO
