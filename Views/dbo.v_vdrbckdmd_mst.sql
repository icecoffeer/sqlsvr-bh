SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create view [dbo].[v_vdrbckdmd_mst] as
select num, sum(qty) sqty, sum(cases) scases, 
    sum(dmdcases) sdmdcases, sum(dmdqty) sdmdqty,
    sum(qty * price) samt, sum(dmdqty * dmdprice) sdmdamt
from vdrbckdmddtl
group by num
GO
