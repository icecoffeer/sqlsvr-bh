SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create proc [dbo].[SPV_MODIFY_GROUPHEAD]
  (
    @piForeSN   varchar(32),                -- the fore part in this group SNs
    @piHead     varchar(32),                -- the first NO in this group SNs
    @piTail     varchar(32),                -- the whole count of this group
    @piFromStat int,
    @piToStat   int,
    @piOperGid  int,                        -- 操作人
    @poErrMsg   varchar(255) output         -- 出错信息
  )
  as
  begin
    declare @vRnt   int;
    declare @vExv   int;
    declare @vUID   int;
    declare @vCount int;
    declare @vStat  int;
    declare @vTopStat int;
    declare @vSN    varchar(32);
    declare @vOperDate  datetime;
    declare @SigStatJmp char(1);

    set @vRnt = 0;
    set @poErrMsg = '';
    set @piForeSN = isNull(@piForeSN, '');
    set @piHead = isNull(@piHead, '');
    set @piTail = isNull(@piTail, '');

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
    if @piToStat = 900
    begin
      set @poErrMsg = '回收动作请执行SPV_HANDUP_，本过程拒绝执行！';
      return(1);
    end;
    if @piToStat <= @piFromStat
    begin
      set @poErrMsg = '状态倒置，拒绝执行！';
      return(1);
    end;

    set @vStat = 0;
    set @vTopStat = 0;
    select @vStat = min(STAT), @vTopStat = max(STAT)
      from SPVOUCHER (nolock)
      where SN >= @piForeSN + @piHead
        and SN <= @piForeSN + @piTail;
    select @vCount = @@rowcount, @vExv = @@error

    if @vTopStat >= @piToStat
    begin
      select top 1 @vSN = SN
        from SPVOUCHER (nolock)
        where SN >= @piForeSN + @piHead
          and SN <= @piForeSN + @piTail
          and STAT >= @piToStat    ---->ToStat 只能执行一次
        order by SN;
      set @poErrMsg = '输入的序列号范围，部分已经执行了该动作，因此拒绝执行。' + char(10) + '其中首个序列号为：' + @vSN;
      return (1);
    end;

    declare @usercode varchar(128)
    select @usercode =rtrim(ltrim(usercode)) + '[' + rtrim(ltrim(username)) + ']' from system
    if @piToStat = 700
      if exists( select 1 from SPVOUCHER(nolock) where SN >= @piForeSN + @piHead and SN <= @piForeSN + @piTail and isnull(bessrc,'') <> @usercode)
         begin
           select top 1 @vSN = SN from SPVOUCHER(nolock)
             where SN >= @piForeSN + @piHead and SN <= @piForeSN + @piTail and isnull(bessrc,'') <> @usercode
           set @poErrMsg = '输入的序列号范围，部分不是本店领用的不能在本店发放,其中首个序列号为：' + @vSN;
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
      select top 1 @vSN = SN
        from SPVOUCHER (nolock)
        where SN >= @piForeSN + @piHead
          and SN <= @piForeSN + @piTail
          and STAT = @vStat    ---->ToStat 只能执行一次
        order by SN;
      set @poErrMsg = '当前的系统设置禁止跳过中间状态，因此拒绝执行这种操作： 券' + cast(@vSN as varchar) + '状态流转:'
                    + cast(@vStat as varchar) + '->' + cast(@piToStat as varchar);
      return(1);
    end;

    set @vOperDate = getdate();
    select @vUID = USERGID
      from system (nolock) ;
    set @vRnt = @vRnt + @@error;

    if not exists(select top 1 1 from SPVOUCHER where SN >= @piForeSN + @piHead and SN <= @piForeSN + @piTail)
        begin
           set @poErrMsg = '没有满足要求的券！';
           return(1);
        end;

    insert into SPVOUCHERLOG(SN, ITEMNO, FROMSTAT, TOSTAT, OPER, OPERTIME, SRC, NOTE)
           select mst.SN  SN, isnull(max(hlg.itemno), 0) + 1 ITEMNO
                 ,isnull(max(mst.STAT), 0) FROMSTAT, @piToStat TOSTAT
                 ,@piOperGid OPER, @vOperDate OPERTIME, @vUID SRC, ('批量更改，批次:' + @piForeSN) NOTE
           from  spvoucher mst (nolock) left outer join spvoucherlog hlg (nolock) on  mst.SN = hlg.SN
           where mst.SN >= @piForeSN + @piHead       --            where mst.SN >= @piForeSN + cast(@piHead as varchar)
             and mst.SN <= @piForeSN + @piTail       --              and mst.SN <= @piForeSN + cast(@piTail as varchar)
           group by mst.SN;
    set @vRnt = @vRnt + @@error;

    update SPVOUCHER
       set STAT = @piToStat
      from SPVOUCHER
      where SN >= @piForeSN + @piHead
        and SN <= @piForeSN + @piTail;
    set @vRnt = @vRnt + @@error;

    if @vRnt > 0
      set @poErrMsg = '访问数据库错误！';

    return (@vRnt)
  end
GO
