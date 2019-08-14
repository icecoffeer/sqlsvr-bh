SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCT_CHGBOOK_UPDIVCFIELD] (
  @piChgCode varchar(20),               --账款项目
  @piNum varchar(14)                    --费用单单号
) as
begin
  declare
    @vGatheringMode varchar(20), --收款方式
    @vOptUseGenEIvc int --是否启用选项

  Exec OptReadInt 0, 'PS3_UseGenEInvoice', 0, @vOptUseGenEIvc output
  select @vGatheringMode = GatheringMode
    from CTCHGDEF where CODE = @piChgCode
  --启用选项时,只有自动账扣类的费用单才做更新
  if (@vOptUseGenEIvc = 0) or (@vGatheringMode <> '冲扣货款')
    Return 0

  Update ChgBook Set
    TaxRate = c.TaxRate,
    IvcDtlName = c.IvcDtlName,
    TaxSortCode = c.TaxSortCode
  From CtChgDef c
  Where ChgBook.ChgCode = c.Code
    And ChgBook.Num = @piNum

  return 0
end
GO
