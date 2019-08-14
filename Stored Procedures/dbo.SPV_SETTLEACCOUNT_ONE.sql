SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create proc [dbo].[SPV_SETTLEACCOUNT_ONE]
  (
    @piSN       varchar(32),                -- series number
    @piOperGid  int,                        -- 操作人
    @poErrMsg   varchar(255) output         -- 出错信息
  )
  as
  begin
    set nocount on;
    declare @vRnt   int;
    declare @vExv   int;
    declare @vCount int;
    declare @vUID   int;
    declare @vStat  int;

    set @vRnt = 0;
    set @poErrMsg = '';
    set @piSN = isNull(@piSN, '');

    update SPVOUCHER
       set PHASE = 1
     where SN = @piSN
       and PHASE = 0
       and STAT >= 700;
    select @vRnt = @vRnt + @@error, @vExv = @@rowcount;
    if @vExv = 0
    begin
      select @vExv = count(*)
        from SPVOUCHER
       where SN = @piSN;
      if @vExv = 0
      begin
        set @poErrMsg = '此券不存在！';
        return (1);
      end;
      set @vRnt = @vRnt + 1;
      set @poErrMsg = '此券的状态不符或者已经结清！';
      return(@vRnt);
    end;

    select @vCount = max(ITEMNO)
      from SPVOUCHERLOG
      where SN = @piSN;
    set @vRnt = @vRnt + @@error;

    set @vCount = isnull(@vCount, 0) + 1;
    select @vUID = USERGID                 ---- 门店GID
      from system (nolock);
    set @vRnt = @vRnt + @@error;
    if @vRnt > 0
    begin
      set @poErrMsg = '访问数据库出错！';
      return (@vRnt);
    end;
    select @vStat = STAT
      from SPVOUCHER
      where SN = @piSN;
    insert into SPVOUCHERLOG(SN, ITEMNO, FROMSTAT, TOSTAT, OPER, OPERTIME, SRC, NOTE)
           values(@piSN, @vCount, @vStat, @vStat, @piOperGid, getdate(), @vUID, '单张结算');
    set @vRnt = @vRnt + @@error;

    return (@vRnt)
  end
GO
