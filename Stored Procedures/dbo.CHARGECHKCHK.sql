SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[CHARGECHKCHK]
(
  @NUM VARCHAR(50),
  @TOSTAT INT,
  @OPER VARCHAR(30),
  @MSG VARCHAR(255) OUTPUT
)
As
Begin
  declare
    @stat int,
    @ret smallint

  set @ret = 0
  select @stat = stat
  from CHARGECHK where num =@Num

  if @TOSTAT = 100
    begin
    	execute @ret = CHARGECHKCHKDTL @num = @NUM, @ToStat = @TOSTAT, @Oper = @OPER, @errmsg = @MSG output;
    end
  else if @TOSTAT = 110
    begin
      update CHARGECHK
      set stat = @TOSTAT, LstUpdTime = Getdate()
      where num = @num;
    end;

  if @ret <> 0 set @msg = @msg + ',审核单据出错';
  return @ret;
End
GO
