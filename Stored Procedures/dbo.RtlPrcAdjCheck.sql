SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[RtlPrcAdjCheck](
  @p_num varchar(14)
) as
begin
  declare @title varchar(200)
  --declare @username varchar(20)
          
  --提取信息
  set @title = '售价调整单[' + @p_num + ']在' + Convert(varchar, getdate(), 20) + '被审核了'
  --触发
  execute RtlPrcAdjPrompt @title, '售价调整单审核提醒', @p_num
end
GO
