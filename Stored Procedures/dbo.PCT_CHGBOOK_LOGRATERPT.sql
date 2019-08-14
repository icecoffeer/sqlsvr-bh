SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCT_CHGBOOK_LOGRATERPT] (
  @piCntrNum varchar(14),                 --合约号
  @piCntrVersion integer,                 --合约版本号
  @piChgCode varchar(10),                 --帐款项目
  @piFeeDate datetime,                    --费用日期
  @piGenDate datetime,                    --生成日期
  @piBeginDate datetime,                  --统计开始日期
  @piEndDate datetime,                    --统计结束日期
  @piBaseTotal decimal(24, 2),            --统计基数
  @piRateTotal decimal(24, 2)             --提成金额
) as
begin
  insert into CTCNTRRATERPT(NUM, VERSION, CHGCODE, FEEDATE, GENDATE, BEGINDATE, ENDDATE, BASETOTAL, RATETOTAL)
  values(@piCntrNum, @piCntrVersion, @piChgCode, @piFeeDate, @piGenDate, @piBeginDate, @piEndDate, @piBaseTotal, @piRateTotal)
end
GO
