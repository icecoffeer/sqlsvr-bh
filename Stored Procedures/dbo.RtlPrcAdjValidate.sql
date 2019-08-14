SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[RtlPrcAdjValidate](
  @p_num varchar(14)
) as
begin
  declare @title varchar(200)
          
  --提取信息
  set @title = '售价调整单[' + @p_num + ']在' + Convert(varchar, getdate(), 20) + '生效了'
  --触发
  execute RtlPrcAdjPrompt @title, '售价调整单生效提醒', @p_num
end
GO
