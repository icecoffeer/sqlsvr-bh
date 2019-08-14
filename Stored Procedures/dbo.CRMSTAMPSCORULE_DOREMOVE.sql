SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create Procedure [dbo].[CRMSTAMPSCORULE_DOREMOVE]
(
    @Num varchar(14),         --单号
    @Msg varchar(255) output  --错误信息
)
as
begin
  delete from CRMSTAMPSCORULE where NUM = @Num 
  delete from CRMSTAMPSCORULEDTL where NUM = @Num 
  delete from CRMSTAMPSCORULEDTL2 where NUM = @Num 
  delete from CRMSTAMPSCORULELACSTORE where NUM = @Num 
  SET @MSG = ''
  RETURN(0)
end

GO
