SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create view [dbo].[v_bckdmd_mst2] as
select v.num, g.sort, '['+rtrim(gds.code)+']' + rtrim(gds.name) sortname from bckdmddtl v(nolock), goods g(nolock), sort gds(nolock) where v.gdgid = g.gid
and gds.code = g.sort
group by num,g.sort,gds.code, gds.name
GO
