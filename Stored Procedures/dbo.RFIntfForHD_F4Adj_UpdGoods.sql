SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFIntfForHD_F4Adj_UpdGoods](
  @piRFNo varchar(20),
  @piGdCode varchar(13),
  @piLength decimal(24,4),
  @piWidth decimal(24,4),
  @piHeight decimal(24,4),
  @piFillerCode varchar(10),
  @poErrMsg varchar(255) output
)
as
begin
  --记录日志

  insert into RFGOODSVERSIONLOG(UUID, STORECODE, RFNO,
    GDCODE, LENGTH, WIDTH, HEIGHT,
    FILLERCODE, FILDATE, LSTUPDTIME, SUBTIME, LAUNCHED)
    select newid(), USERCODE, @piRFNo,
    @piGdCode, @piLength, @piWidth, @piHeight,
    @piFillerCode, getdate(), getdate(), getdate(), 1
    from SYSTEM(nolock)

  --影响GOODS.F4

  declare @F4 varchar(50)
  set @F4 = convert(varchar, convert(int, isnull(@piLength, 0))) + '*' +
    convert(varchar, convert(int, isnull(@piWidth, 0))) + '*' +
    convert(varchar, convert(int, isnull(@piHeight, 0)))

  update GOODS set
    F4 = @F4,
    LSTUPDTIME = getdate()
    where CODE = @piGdCode

  return 0
end
GO
