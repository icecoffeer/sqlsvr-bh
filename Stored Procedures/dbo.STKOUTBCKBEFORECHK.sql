SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[STKOUTBCKBEFORECHK] (
  @piNum VARCHAR(14),
  @piCls VARCHAR(10),
  @poErrMsg VARCHAR(255) OUTPUT       --出错信息
  )
  AS
  begin
    if @piCls <> '批发'
      return 0
    declare @CLIENT INT,
            @WSLIMIT INT,
            @BALANCE MONEY,
            @TOTAL MONEY,
            @CHECKER INT,
            @CHK VARCHAR(30),
            @Item INT
    select @CLIENT = CLIENT, @TOTAL = TOTAL, @CHECKER = CHECKER from STKOUTBCK where NUM = @piNum and CLS = @piCls
    select @CHK = Rtrim(NAME) + '[' + Rtrim(CODE) + ']' from employee where GID = @CHECKER
    if @CHK is NULL
      set @CHK = '未知[-]'
    select @WSLIMIT = WSLIMIT, @BALANCE = BALANCE from CLIENT where GID = @CLIENT
    if @WSLIMIT is NULL or @WSLIMIT = 0
      return 0
    if -@TOTAL > @BALANCE
    begin

      set @poErrMsg = '当前客户预存款余额不足(余额:' + Cast(@BALANCE as VARCHAR(24)) + ' 本次冲扣额:'
                    + Cast(@TOTAL as VARCHAR(24)) + ')'
      return 1
    end
    update CLIENT set BALANCE = BALANCE + @TOTAL where GID = @CLIENT
    select @Item = MAX(ITEMNO) + 1 from CLIENTPRERCVHST where CLIENT = @CLIENT
    if @Item is NULL
      set @Item = 1
    insert into CLIENTPRERCVHST (CLIENT, ITEMNO, OPERDATE, AMT, BALANCE, NUM, OPER, CLS) values
      (@CLIENT, @Item, GETDATE(), @TOTAL, @BALANCE, @piNum, @CHK, '批发退')
    return 0
  end
GO
