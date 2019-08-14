SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCRM_SCORE_DEFINE]
(
  @piCls varchar(10),            --积分规则类型，取值：储值、消费
  @piAmount money,               --金额
  @piScore money,                --积分
  @piOperGid int,                --操作员
  @piMinAmount money,            --起始金额
  @piErrMsg varchar(255) output  --错误信息
) as
begin
  delete from CRMSCORE where CLS = @piCls
  insert into CRMSCORE(CLS, AMOUNT, SCORE, MINAMOUNT)
  values(@piCls, @piAmount, @piScore, @piMinAmount)
  return(0)
end
GO
