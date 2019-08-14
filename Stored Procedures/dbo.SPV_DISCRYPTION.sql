SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create proc [dbo].[SPV_DISCRYPTION]
  (
    @piENSN   varchar(32),         -- encrypted series number
    @poSN     varchar(64)  output  -- series number
  )
  as
  begin
    declare @poSNTmp varchar(64)

    set nocount on;
    declare @vRnt   int;
    declare @vExv   int;
    set @vRnt = 0;
   --ShenMin
    if (select count (SN) from SPVOUCHER (nolock)
        where ENSN = upper(@piENSN)) > 1
      begin
        set @poSN = ''
        return(800)
      end

    select @poSNTmp = SN
      from SPVOUCHER (nolock)
      where ENSN = upper(@piENSN);
   --ShenMin
    if @poSNTmp = '' or @poSNTmp is null
      set @vRnt = 1
    else
      set @poSN = @poSNTmp
    select @vRnt = @vRnt + @@error, @vExv = @@rowcount;
    return (@vRnt);
  end
GO
