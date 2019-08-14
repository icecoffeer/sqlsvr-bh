SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[BillToAdj_ValidGdDtl]
(
  @num  varchar(14)
) as
begin
  --取得当前单据中的商品,依次判断是否不能生效
  --判断的条件包括(未审核的 损耗单、溢余单、内部调拨单、库存转移单及盘点单等)
  --如果发现有商品不能生效,那么更新反馈明细表BILLTOADJFEEDBCKDTL,并返回1
  --目前只有美凯龙增加此判断

  return 0
end
GO
