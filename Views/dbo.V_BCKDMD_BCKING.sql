SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create view [dbo].[V_BCKDMD_BCKING] (
  [GDGID],
  [BCKINGQTY]
) as
select b.gid, isnull(sum(qty - bckedqty),0) from (
select d.gdgid, d.qty, d.bckedqty from bckdmddtl d(nolock), bckdmd m(nolock)
where m.stat = 400
  and d.num = m.num
union all
select vd.gdgid, vd.qty, vd.bckedqty from vdrbckdmddtl vd(nolock), vdrbckdmd vm(nolock)
where vm.stat = 500
  and vd.num = vm.num) a ,goods b where a.gdgid =* b.gid and b.autoord=1
group by b.gid
GO
