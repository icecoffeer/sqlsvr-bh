SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[OrderPool_Append](
  @piUUID varchar(38),
  @piGdGid int,
  @piVdrGid int,
  @piWrh int,
  @piCombineType char(10),
  @piSendDate datetime,
  @piQty decimal(24,4),
  @piPrice decimal(24,4),
  @piOrderType char(10),
  @piImpTime datetime,
  @piImporter char(30),
  @piOrderDate datetime,
  @piSplitDays int,
  @piNote varchar(255),
  @piRoundType char(10),
  @piStoreOrdApplyType int,
  @piStoreOrdApplyStat int,
  @poErrMsg varchar(255) output
)
as
begin
  declare
    @vUUID varchar(38)

  if IsNull(@piUUID, '') = ''
    exec HD_CREATEUUID @vUUID output
  else
    set @vUUID = @piUUID

  if not exists(select UUID from ORDERPOOL(nolock) where UUID = @vUUID)
  begin
    insert into ORDERPOOL(UUID, GDGID, VDRGID, WRH, COMBINETYPE, SENDDATE,
      QTY, PRICE, ORDERTYPE, IMPTIME, IMPORTER, ORDERDATE,
      SPLITDAYS, NOTE, ROUNDTYPE, STOREORDAPPLYTYPE, STOREORDAPPLYSTAT)
      select @vUUID, @piGdGid, @piVdrGid, @piWrh, @piCombineType, @piSendDate,
        @piQty, @piPrice, @piOrderType, @piImpTime, @piImporter, @piOrderDate,
        @piSplitDays, @piNote, @piRoundType, @piStoreOrdApplyType, @piStoreOrdApplyStat
  end

  return 0
end
GO
