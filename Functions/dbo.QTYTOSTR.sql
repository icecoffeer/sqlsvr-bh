SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create function [dbo].[QTYTOSTR]
(
  @qty decimal(24, 4),
  @qpc decimal(24, 4)
) returns varchar(50) as
begin
  declare
    @str varchar(50),
    @v_i int,  --整箱数
    @v_j decimal(24, 4)   --拆零数

  if @qpc = 0
    set @str = convert(varchar(50), @qty);
  else begin
    set @v_i = floor(abs(@qty)/@qpc);   --整箱数为数量除以包装规格的整数部分
    set @v_j = abs(@qty) - @qpc*@v_i;   --剩余部分为拆零数
    if @qty > 0
    begin
      if @v_j = 0
        set @str = convert(varchar(20), @v_i);
      else
        set @str = convert(varchar(20), @v_i) + '+' + convert(varchar(29), @v_j);  --?
    end
    else if @qty = 0
      set @str = '0';
    else begin
      if @v_j = 0
        set @str = '-' + convert(varchar(20), @v_i);
      else
        set @str = '-(' + convert(varchar(20), @v_i) + '+' + convert(varchar(29), @v_j) + ')';
    end;
  end;
  return @str;
end
GO
