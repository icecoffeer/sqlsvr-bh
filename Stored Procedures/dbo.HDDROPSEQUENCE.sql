SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[HDDROPSEQUENCE]
(
  @piName sysname --序列名
) as
begin
  declare @seq varchar(50)
  select @seq = substring(@piName, 5, len(@piName)-4)
  delete from SEQ where OBJNAME = @seq
  print 'HINT: HDDROPSEQUENCE序列' + @piName + '成功'
  return(0)
end
GO
