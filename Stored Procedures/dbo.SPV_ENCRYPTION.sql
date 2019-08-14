SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create proc [dbo].[SPV_ENCRYPTION]
  (
    @piSN   varchar(32),          -- series number
    @poENSN varchar(256)    output -- encrypted series number
  )
  as
  begin
    set nocount on;
    declare @vRnt  int;
    declare @vExv  int;
    declare @vlp   smallint;
    declare @vTop  smallint;
    declare @vlast smallint;
    declare @vch   varchar(255);
    declare @vrr   varchar(255);
    declare @vRm   char(4);
    declare @vEE   char(1);

    set @vRnt = 0;
    --set @piSN = upper(@piSN);
    set @poENSN = '';
    set @vch = '';
    set @vlp = len(@piSN);
    set @vTop = cast(substring(@piSN, @vlp, 1) as smallint);
    set @vTop = @vTop % @vlp;   ---- 移动@vlp以上的，不需要重复移动，只需要把余数做掉即可
    if (@vlp <= 1) or (@vTop = 0)
    begin
      set @poENSN = @piSN;
      return(0);
    end;

    set @vlp = @vlp - 1;
    while @vlp > 0
    begin
      set @vEE = substring(@piSN, @vlp, 1);
      exec @vExv = SPV_EN0X @vEE, @vRm output;
      if @vExv > 0 return (@vExv);
      set @vch = @vRm + @vch;
      set @vlp = @vlp - 1;
    end;
    -- @vch 为转成2进制的结果
    if @vTop > len(@vch)
      return(1);
    if ((@vTop % 2) <> 0)     ---- ####  奇数
    begin
      set @vrr = right(@vch, @vTop) + left(@vch, len(@vch) - @vTop);
    end else if (@vTop <> 0)  ---- ####  偶数
    begin
      set @vrr = right(@vch, @vTop - 1) + left(@vch, len(@vch) - @vTop + 1);
    end else
      set @vrr = @vch;
    -- @vrr 为右移的结果
    set @vch = '';
    set @vlp = len(@vrr) - 3
    while (@vlp > 0)
    begin
      set @vRm = substring(@vrr, @vlp ,4);
      exec @vExv = SPV_DIS0X @vRm, @vEE output
      set @vch = @vEE + @vch;
      set @vlp = @vlp - 4;
    end;
    -- @vch 为转成16进制的结果
    set @poENSN = cast(@vTop as char(1)) + right(@vch, len(@vch) - @vTop) + left(@vch, @vTop);
    -- @poENSN 为左移的结果
    return (@vRnt);
  end
GO
