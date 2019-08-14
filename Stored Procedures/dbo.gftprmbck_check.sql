SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[gftprmbck_check]
(
  @NUM CHAR(14),
  @OPER CHAR(30),
  @CLS	 CHAR(10),
  @TOSTAT INT,
  @MSG VARCHAR(255) OUTPUT
)
as
begin
  declare @stat int
  declare @ret int
  declare @actname varchar(30)
  declare @statname varchar(30)

  select @stat = stat from gftprmbck where num = @Num;
  if (@tostat = 100) and (@stat = 0)
  begin
    exec @ret = gftprmbck_to100 @Num, @Oper, @Msg output
    return(@ret)
  end

  select @actname = actname from modulestat where no = @tostat;
  select @statname = statname from modulestat where no = @stat;
  raiserror('不能%s状态为%s的赠品促销单', 16, 1, @actname, @statname);
  return(1);
end
GO
