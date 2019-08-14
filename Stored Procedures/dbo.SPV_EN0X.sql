SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create proc [dbo].[SPV_EN0X]
  (
    @piNm   char(1),         -- encrypted series number
    @poch   varchar(4)  output  -- series number
  )
  as
  begin
    declare @vv   smallint;
    declare @vMod smallint;
    set @piNm = upper(@piNm);
    set @vv = ascii(@piNm);
    if @vv < 48 or @vv > 57
       if @vv < 65 or @vv > 70
          return 1;
    set @vv = case @piNm when 'F' then 15
                         when 'E' then 14
                         when 'D' then 13
                         when 'C' then 12
                         when 'B' then 11
                         when 'A' then 10
                     else cast (@piNm as int)
                end;
    set @poch = '';
    set @vMod = 8
    while @vMod >= 1
    begin
      if @vv < @vMod
        set @poch = @poch + '0'
      else
      begin
        set @poch = @poch + '1'
        set @vv = @vv - @vMod
      end;
      set @vMod = @vMod / 2;
    end;
  end
GO
