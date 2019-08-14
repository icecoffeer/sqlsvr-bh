SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create proc [dbo].[SPV_HANDUP_GROUPHEAD]
  (
    @piForeSN   varchar(32),                -- the fore part in this group SNs
    @piHead     varchar(32),                -- the first NO in this group SNs
    @piTail     varchar(32),                -- the last NO in this group SNs
    @piOperGid  int,                        -- 操作人
    @poErrMsg   varchar(255) output         --出错信息
  )
  as
  begin
    declare @vRnt   int;
    declare @vExv   int;
    declare @vUID   int;
    declare @vCount int;
    declare @vRoom  int;
    declare @vSN    varchar(32);
    declare @vEFlag varchar(8);
    declare @vlp    int;
    declare @vOperDate datetime;
    declare @vStat  int;
    declare @vTopStat  int;
    declare @SigStatJmp char(1);

    set @vRnt = 0;
    set @poErrMsg = '';
    set @piForeSN = isNull(@piForeSN, '');
    set @piHead = isNull(@piHead, '');
    set @piTail = isNull(@piTail, '');
    set @vlp = 0;

    if len(@piHead) <> len(@piTail)
    begin
      set @poErrMsg = '起始与结束序列号，其尾部的长度不同，拒绝批量操作';
      return (1);
    end;
    if len(@piHead) < 6 or len(@piHead) > 14
    begin
      set @poErrMsg = '序列号的尾部长度超出允许范围(6-14)，拒绝批量操作';
      return(1);
    end;

    set @vCount = 0;
    set @vStat = 0;
    set @vTopStat = 0;
    select @vStat = min(STAT), @vTopStat = max(STAT)
      from SPVOUCHER (nolock)
      where SN >= @piForeSN + @piHead
        and SN <= @piForeSN + @piTail;
    select @vCount = @@rowcount, @vExv = @@error

    if @vTopStat >= 900
    begin
      select top 1 @vSN = SN
        from SPVOUCHER (nolock)
        where SN >= @piForeSN + @piHead
          and SN <= @piForeSN + @piTail
          and STAT >= 900
        order by SN;
      set @poErrMsg = '输入的序列号范围，部分已经被回收，拒绝执行。' + char(10) + '其中首个序列号为：' + @vSN;
      return (1);
    end;

    if @vStat < 700
    begin
      select top 1 @vSN = SN
        from SPVOUCHER (nolock)
        where SN >= @piForeSN + @piHead
          and SN <= @piForeSN + @piTail
          and STAT < 700
        order by SN;
      set @poErrMsg = '输入的序列号范围，部分没有发放过，拒绝执行。' + char(10) + '其中首个序列号为：' + @vSN;
      return (1);
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
       and STATNO < 900;

    if @SigStatJmp = 'N' and @vCount > 0
    begin
      select top 1 @vSN = SN
        from SPVOUCHER (nolock)
        where SN >= @piForeSN + @piHead
          and SN <= @piForeSN + @piTail
          and STAT = @vStat    ---->ToStat 只能执行一次
        order by SN;
      set @poErrMsg = '当前的系统设置禁止跳过中间状态，因此拒绝执行这种操作： 券' + cast(@vSN as varchar) + '状态流转:'
                    + cast(@vStat as varchar) + '->900' ;
      return(1);
    end;

    set @vOperDate = getdate();
    select @vUID = USERGID
      from system (nolock);
    set @vRnt = @vRnt + @@error;


    if not exists(select top 1 1 from SPVOUCHER where SN >= @piForeSN + @piHead and SN <= @piForeSN + @piTail)
        begin
           set @poErrMsg = '没有满足要求的券！';
           return(1);
        end;

    insert into SPVOUCHERLOG(SN, ITEMNO, FROMSTAT, TOSTAT, OPER, OPERTIME, SRC, NOTE)
           select mst.SN  SN, isnull(max(hlg.itemno), 0) + 1 ITEMNO
                 ,max(mst.STAT) FROMSTAT, 900 TOSTAT
                 ,@piOperGid OPER, @vOperDate OPERTIME, @vUID SRC, ('批量回收，批次:' + @piForeSN) NOTE
           from  spvoucher mst left outer join spvoucherlog hlg on  mst.SN = hlg.SN
           where mst.SN >= @piForeSN + @piHead
             and mst.SN <= @piForeSN + @piTail
           group by mst.SN;
    set @vRnt = @vRnt + @@error;

    update SPVOUCHER
       set STAT = 900
      from SPVOUCHER
      where SN >= @piForeSN + @piHead
        and SN <= @piForeSN + @piTail;
    set @vRnt = @vRnt + @@error;

    if @vRnt > 0
      set @poErrMsg = @poErrMsg + '数据库访问错误';


    return (@vRnt)
  end
GO
