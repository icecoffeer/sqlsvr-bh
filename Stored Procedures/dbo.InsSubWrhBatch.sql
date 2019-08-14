SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


create procedure [dbo].[InsSubWrhBatch]
  @wrh int,
  @subwrh int,
  @errmsg varchar(200) = '' output
as
begin
  /*
  输入: @WRH,仓位GID.
       @SUBWRH,货位GID
  改变数据: 新增一个货位
    GID=@subwrh,
    CODE的格式为“YYMMDDXXXX”. 前6位通过当前日期得到，后4位流水. NAME中的内容与CODE相同 
  */
  declare @datestr char(6), @string char(20), @maxsubwrh char(10)

  /* 2000-12-14 把判断提前以提高效率 */
  if not exists(select 1 from subwrh where gid = @subwrh)
  begin
    select @string = convert(char(10), getdate(), 102)
    select @datestr = substring(@string,3,2) + substring(@string,6,2) +	substring(@string,9,2)
    select @maxsubwrh = isnull(
      (select max(code) from subwrh where code like @datestr+'%'), 
      @datestr+'0000')
    execute nextbn @maxsubwrh, @maxsubwrh output

    /* 2000-9-29 */
    /* 2000-12-14 if not exists(select 1 from subwrh where gid = @subwrh) */
    insert into subwrh (GID, CODE, NAME, WRH)
    values (@subwrh, @maxsubwrh, @maxsubwrh, @wrh)
  end
  
  return 0
end

GO
