SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE VIEW	[dbo].[V_VDRYRPT]	(	
		ASTORE	,
		BVDRGID	,
		BGDGID	,
		BWRH	,
		NPQTY	,
		NPTL	,
		NPSTL	,
		NPINQTY	,
		NPINTL	
	) AS SELECT		
		ASTORE,	
		BVDRGID,	
		BGDGID,	
		BWRH,	
		(CQ3-CQ4+CQ6)+(DQ3-DQ4+DQ6),	
		case (select inprctax from system)	
		when 1 then (CT3-CT4+CT6)+(DT3-DT4+DT6)	
		else (ct3 + dt3) * (1 + (select taxrate from goodsh where gid = vdryrpt.bgdgid) / 100) - (ct4 + dt4) + ct6 + dt6	
		end,	
		(CT2-CT7)+(DT2-DT7),	
		(CQ1-CQ4)+(DQ1-DQ4),	
		(CT1-CT4)+(DT1-DT4)	
	FROM VDRYRPT		
	WHERE ASETTLENO = (SELECT MAX(NO) FROM YEARSETTLE)		
	
GO
