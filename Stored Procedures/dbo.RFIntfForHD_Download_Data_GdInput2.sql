SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFIntfForHD_Download_Data_GdInput2](
  @poErrMsg varchar(255) output --传出参数（返回值不为0时有效）：错误消息。
)
as
begin
  select rtrim(CODE) CODE, CODETYPE, GID
    from GDINPUT(nolock)
    order by CODE
  return 0
end
GO
