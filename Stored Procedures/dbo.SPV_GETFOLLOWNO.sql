SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create proc [dbo].[SPV_GETFOLLOWNO]
  (
    @piFirst  varchar(14),         -- encrypted series number
    @piCount  int,
    @poLast   varchar(14)  output  -- series number
  )
  as
  begin
    set nocount on;
    declare @vExv  int;
    declare @vNum  varchar(16);
    declare @vNext varchar(16);

    if len(@piFirst) < 6 or len(@piFirst) > 14
    begin
      set @poLast = '';
      return (1);
    end;
    set @vNum = @piFirst;
    set @vExv = 1;
    while @vExv < @piCount
    begin
      exec NEXTBN2 @vNum, @vNext output;
      set @vNum = @vNext;
      set @vExv = @vExv + 1;
    end
    set @poLast = @vNum;
    return (0);
  end
GO
