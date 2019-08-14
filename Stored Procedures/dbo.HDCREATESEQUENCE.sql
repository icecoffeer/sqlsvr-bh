SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[HDCREATESEQUENCE]
(
  @piSeqName sysname,   --序列名
  @piInitial int,       --初始值
  @piInc int            --递增值
) as
begin
  declare @seq varchar(50)
  select @seq = substring(@piSeqName, 5, len(@piSeqName)-4)
  if not exists(select 1 from seq where objname = @seq)
    insert into seq(objname, nextvalue, inc) values(@seq, @piInitial, @piInc)
  else
    print 'WARNING: 创建序列' + @piSeqName + '失败，序列已存在'
  return(0)
end
GO
