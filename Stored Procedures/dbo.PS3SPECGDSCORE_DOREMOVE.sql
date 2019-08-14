SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create Procedure [dbo].[PS3SPECGDSCORE_DOREMOVE]
(
    @Num varchar(14),         --单号
    @Cls varchar(10),
    @Msg varchar(255) output  --错误信息
)
as
begin
  delete from PS3SPECGDSCORE where NUM = @Num and CLS = @Cls
  delete from PS3SPECGDSCOREDTL where NUM = @Num and CLS = @Cls
  delete from PS3SPECGDSCOREPROMSUBJOUTDTL where NUM = @Num and CLS = @Cls
  delete from PS3SPECGDSCORELACSTORE where NUM = @Num and CLS = @Cls
  delete from PS3SPECGDSCORESPECDIS where NUM = @Num and CLS = @Cls

  SET @MSG = ''
  RETURN(0)
end
GO
