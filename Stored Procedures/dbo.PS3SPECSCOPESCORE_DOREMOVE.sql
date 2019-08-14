SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create Procedure [dbo].[PS3SPECSCOPESCORE_DOREMOVE]
(
    @Num varchar(14),         --单号
    @Cls varchar(10),
    @Msg varchar(255) output  --错误信息
)
as
begin
  delete from PS3SPECSCOPESCORE where NUM = @Num and CLS = @Cls
  delete from PS3SPECSCOPESCOREDTL where NUM = @Num and CLS = @Cls
  delete from PS3SPECSCOPESCORELACSTORE where NUM = @Num and CLS = @Cls
  delete from PS3SPECSCOPESCOREPROMSUBJOUTDTL where NUM = @Num and CLS = @Cls
  delete from PS3SPECSCOPESCORESPECDIS where NUM = @Num and CLS = @Cls

  SET @MSG = ''
  RETURN(0)
end
GO
