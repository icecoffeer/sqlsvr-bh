SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[CRMSTAMPSCORULE_OCR]
(
  @Num varchar(14),
  @Oper varchar(20),
  @Msg varchar(255) output
) as
begin

  --删除原先的记录
  delete from PS3STAMPSCORULE
  delete from PS3NOTSTAMPSCOGOODS 

  --将单据中的值插入到当前值表
  insert into PS3STAMPSCORULE(UUID,TOTAL,SCORE,SCOTOP,BEGINDATE,ENDDATE,NOTE,OPER,OPERTIME)
  select UUID,TOTAL,SCORE,SCOTOP,BEGINDATE,ENDDATE,NOTE,@Oper,getdate() from CRMSTAMPSCORULEDTL
  where Num = @Num 
  
  insert into PS3NOTSTAMPSCOGOODS(GOODS,NOTE,OPER,OPERTIME)
  select GOODS,NOTE,@Oper,getdate() from CRMSTAMPSCORULEDTL2
  where Num = @Num   
  
  return(0)
end

GO
