SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[gftprm_check]
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

  select @stat = stat from gftprm where num = @Num;
  if (@tostat = 100) and (@stat = 0)
  begin
    exec @ret = gftprm_to100 @Num, @Oper, @Msg output
    return(@ret)
  end
  if (@tostat = 800) and (@stat = 0) --汇总需要使用
  begin
    exec @ret = gftprm_to100 @Num, @Oper, @Msg output
    return(@ret)
  end
  select @stat = stat from gftprm where num = @Num;
  if (@tostat = 800) and (@stat = 100)
  begin
    exec @ret = gftprm_to800 @Num, @Oper, @Msg output
    return(@ret)
  end
  if (@tostat = 1400) and ((@stat = 800) or (@stat = 100))
  begin
    exec @ret = gftprm_to1400 @Num, @Oper, @Msg output
    return(@ret)
  end

  select @actname = actname from modulestat where no = @tostat;
  select @statname = statname from modulestat where no = @stat;
  raiserror('不能%s状态为%s的赠品促销单', 16, 1, @actname, @statname);
  return(1);
end
GO
