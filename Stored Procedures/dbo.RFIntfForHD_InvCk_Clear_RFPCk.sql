SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFIntfForHD_InvCk_Clear_RFPCk](
  @piEmpCode varchar(10),
  @poErrMsg varchar(255) output
)
as
begin
  declare
    @vEmpGid int

  --公共变量初始化
  select @vEmpGid = GID from EMPLOYEE(nolock)
    where CODE = @piEmpCode

  --将数据转移至RFPCKH，清空RFPCK
  delete RFPCKH from RFPCK(nolock)
    where RFPCKH.UUID = RFPCK.UUID
    and RFPCK.FILLER = @vEmpGid
  insert into RFPCKH(UUID, FILLER, WRH, GDGID, QTY,
    FILDATE, LSTUPDTIME, NOTE, GENNUM, GENCLS,
    SUBWRH, PDANUM)
    select UUID, FILLER, WRH, GDGID, QTY,
      FILDATE, LSTUPDTIME, NOTE, GENNUM, GENCLS,
      SUBWRH, PDANUM
    from RFPCK(nolock)
    where FILLER = @vEmpGid
  delete from RFPCK where FILLER = @vEmpGid

  --清空生成单据表
  delete from RFPCKGENBILLS where SPID = @@spid

  return 0
end
GO
