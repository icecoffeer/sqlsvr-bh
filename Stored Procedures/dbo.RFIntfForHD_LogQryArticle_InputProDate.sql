SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFIntfForHD_LogQryArticle_InputProDate](
  @piUUID varchar(38),                  --唯一编号
  @piParentUUID varchar(38),            --上级唯一编号
  @piF2 varchar(64),                    --货架
  @piProDate datetime,                  --生产日期
  @piCkQty decimal(24,4),               --盘点数量
  @poErrMsg varchar(255) output         --错误信息
)
as
begin
  delete from QRYARTICLELOGCK where UUID = @piUUID
  insert into QRYARTICLELOGCK(UUID, PARENTUUID, OPERTIME,
    F2, PRODATE, CKQTY)
    select @piUUID, @piParentUUID, getdate(),
    @piF2, @piProDate, @piCkQty

  return 0
end
GO
