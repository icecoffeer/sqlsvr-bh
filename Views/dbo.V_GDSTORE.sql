SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create view [dbo].[V_GDSTORE] (
  [STOREGID],
  [GDGID],
  [BILLTO],
  [SALE],
  [RTLPRC],
  [INPRC],
  [LOWINV],
  [HIGHINV],
  [PROMOTE],
  [GFT],
  [LWTRTLPRC],
  [MBRPRC],
  [DXPRC],
  [PAYRATE],
  [ISLTD],
  [CNTINPRC],
  [BQTYPRC],
  [ALC],
  [TopRtlPrc],
  [ALCQTY],
  [INVLOWBOUND],
  [INVHIGHBOUND],
  [SUGGESTEDQTYLOWBOUND],
  [SUGGESTEDQTYHIGHBOUND],
  [SUGGESTEDQTY],
  [ORDQTYMIN],
  [ALCCTR],
  [SALCQTY],
  [SALCQSTART]
) as
select s.GID STOREGID, g.GID GDGID, isnull(a.BILLTO, g.BILLTO) BILLTO,
isnull(a.SALE, g.SALE) SALE, isnull(a.RTLPRC, g.RTLPRC) RTLPRC,
isnull(a.INPRC, g.INPRC) INPRC, isnull(a.LOWINV, g.LOWINV) LOWINV,
isnull(a.HIGHINV, g.HIGHINV) HIGHINV, isnull(a.PROMOTE, g.PROMOTE) PROMOTE,
isnull(a.GFT, g.GFT) GFT, isnull(a.LWTRTLPRC, g.LWTRTLPRC) LWTRTLPRC,
isnull(a.MBRPRC, g.MBRPRC) MBRPRC, isnull(a.DXPRC, g.DXPRC) DXPRC,
isnull(a.PAYRATE, g.PAYRATE) PAYRATE, isnull(a.ISLTD, g.ISLTD) ISLTD,
isnull(a.CNTINPRC, g.CNTINPRC) CNTINPRC, isnull(a.BQTYPRC, g.BQTYPRC) BQTYPRC,
isnull(a.ALC, g.ALC) ALC, isnull(a.TopRtlPrc, g.TopRtlPrc) TopRtlPrc,
isnull(a.ALCQTY, g.ALCQTY) ALCQTY, a.INVLOWBOUND, a.INVHIGHBOUND, a.SUGGESTEDQTYLOWBOUND,
a.SUGGESTEDQTYHIGHBOUND, a.SUGGESTEDQTY, a.ORDQTYMIN, isnull(a.ALCCTR, g.ALCCTR) ALCCTR,
isnull(a.SALCQTY, g.SALCQTY) SALCQTY, isnull(a.SALCQSTART, g.SALCQSTART) SALCQSTART
from STORE s(nolock)
cross join GOODS g(nolock)
left join GDSTORE a(nolock) on s.GID = a.STOREGID and g.GID = a.GDGID
where s.GID <> (select USERGID from SYSTEM(nolock))
GO