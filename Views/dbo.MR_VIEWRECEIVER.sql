SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[MR_VIEWRECEIVER](	
		code,
		name	
	) AS SELECT code,name from viewreceiver (nolock)
GO
