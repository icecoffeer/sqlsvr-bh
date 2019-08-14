SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFIntfForHD_Download_Data_Goods2](
  @poErrMsg varchar(255) output --传出参数（返回值不为0时有效）：错误消息。
)
as
begin
  select
    GID,
    rtrim(CODE) CODE,
    rtrim(NAME) NAME,
    rtrim(SPEC) SPEC,
    RTLPRC,
    INPRC,
    TAXRATE,
    SALE,
    rtrim(MUNIT) MUNIT,
    QPC,
    ISLTD
    from GOODS(nolock)
    order by GID
  return 0
end
GO
