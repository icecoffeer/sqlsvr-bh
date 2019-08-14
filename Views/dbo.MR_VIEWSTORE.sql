SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[MR_VIEWSTORE](	
		gid,
                code,
		name	
	) AS SELECT gid,code,name from VIEWSTORE(nolock)
GO
