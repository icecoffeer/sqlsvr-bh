SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFIntfForHD_LogQryArticle](
  @piUUID varchar(38),                  --唯一编号
  @piPDANum varchar(40),                --机器号
  @piEmpCode varchar(10),               --员工代码
  @piOperTime datetime,                 --查询时间
  @piWrhCode varchar(10),               --仓位代码
  @piArticleCode varchar(40),           --货品代码
  @piStat smallint,                     --状态：0-未确认查询；1-确认查询；2-报告缺货；3-盘点
  @piInvQty decimal(24,4),              --库存
  @poErrMsg varchar(255) output         --错误信息
)
as
begin
  delete from QRYARTICLELOG where UUID = @piUUID
  insert into QRYARTICLELOG(UUID, PDANUM, OPERCODE, OPERTIME,
    WRHCODE, ARTICLECODE, STAT, INVQTY)
    select @piUUID, @piPDANum, @piEmpCode, @piOperTime,
    @piWrhCode, @piArticleCode, @piStat, @piInvQty

  return 0
end
GO
