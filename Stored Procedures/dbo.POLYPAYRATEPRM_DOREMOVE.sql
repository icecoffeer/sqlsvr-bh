SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create Procedure [dbo].[POLYPAYRATEPRM_DOREMOVE]
(
    @Num varchar(14),         --单号
    @Cls varchar(10),
    @Msg varchar(255) output  --错误信息
)
as
begin
  delete from POLYPAYRATEPRM where NUM = @Num and CLS = @Cls;
  delete from POLYPAYRATEPRMDTL where NUM = @Num and CLS = @Cls;
  delete from POLYPAYRATEPRMLACSTORE where NUM = @Num and CLS = @Cls;
  SET @MSG = ''
  RETURN(0)
end
GO
