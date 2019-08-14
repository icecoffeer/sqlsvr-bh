SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFIntfForHD_OrdStkin_ParseOneNum](
  @piSrcCode varchar(10),       --传入参数：定单来源单位代码。
  @piSrcNum varchar(10),        --传入参数：定单来源单号。
  @poOrdNum varchar(10) output  --传出参数（返回值为0时有效）：定单号。
) as
begin
  declare
    @UserCode varchar(10), --本店代码
    @SrcGid int --来源单位GID

  --读取系统设定。
  select @UserCode = rtrim(USERCODE) from SYSTEM(nolock)

  --初始化传出参数。
  set @poOrdNum = ''

  --根据来源单位代码及来源单号，找到其对应的定单号。
  if @piSrcCode = @UserCode
  begin
    set @poOrdNum = @piSrcNum
  end
  else if exists(select 1 from STORE(nolock) where CODE = @piSrcCode)
  begin
    select @SrcGid = GID from STORE(nolock) where CODE = @piSrcCode
    select @poOrdNum = max(NUM)
      from ORD(nolock)
      where SRC = @SrcGid
      and SRCNUM = @piSrcNum
  end

  --返回。
  if @poOrdNum is null or rtrim(@poOrdNum) = ''
    return 1
  else
    return 0
end
GO
