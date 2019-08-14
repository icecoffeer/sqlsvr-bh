SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create proc [dbo].[SPV_CREATE_GROUPNUMBER]
  (
    @piForeSN   varchar(32),                -- the fore part in this group SNs
    @piHead     varchar(32),                        -- the first NO in this group SNs
    @piCount    int,
    @piTotal    decimal(24,2),
    @piOperGid  int,                        -- 操作人
    @poErrMsg   varchar(255) output         --出错信息
  )
  as
  begin
    set nocount on;
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
    set @vCount = 1;
    while @vCount < @piCount
    begin
      exec @vExv = NEXTBN @vSN, @vNext output; --2006.1.4, Edited by ShenMin, Q5969, 购物券程序生成序列号
      set @vSN = @vNext;
      set @vCount = @vCount + 1;
    end;

    exec @vRnt = SPV_CREATE_GROUPHEAD @piForeSN, @piHead, @vSN, @piTotal, @piOperGid, @poErrMsg output;

    return (@vRnt)
  end
GO
