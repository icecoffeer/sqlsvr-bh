SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create view [dbo].[cjkdb2] as select * from ytbhmis..cjkdb (nolock) where flag <= 3 and leftall <> 0

GO
