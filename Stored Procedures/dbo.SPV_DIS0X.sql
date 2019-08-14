SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create proc [dbo].[SPV_DIS0X]
  (
    @pich   varchar(4),         -- encrypted series number
    @poNm   char(1)  output  -- series number
  )
  as
  begin
    declare @ee   smallint;
    declare @vv   smallint;
    declare @nlp  smallint;
    declare @vMod smallint;
    set @vv = 0;
    set @nlp = 4
    set @vMod = 1
    while @nlp > 0
    begin
      set @ee = cast(substring(@pich, @nlp, 1) as int); -- the NO @nlp character
      if @ee = 1
        set @vv = @vv + @vMod
      set @vMod = @vMod * 2;
      set @nlp = @nlp - 1
    end;
    set @poNm = case @vv when 15 then 'F'
                         when 14 then 'E'
                         when 13 then 'D'
                         when 12 then 'C'
                         when 11 then 'B'
                         when 10 then 'A'
                     else cast(@vv as char(1))
                end;
    return(0);
  end
GO
