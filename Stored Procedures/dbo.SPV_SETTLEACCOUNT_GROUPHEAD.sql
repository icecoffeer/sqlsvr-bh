SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create proc [dbo].[SPV_SETTLEACCOUNT_GROUPHEAD]
  (
    @piForeSN   varchar(32),                -- the fore part in this group SNs
    @piHead     varchar(32),                -- the first NO in this group SNs
    @piTail     varchar(32),                -- the whole count of this group
    @piOperGid  int,                        -- 操作人
    @poErrMsg   varchar(255) output         -- 出错信息
  )
  as
  begin
    declare @vRnt   int;
    declare @vExv   int;
    declare @vUID   int;
    declare @vCount int;
    declare @vSN    varchar(32);
    declare @vOperDate datetime;

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
      set @poErrMsg = '序列号的其尾部长度超出允许范围(6-14)，拒绝批量操作';
      return(1);
    end;

    select @vCount = count(*)
      from SPVOUCHER (nolock)
      where SN >= @piForeSN + @piHead
        and SN <= @piForeSN + @piTail
        and (STAT not in (700, 900) or PHASE <> 0);
    if @vCount > 0
    begin
      select top 1 @vSN = SN
        from SPVOUCHER (nolock)
        where SN >= @piForeSN + @piHead
          and SN <= @piForeSN + @piTail
          and (STAT not in (700, 900) or PHASE <> 0)
        order by SN;
      set @poErrMsg = '输入的序列号范围中，部分状态不符或已经结清，因此拒绝执行。' + char(10) + '其中首个序列号为：' + @vSN;
      return (1);
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
                 ,max(mst.STAT) FROMSTAT, max(mst.STAT) TOSTAT
                 ,@piOperGid OPER, @vOperDate OPERTIME, @vUID SRC, ('批量结算，批次:' + @piForeSN) NOTE
           from  spvoucher mst (nolock) left outer join spvoucherlog hlg (nolock) on  mst.SN = hlg.SN
           where mst.SN >= @piForeSN + @piHead       --            where mst.SN >= @piForeSN + cast(@piHead as varchar)
             and mst.SN <= @piForeSN + @piTail       --              and mst.SN <= @piForeSN + cast(@piTail as varchar)
           group by mst.SN;
    set @vRnt = @vRnt + @@error;

    update SPVOUCHER
       set PHASE = 1
      from SPVOUCHER
      where SN >= @piForeSN + @piHead
        and SN <= @piForeSN + @piTail
        and STAT in (700, 900)
        and PHASE = 0;
    set @vRnt = @vRnt + @@error;

    if @vRnt > 0
      set @poErrMsg = '访问数据库错误！';

    return (@vRnt)
  end
GO
