SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create proc [dbo].[SPV_MODIFY_ONE]
  (
    @piSN       varchar(32),                -- series number
    @piFromStat int,
    @piToStat   int,
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
    declare @SigStatJmp char(1);

    set @vRnt = 0;
    set @poErrMsg = '';
    set @piSN = isNull(@piSN, '');

    if @piToStat = 900-- or @piToStat = 900
    begin
      set @poErrMsg = '回收动作请执行SPV_HANDUP_，本过程拒绝执行！';
      return(1);
    end;

    select @vStat = STAT
      from SPVOUCHER (nolock)
      where SN = @piSN;
    select @vRnt = @vRnt + @@error, @vExv = @@rowcount

    if @vStat >= @piToStat or @piFromStat >= @piToStat
    begin
      set @poErrMsg = '状态倒置，拒绝执行！';
      return(1);
    end;

    select @SigStatJmp = upper(OPTIONVALUE)      ----'在状态流转的过程中，是否允许跳过中间的状态。Y:允许跳过;N:禁止跳过中间状态'
      from HDOPTION (nolock)
      where MODULENO = 612
        and upper(OPTIONCAPTION) = 'STAT_JUMP';

    set @vCount = 0;
    select @vCount = count(*)
      from modulestatflow
     where moduleno = 613
       and STATNO > @vStat
       and STATNO < @piToStat;

    if @SigStatJmp = 'N' and @vCount > 0
    begin
      set @poErrMsg = '当前的系统设置禁止跳过中间状态，因此拒绝执行这种流转：'
                    + cast(@vStat as varchar) + '->' + cast(@piToStat as varchar);
      return(1);
    end;

    declare @usercode varchar(128)
    select @usercode =rtrim(ltrim(usercode)) + '[' + rtrim(ltrim(username)) + ']' from system
    if @piToStat = 700
      if exists( select 1 from SPVOUCHER(nolock) where  SN = @piSN and isnull(bessrc,'') <> @usercode)
         begin
            set @poErrMsg = '此券'+@piSN+'，不是本店领用的不能在本店发放!';
           return(1);
         end;

    update SPVOUCHER
       set STAT = @piToStat
     where SN = @piSN;
    select @vRnt = @vRnt + @@error, @vExv = @@rowcount;
    if @vExv = 0
    begin
      set @poErrMsg = '此券未找到'+@piSN+'，无法完成任务！';
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
           values(@piSN, @vCount, @vStat, @piToStat, @piOperGid, getdate(), @vUID);
    set @vRnt = @vRnt + @@error;

    if @vRnt > 0
      set @poErrMsg = '访问数据库错误！';

    return (@vRnt)
  end
GO
