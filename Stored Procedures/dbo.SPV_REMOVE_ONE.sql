SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create proc [dbo].[SPV_REMOVE_ONE]
  (
    @piSN       varchar(32),                -- series number
    @piOperGid  int,                        -- 操作人
    @poErrMsg   varchar(255) output         --出错信息
  )
  as
  begin
    set nocount on;
    declare @vCount int;
    declare @vUID   int;

    delete SPVOUCHER
     where SN = @piSN
       and STAT = 0;

    if @@rowcount = 0
    begin
      set @poErrMsg = '此券不存在或状态不符！删除未执行';
      return(1);
    end;

    select @vCount = max(ITEMNO)
      from SPVOUCHERLOG (nolock)
      where SN = @piSN;
    set @vCount = isnull(@vCount, 0) + 1;
    select @vUID = USERGID --ltrim(rtrim(USERCODE)) + '[' + ltrim(rtrim(USERNAME)) + ']'
      from system (nolock);
    insert into SPVOUCHERLOG(SN, ITEMNO, FROMSTAT, TOSTAT, OPER, OPERTIME, SRC,note)
           values(@piSN, @vCount, 0, 0, @piOperGid, getdate(), @vUID,'删除此券');

    return (0)
  end
GO
