SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFIntfForHD_Download_Data_GdInput](
  @piStartIndex int,            --传入参数：记录索引，从1开始。
  @piCount int,                 --传入参数：记录数。
  @poErrMsg varchar(255) output --传出参数（返回值不为0时有效）：错误消息。
)
as
begin
  declare
    @SQL nvarchar(4000),
    @Params nvarchar(4000)

  --返回指定位置及数量的记录。
  set @SQL = '
    select
      CODE,
      CODETYPE,
      GID
    from (
      select
        ROW_NUMBER() OVER (ORDER BY CODE) ROWNUM,
        rtrim(CODE) CODE,
        CODETYPE,
        GID
      from GDINPUT(nolock)
      where 1 = 1
      ) a
    where a.ROWNUM >= @piStartIndex
    and a.ROWNUM < @piStartIndex + @piCount'
  set @Params = '@piStartIndex int, @piCount int'
  exec SP_EXECUTESQL @SQL, @Params, @piStartIndex, @piCount

  return 0
end
GO
