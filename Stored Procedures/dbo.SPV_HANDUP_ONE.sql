SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create proc [dbo].[SPV_HANDUP_ONE]
  (
    @piSN       varchar(32),                -- series number
    @piOperGid  int,                        -- 操作人
    @poErrMsg   varchar(255) output         --出错信息
  )
  as
  begin
    set nocount on;
    declare @vRnt   int;
    declare @vExv   int;
    declare @vCount int;
    declare @vUID   int;
    declare @vStat  int;
    declare @vENSN  varchar(64);
    declare @vEFlag varchar(8);
    declare @SigStatJmp char(1);

    set @vRnt = 0;
    set @poErrMsg = '';
    set @piSN = isNull(@piSN, '');

    select @vStat = STAT, @vENSN = ENSN
      from SPVOUCHER (nolock)
      where SN = @piSN;
    select @vRnt = @vRnt + @@error, @vExv = @@rowcount

    if @vExv = 0
    begin
      set @poErrMsg = '此券不存在于数据库中，拒绝回收！';
      return (1);
    end;
    if @vStat = 900
    begin
      set @poErrMsg = '警告：此券已经回收，系统拒绝再次回收！';
      return (900);    --ShenMin
    end;

    if @vStat <> 700
    begin
      set @poErrMsg = '警告：此券没有发放过，系统拒绝回收！';
      return (2048);
    end;

    select @SigStatJmp = upper(OPTIONVALUE)     ---- '在状态流转的过程中，是否允许跳过中间的状态。Y:允许跳过;N:禁止跳过中间状态'
      from HDOPTION (nolock)
      where MODULENO = 612
        and upper(OPTIONCAPTION) = 'STAT_JUMP';

    set @vCount = 0;
    select @vCount = count(*)
      from modulestatflow
     where moduleno = 613
       and STATNO > @vStat
       and STATNO < 900;

    if @SigStatJmp = 'N' and @vCount > 0
    begin
      set @poErrMsg = '当前的系统设置禁止跳过中间状态，因此拒绝执行这种流转：'
                    + cast(@vStat as varchar) + '-> 900';
      return(1);
    end;

    update SPVOUCHER
       set STAT = 900
       where SN = @piSN;
    select @vRnt = @vRnt + @@error, @vExv = @@rowcount

    if @vExv = 0
    begin
      set @poErrMsg = '此券未找到或状态不符，无法完成任务！';
      return(@vRnt + 128);
    end;

    select @vCount = max(ITEMNO)
      from SPVOUCHERLOG
      where SN = @piSN;
    set @vRnt = @vRnt + @@error;

    set @vCount = isnull(@vCount, 0) + 1;
    select @vUID = USERGID                 ---- 门店GID
      from system (nolock);
    set @vRnt = @vRnt + @@error;
    insert into SPVOUCHERLOG(SN, ITEMNO, FROMSTAT, TOSTAT, OPER, OPERTIME, SRC)
           values(@piSN, @vCount, @vStat, 900, @piOperGid, getdate(), @vUID);
    set @vRnt = @vRnt + @@error;

    return(@vRnt);
  end
GO
