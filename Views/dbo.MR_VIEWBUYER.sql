SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[MR_VIEWBUYER](	
		code,
		name	
	) AS SELECT code,name from viewbuyer(nolock)	
GO
