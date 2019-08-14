SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create proc [dbo].[SPV_CREATE_ONE]
  (
    @piSN       varchar(32),                -- series number
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
    declare @vUID   int;
    declare @vENSN  varchar(64);
    declare @vEFlag varchar(8);

    set @vRnt = 0;
    set @poErrMsg = '';
    set @piSN = isNull(@piSN, '');

    declare @SNLEN int
    select @SNLEN = OPTIONVALUE
      from HDOPTION (nolock)
      where MODULENO = 612
        and upper(OPTIONCAPTION) = 'SNLEN';
    if len(@piSN) <> @SNLEN
      begin
        set @poErrMsg = '此券长度不为要求的长度'+convert(varchar(2),@SNLEN);
      return(1);
      end;

    select @vCount = count(*)
      from SPVOUCHER (nolock)
      where SN = @piSN;

    if @vCount > 0
    begin
      set @poErrMsg = '已经存在序列号为:[' + @piSN + ']的券';
      return (1);
    end;

    select @vEFlag = upper(OPTIONVALUE)      ----'Y', '加密与否,Y:加密,N:不加密'
      from HDOPTION (nolock)
      where MODULENO = 612
        and upper(OPTIONCAPTION) = 'ENCRYPTION';
    if @vEFlag = 'Y'
      exec SPV_ENCRYPTION @piSN, @vENSN output;

    insert into SPVOUCHER (SN, STAT, PHASE, FILDATE, SALEAMT, ENSN)
           values(@piSN, 0, 0, getdate(), @piTotal, @vENSN);
    set @vRnt = @vRnt + @@error;

    select @vCount = max(ITEMNO)
      from SPVOUCHERLOG (nolock)
      where SN = @piSN;
    set @vCount = isnull(@vCount, 0) + 1;
    select @vUID = USERGID --ltrim(rtrim(USERCODE)) + '[' + ltrim(rtrim(USERNAME)) + ']'
      from system (nolock);
    insert into SPVOUCHERLOG(SN, ITEMNO, FROMSTAT, TOSTAT, OPER, OPERTIME, SRC,note)
           values(@piSN, @vCount, 0, 0, @piOperGid, getdate(), @vUID,'制作此券');
    return (@vRnt)
  end
GO
