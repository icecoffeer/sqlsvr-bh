SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


create procedure [dbo].[GetSubWrhBatch]
  @wrh int,
  @subwrh int output,
  @errmsg varchar(200) = '' output
as
begin
  /*
  输入: @WRH,仓位GID.
  输出: @SUBWRH,新货位的GID
  改变数据: 新增一个货位,GID的处理与其它基本资料一致,CODE的格式为“YYMMDDXXXX”
  	前6位通过当前日期得到，后4位流水. NAME中的内容与CODE相同 */
  declare @datestr char(6), @string char(20), @maxsubwrh char(10)
  select @string = convert(char(10), getdate(), 102)
  select @datestr = substring(@string,3,2) + substring(@string,6,2) +	substring(@string,9,2)
  select @maxsubwrh = isnull(
    (select max(code) from subwrh where code like @datestr+'%'), 
    @datestr+'0000')
  execute nextbn @maxsubwrh, @maxsubwrh output

  select @subwrh = subwrhgid from system
  update system set subwrhgid = @subwrh + 1

  insert into subwrh (GID, CODE, NAME, WRH)
	values (@subwrh, @maxsubwrh, @maxsubwrh, @wrh)
	
	return 0
end

GO
