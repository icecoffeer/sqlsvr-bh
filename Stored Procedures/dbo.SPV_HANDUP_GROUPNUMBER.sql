SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create proc [dbo].[SPV_HANDUP_GROUPNUMBER]
  (
    @piForeSN   varchar(32),                -- the fore part in this group SNs
    @piHead     varchar(32),                        -- the first NO in this group SNs
    @piCount    int,                        -- the whole count of this group
    @piOperGid  int,                        -- 操作人
    @poErrMsg   varchar(255) output         --出错信息
  )
  as
  begin
    declare @vRnt   int;
    declare @vExv   int;
    declare @vCount int;
    declare @vSN    varchar(32);
    declare @vNext  varchar(32);

    set @vRnt = 0;
    set @poErrMsg = '';
    set @piForeSN = isNull(@piForeSN, '');
    set @piHead = isNull(@piHead, '');

    set @vSN = @piHead;
    set @vCount = 1
    while @vCount < @piCount
    begin
      exec @vExv = NEXTBN2 @vSN, @vNext output
      set @vSN = @vNext
      set @vCount = @vCount + 1;
    end;

    exec @vRnt = SPV_HANDUP_GROUPHEAD  @piForeSN, @piHead, @vSN, @piOperGid, @poErrMsg output

    return (@vRnt)
  end
GO
