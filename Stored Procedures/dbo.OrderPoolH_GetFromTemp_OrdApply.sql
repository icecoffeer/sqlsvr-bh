SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[OrderPoolH_GetFromTemp_OrdApply](
  @piCaller varchar(255),
  @poErrMsg varchar(255) output
)
as
begin
  delete ORDERPOOLH from ORDERPOOLHTEMP a
    where a.SPID = @@spid
      and a.UUID = ORDERPOOLH.UUID
  insert into ORDERPOOLH(UUID, GDGID, VDRGID, WRH, COMBINETYPE, SENDDATE, QTY,
    PRICE, ORDERTYPE, IMPTIME, IMPORTER, ORDERDATE, SPLITDAYS,
    NOTE, ROUNDTYPE)
  select UUID, GDGID, VDRGID, WRH, COMBINETYPE, SENDDATE, QTY,
    PRICE, ORDERTYPE, IMPTIME, IMPORTER, ORDERDATE, SPLITDAYS,
    isnull(NOTE, '') + ';' + @piCaller + '调用.', ROUNDTYPE
    from ORDERPOOLHTEMP(nolock)
    where SPID = @@spid
  return(0);
end
GO
