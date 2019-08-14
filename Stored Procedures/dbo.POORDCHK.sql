SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[POORDCHK](
	@num char(14),
	@Cls char(10),
	@Oper varchar(100),
	@ToStat smallInt,
	@Msg varchar(200) output
) with encryption as
begin
	declare
	@ret int,
	@stat int
	if not exists(select * from PURCHASEORDER where NUM = @num and CLS = @cls)
	begin
		select @Msg = '不存在要审核的单据'
		return(1)
	end

	select @stat = STAT from PURCHASEORDER where NUM = @num and CLS = @cls
	if @stat = 0 and @ToStat = 3200
	begin
	    select @msg = '未审核销售定货单不允许直接确认'
        return(1)
	end

	if @stat = 0 and @ToStat = 100
	begin
	    exec @ret = CHECKPO_TO100 @NUM, @CLS, @OPER, @TOSTAT, @MSG output
	    return(@ret)
	end
	else
	if @stat = 100 and @ToStat = 3200
	begin
      exec @ret = CHECKPO_TO3200 @NUM, @CLS, @OPER, @TOSTAT, @MSG output
	  return(@ret)
	end
    else
    begin
      select @Msg = '单据状态不合法'
	  return(0)
	end
end
GO
