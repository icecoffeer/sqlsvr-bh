SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create view [dbo].[v_unvdrdrpt] as
select ASETTLENO,bgdgid,adate,bwrh,bvdrgid from vdrdrpt v(nolock)
where ASTORE = (SELECT USERGID FROM SYSTEM(NOLOCK))
AND not exists (select 1 from payeddtl(nolock) where asettleno=v.asettleno and gdgid=v.bgdgid and adate=v.adate and wrh=v.bwrh and bvdrgid=v.bvdrgid) 
GO
