SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFIntfForHD_Download_Data_BarcodeLen](
  @poErrMsg varchar(255) output
)
as
begin
  select rtrim(POSNO) POSNO, rtrim(FLAG) FLAG, CODELEN, QTYLEN, AMTLEN
    from BARCODELEN(nolock)
  return 0
end
GO
