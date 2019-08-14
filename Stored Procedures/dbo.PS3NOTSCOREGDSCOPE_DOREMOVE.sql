SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create Procedure [dbo].[PS3NOTSCOREGDSCOPE_DOREMOVE]
(
    @Num varchar(14),         --单号
    @Cls varchar(10),
    @Msg varchar(255) output  --错误信息
)
as
begin
  delete from PS3NOTSCOREGDSCOPE where NUM = @Num and CLS = @Cls
  delete from PS3NOTSCOREGDSCOPEDTL where NUM = @Num and CLS = @Cls
  delete from PS3NOTSCOREGDSCOPELACSTORE where NUM = @Num and CLS = @Cls
  SET @MSG = ''
  RETURN(0)
end
GO
