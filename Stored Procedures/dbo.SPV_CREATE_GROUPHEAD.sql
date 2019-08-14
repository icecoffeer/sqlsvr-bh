SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create proc [dbo].[SPV_CREATE_GROUPHEAD]
  (
    @piForeSN   varchar(32),                -- the fore part in this group SNs
    @piHead     varchar(32),                        -- the first NO in this group SNs
    @piTail     varchar(32),                        -- the last NO in this group SNs
    @piTotal    decimal(24,2),
    @piOperGid  int,                        -- 操作人
    @poErrMsg   varchar(255) output         --出错信息
  )
  as
  begin
    set nocount on;
    declare @vRnt   int;
    declare @vExv   int;
    declare @vUID   int;
    declare @vCount int;
    declare @vRoom  int;
    declare @vLast  varchar(64);
    declare @vSN    varchar(32);
    declare @vTmp   varchar(32);
    declare @vENSN  varchar(64);
    declare @vEFlag varchar(8);
    declare @vNow   datetime;

    set @vNow = getdate();
    set @vRnt = 0;
    set @poErrMsg = '';
    set @piForeSN = isNull(@piForeSN, '');
    set @piHead = isNull(@piHead, '');
    set @piTail = isNull(@piTail, '');

   --2006.1.4, Edited by ShenMin, Q5969, 购物券程序生成序列号
    declare @SNLEN int
    exec OPTREADINT 612, 'SNLEN', 0, @SNLEN output
    if len(@piForeSN+@piHead) <> @SNLEN
      begin
        set @poErrMsg = '此券长度为' + convert(varchar(2),@SNLEN) + ', 与设置不符！';
      return(1);
      end;

    if len(@piHead) <> len(@piTail)
    begin
      set @poErrMsg = '起始与结束序列号，其尾部的长度不同，拒绝批量操作';
      return (1);
    end;
    if len(@piHead) < 6 or len(@piHead) > 14
    begin
      set @poErrMsg = '起始或结束序列号，其尾部的长度超出允许范围(6-14)，拒绝批量操作';
      return(1);
    end;
    select @vCount = count(*)
      from SPVOUCHER (nolock)
      where SN >= @piForeSN + @piHead
        and SN <= @piForeSN + @piTail;
    if @vCount > 0
    begin
      select top 1 @vSN = SN
        from SPVOUCHER (nolock)
        where SN >= @piForeSN + @piHead
          and SN <= @piForeSN + @piTail
        order by SN;
      set @poErrMsg = '输入的序列号范围已经被部分占用，拒绝执行' + char(10) + '其中首个序列号为：' + @vSN;
      return (1);
    end;

    select @vEFlag = upper(OPTIONVALUE)      ----'Y', '加密与否,Y:加密,N:不加密'
      from HDOPTION (nolock)
      where MODULENO = 612
        and upper(OPTIONCAPTION) = 'ENCRYPTION';
    select @vUID = USERGID --ltrim(rtrim(USERCODE)) + '[' + ltrim(rtrim(USERNAME)) + ']'
      from system (nolock) ;

    set @vNow = getdate();
--     set @vSN = @piForeSN + @piHead;
--     set @vLast = @piForeSN + @piTail;
    set @vSN = @piHead;
    set @vENSN = '';
    set @vLast = @piTail;
    while @vSN <= @vLast
    begin
      if @vEFlag = 'Y'
      begin
        set @vTmp = @piForeSN + @vSN;
        exec @vExv = SPV_ENCRYPTION @vTmp, @vENSN output;
        set @vRnt = @vRnt + @vExv + @@error ;
      end;
      insert into SPVOUCHER (SN, STAT, PHASE, FILDATE, SALEAMT, ENSN)
             values(@piForeSN + @vSN, 0, 0, @vNow, @piTotal, @vENSN);
      set @vRnt = @vRnt + @@error;
      insert into SPVOUCHERLOG(SN, ITEMNO, FROMSTAT, TOSTAT, OPER, OPERTIME, SRC, NOTE)
           values(@piForeSN + @vSN, 1, 0, 0, @piOperGid, @vNow, @vUID, '批量制作，批次:' + @piForeSN);
      set @vCount = @vCount + @@error;
      exec @vExv = NEXTBN @vSN, @vENSN output --2006.1.4, Edited by ShenMin, Q5969, 购物券程序生成序列号
      set @vRnt = @vRnt + @@error;
      set @vSN = @vENSN;
      set @vENSN = '';
    end;

    if @vRnt > 0
       set @poErrMsg = @poErrMsg + '批量输入序列号出错';

    return (@vRnt)
  end
GO
