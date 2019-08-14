SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create Procedure [dbo].[EMPSALETASK_DOREMOVE]
(
    @Num varchar(14),         --单号
    @Msg varchar(255) output  --错误信息
)
as
begin
  delete from EMPSALETASK where NUM = @Num
  delete from EMPSALETASKDTL where NUM = @Num
  SET @MSG = ''
  RETURN(0)
end
GO
